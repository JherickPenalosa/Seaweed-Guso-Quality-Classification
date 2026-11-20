
"""Email OTP verification for gUSo registration.

Provides email-based account verification without requiring
an SMS provider.

Email delivery uses the existing gUSo email_service.py.
"""

from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.otp import (
    generate_otp,
    hash_otp,
    verify_otp,
    OTP_EXPIRATION_MINUTES,
    OTP_MAX_ATTEMPTS,
    OTP_RESEND_COOLDOWN_SECONDS,
)
from app.core.security import verify_password
from app.database.models import User, OtpVerification
from app.services.email_service import send_verification_email


EMAIL_VERIFICATION = "email_verification"

MAX_REQUESTS_PER_HOUR = 5


def _utc_now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _normalize_datetime(value: datetime) -> datetime:
    if value.tzinfo is not None:
        return value.astimezone(timezone.utc).replace(
            tzinfo=None
        )
    return value


def _authenticate_user(
    db: Session,
    email: str,
    password: str,
) -> User:
    """Authenticate the owner before issuing or verifying OTP."""

    if not isinstance(email, str):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    normalized_email = email.strip().lower()

    if not normalized_email or "@" not in normalized_email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    user = (
        db.query(User)
        .filter(User.email == normalized_email)
        .with_for_update()
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    if not verify_password(
        password,
        user.password_hash,
    ):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    return user


def _latest_pending_otp(
    db: Session,
    user_id: int,
):
    return (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user_id,
            OtpVerification.purpose == EMAIL_VERIFICATION,
            OtpVerification.verified_at.is_(None),
        )
        .order_by(
            OtpVerification.created_at.desc(),
            OtpVerification.otp_id.desc(),
        )
        .with_for_update()
        .first()
    )


def send_registration_email_otp(
    db: Session,
    email: str,
    password: str,
) -> dict:
    """Send a verification code to an unverified account email."""

    user = _authenticate_user(
        db,
        email,
        password,
    )

    if user.email_verified:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This email is already verified.",
        )

    if not user.email:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This account has no registered email.",
        )

    now = _utc_now()

    previous = _latest_pending_otp(
        db,
        user.user_id,
    )

    if (
        previous is not None
        and previous.created_at is not None
        and previous.expires_at is not None
    ):
        elapsed = (
            now - _normalize_datetime(previous.created_at)
        ).total_seconds()

        still_active = (
            now < _normalize_datetime(previous.expires_at)
        )

        if (
            still_active
            and elapsed < OTP_RESEND_COOLDOWN_SECONDS
        ):
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Please wait before requesting another code.",
            )

    hourly_requests = (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user.user_id,
            OtpVerification.purpose == EMAIL_VERIFICATION,
            OtpVerification.created_at
            >= now - timedelta(hours=1),
        )
        .count()
    )

    if hourly_requests >= MAX_REQUESTS_PER_HOUR:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=(
                "Too many verification requests. "
                "Please try again later."
            ),
        )

    code = generate_otp()

    # Invalidate previous unused email-verification codes.
    (
        db.query(OtpVerification)
        .filter(
            OtpVerification.user_id == user.user_id,
            OtpVerification.purpose == EMAIL_VERIFICATION,
            OtpVerification.verified_at.is_(None),
            OtpVerification.expires_at > now,
        )
        .update(
            {OtpVerification.expires_at: now},
            synchronize_session=False,
        )
    )

    record = OtpVerification(
        user_id=user.user_id,
        purpose=EMAIL_VERIFICATION,
        otp_hash=hash_otp(code),
        attempts=0,
        created_at=now,
        expires_at=now + timedelta(
            minutes=OTP_EXPIRATION_MINUTES
        ),
    )

    try:
        db.add(record)
        db.flush()

        # Existing Gmail/Brevo email delivery service.
        # The code is never returned to Flutter.
        send_verification_email(
            user.email,
            code,
        )

        db.commit()

    except Exception:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=(
                "Unable to send the verification email. "
                "Please try again."
            ),
        )

    return {
        "message": "Verification email requested successfully.",
        "expires_in_minutes": OTP_EXPIRATION_MINUTES,
    }


def verify_registration_email_otp(
    db: Session,
    email: str,
    password: str,
    code: str,
) -> dict:
    """Verify the email OTP and activate the account."""

    user = _authenticate_user(
        db,
        email,
        password,
    )

    if user.email_verified:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This email is already verified.",
        )

    if (
        not isinstance(code, str)
        or len(code) != 6
        or not code.isascii()
        or not code.isdigit()
    ):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Enter a valid six-digit verification code.",
        )

    record = _latest_pending_otp(
        db,
        user.user_id,
    )

    now = _utc_now()

    if record is None:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No pending verification code.",
        )

    if now >= _normalize_datetime(record.expires_at):
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Verification code has expired.",
        )

    if record.attempts >= OTP_MAX_ATTEMPTS:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many incorrect verification attempts.",
        )

    if not verify_otp(
        code,
        record.otp_hash,
    ):
        record.attempts += 1

        if record.attempts >= OTP_MAX_ATTEMPTS:
            record.expires_at = now

        db.commit()

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect verification code.",
        )

    try:
        record.verified_at = now

        user.email_verified = True

        # Temporary registration policy:
        # verified email or previously verified phone.
        # Preserve existing verified accounts.
        user.is_verified = bool(
            user.email_verified or user.contact_verified
        )

        db.commit()
        db.refresh(user)

    except Exception:
        db.rollback()
        raise

    return {
        "message": "Email verified successfully.",
        "email_verified": user.email_verified,
        "contact_verified": user.contact_verified,
        "is_verified": user.is_verified,
    }
