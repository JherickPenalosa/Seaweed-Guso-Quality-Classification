
"""Secure gUSo password recovery through verified email or SMS.

Email identifiers use a verified email address.
Phone identifiers use a verified mobile number.

Recovery requests do not disclose account existence.
OTPs are hashed, expiring, rate-limited and single-use.
"""

import logging
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.otp import (
    OTP_EXPIRATION_MINUTES,
    OTP_MAX_ATTEMPTS,
    OTP_RESEND_COOLDOWN_SECONDS,
)
from app.core.security import (
    generate_password_reset_otp,
    hash_password,
    hash_password_reset_otp,
    verify_password_reset_otp,
)
from app.database.models import OtpVerification, User
from app.database.repository import (
    get_user_by_contact_num,
    get_user_by_email,
)
from app.services.email_service import (
    normalize_email_address,
    send_password_reset_email,
)
from app.services.sms_service import (
    normalize_mobile_number,
    send_verification_sms,
)

logger = logging.getLogger(__name__)

PASSWORD_RESET_PURPOSE = "password_reset"
MAX_RESET_REQUESTS_PER_HOUR = 5

_INVALID_CODE = (
    "Invalid or expired recovery code. "
    "Request a new code if necessary."
)


def _utc_now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _naive_utc(value: datetime) -> datetime:
    if value.tzinfo is not None and value.utcoffset() is not None:
        return value.astimezone(timezone.utc).replace(
            tzinfo=None
        )
    return value


def _find_user(
    db: Session,
    identifier: str,
) -> User | None:
    if not isinstance(identifier, str):
        return None

    entered = identifier.strip()
    if not entered:
        return None

    if "@" in entered:
        return get_user_by_email(db, entered.lower())

    try:
        normalized = normalize_mobile_number(entered)
    except (TypeError, ValueError):
        return None

    national = normalized[2:]
    variants = (
        entered,
        "0" + national,
        normalized,
        "+" + normalized,
        national,
    )

    for number in dict.fromkeys(variants):
        user = get_user_by_contact_num(db, number)
        if user is not None:
            return user

    return None


def _verified_recovery_channel(
    user: User,
    identifier: str,
) -> tuple[str, str] | None:
    """Return only a recovery channel verified by the owner."""

    entered = identifier.strip()

    if "@" in entered:
        if not bool(user.email_verified) or not user.email:
            return None

        try:
            address = normalize_email_address(user.email)
        except (TypeError, ValueError):
            return None

        return ("email", address)

    if not (
        bool(user.is_verified)
        and bool(user.contact_verified)
    ):
        return None

    try:
        number = normalize_mobile_number(user.contact_num)
    except (TypeError, ValueError):
        return None

    return ("sms", number)


def _pending_code(
    db: Session,
    user_id: int,
    *,
    lock: bool = False,
):
    query = (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user_id,
            OtpVerification.purpose
            == PASSWORD_RESET_PURPOSE,
            OtpVerification.verified_at.is_(None),
        )
        .order_by(
            OtpVerification.created_at.desc(),
            OtpVerification.otp_id.desc(),
        )
    )

    return (
        query.with_for_update() if lock else query
    ).first()


def request_password_reset(
    db: Session,
    identifier: str,
) -> None:
    """Request an OTP without revealing account existence."""

    found = _find_user(db, identifier)
    if found is None:
        return

    user = (
        db.query(User)
        .filter(User.user_id == found.user_id)
        .with_for_update()
        .first()
    )

    if user is None:
        return

    channel = _verified_recovery_channel(
        user,
        identifier,
    )

    if channel is None:
        db.rollback()
        return

    channel_type, destination = channel
    now = _utc_now()

    previous = _pending_code(db, user.user_id)

    if (
        previous is not None
        and previous.created_at is not None
    ):
        elapsed = (
            now - _naive_utc(previous.created_at)
        ).total_seconds()

        if elapsed < OTP_RESEND_COOLDOWN_SECONDS:
            db.rollback()
            return

    hourly_count = (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user.user_id,
            OtpVerification.purpose
            == PASSWORD_RESET_PURPOSE,
            OtpVerification.created_at
            >= now - timedelta(hours=1),
        )
        .count()
    )

    if hourly_count >= MAX_RESET_REQUESTS_PER_HOUR:
        db.rollback()
        return

    code = generate_password_reset_otp()

    # Invalidate only previous password-reset codes.
    (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user.user_id,
            OtpVerification.purpose
            == PASSWORD_RESET_PURPOSE,
            OtpVerification.verified_at.is_(None),
            OtpVerification.expires_at > now,
        )
        .update(
            {OtpVerification.expires_at: now},
            synchronize_session=False,
        )
    )

    db.add(
        OtpVerification(
            user_id=user.user_id,
            purpose=PASSWORD_RESET_PURPOSE,
            otp_hash=hash_password_reset_otp(
                user.user_id,
                code,
            ),
            attempts=0,
            created_at=now,
            expires_at=now
            + timedelta(
                minutes=OTP_EXPIRATION_MINUTES
            ),
        )
    )

    db.flush()

    try:
        if channel_type == "email":
            send_password_reset_email(
                destination,
                code,
            )
        else:
            # Preserve existing Semaphore / dev SMS behavior.
            send_verification_sms(
                destination,
                code,
            )

    except Exception:
        db.rollback()

        # Do not expose the OTP or account details.
        logger.warning(
            "Password recovery delivery failed; "
            "no OTP was activated."
        )
        return

    try:
        db.commit()
    except Exception:
        db.rollback()
        raise


def confirm_password_reset(
    db: Session,
    identifier: str,
    code: str,
    new_password: str,
) -> None:
    """Consume a verified OTP and change the password."""

    found = _find_user(db, identifier)

    if found is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=_INVALID_CODE,
        )

    user = (
        db.query(User)
        .filter(User.user_id == found.user_id)
        .with_for_update()
        .first()
    )

    if (
        user is None
        or _verified_recovery_channel(
            user, identifier
        ) is None
    ):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=_INVALID_CODE,
        )

    record = _pending_code(
        db,
        user.user_id,
        lock=True,
    )
    now = _utc_now()

    if (
        record is None
        or record.expires_at is None
        or now >= _naive_utc(record.expires_at)
    ):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=_INVALID_CODE,
        )

    if record.attempts >= OTP_MAX_ATTEMPTS:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=(
                "Too many incorrect attempts. "
                "Request a new recovery code."
            ),
        )

    if not verify_password_reset_otp(
        user.user_id,
        code,
        record.otp_hash,
    ):
        record.attempts += 1

        if record.attempts >= OTP_MAX_ATTEMPTS:
            record.expires_at = now

        db.commit()

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=_INVALID_CODE,
        )

    if (
        not isinstance(new_password, str)
        or len(new_password) < 8
    ):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "The new password must contain "
                "at least eight characters."
            ),
        )

    try:
        user.password_hash = hash_password(
            new_password
        )

        user.auth_token_version = (
            int(user.auth_token_version or 0) + 1
        )

        record.verified_at = now

        db.flush()

        (
            db.query(OtpVerification)
            .filter(
                OtpVerification.user_id == user.user_id,
                OtpVerification.purpose
                == PASSWORD_RESET_PURPOSE,
                OtpVerification.otp_id != record.otp_id,
                OtpVerification.verified_at.is_(None),
                OtpVerification.expires_at > now,
            )
            .update(
                {OtpVerification.expires_at: now},
                synchronize_session=False,
            )
        )

        db.commit()

    except Exception:
        db.rollback()
        raise
