"""One-time account verification for gUSo: SMS and email.

Each delivery method gets its own OTP purpose and verified flag. An email
verification never marks a phone number verified, and vice versa.

This module does not send messages itself. API routes must authenticate the
account holder before calling these functions, then supply the appropriate
trusted delivery callback:
    contact_verification -> send_verification_sms
    email_verification   -> send_verification_email
"""

from datetime import datetime, timezone
from typing import Callable

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.otp import (
    generate_otp,
    hash_otp,
    verify_otp,
    otp_expiration,
    is_otp_expired,
    OTP_MAX_ATTEMPTS,
    OTP_RESEND_COOLDOWN_SECONDS,
    OTP_EXPIRATION_MINUTES,
)
from app.database.repository import (
    get_user_by_id,
    create_otp_record,
    get_pending_otp,
    increment_otp_attempts,
)

CONTACT_VERIFICATION = "contact_verification"
EMAIL_VERIFICATION = "email_verification"
SUPPORTED_PURPOSES = (CONTACT_VERIFICATION, EMAIL_VERIFICATION)


def utc_now() -> datetime:
    """Current naive UTC time, matching the existing PostgreSQL columns."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


def validate_purpose(purpose: str) -> None:
    if purpose not in SUPPORTED_PURPOSES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported verification method.",
        )


def get_verification_destination(user, purpose: str) -> str:
    """Return only the contact method associated with the requested purpose."""
    validate_purpose(purpose)

    if purpose == CONTACT_VERIFICATION:
        if not user.contact_num or not user.contact_num.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This account has no registered contact number.",
            )
        return user.contact_num.strip()

    if not user.email or not user.email.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This account has no registered email address.",
        )
    return user.email.strip()


def _already_verified(user, purpose: str) -> bool:
    return bool(
        user.contact_verified
        if purpose == CONTACT_VERIFICATION
        else user.email_verified
    )


def send_verification_otp(
    db: Session,
    user_id: int,
    purpose: str,
    deliver_code: Callable[[str, str], None],
) -> dict:
    """Generate, store a hash, and deliver a six-digit verification code.

    `deliver_code` must be a trusted backend callback, not a URL or function
    name selected by the client. Never return the plaintext OTP to Flutter.
    """
    validate_purpose(purpose)
    user = get_user_by_id(db, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    destination = get_verification_destination(user, purpose)
    if _already_verified(user, purpose):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This contact method is already verified.",
        )

    previous = get_pending_otp(db, user_id, purpose)
    if previous is not None and previous.created_at is not None:
        elapsed_seconds = (utc_now() - previous.created_at).total_seconds()
        if (
            elapsed_seconds < OTP_RESEND_COOLDOWN_SECONDS
            and not is_otp_expired(previous.expires_at)
        ):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Please wait before requesting another OTP.",
            )

    code = generate_otp()
    record = create_otp_record(
        db=db,
        user_id=user_id,
        purpose=purpose,
        otp_hash=hash_otp(code),
        expires_at=otp_expiration(),
    )

    try:
        deliver_code(destination, code)
    except Exception as exc:
        # A failed delivery must not leave an active OTP in PostgreSQL.
        # Do not leak SMTP, SMS, passwords, addresses or codes to the client.
        try:
            record.expires_at = utc_now()
            db.commit()
        except Exception:
            db.rollback()
            raise
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to send verification code. Please try again.",
        ) from exc

    return {
        "message": "Verification code sent.",
        "expires_in_minutes": OTP_EXPIRATION_MINUTES,
    }


def verify_verification_otp(
    db: Session,
    user_id: int,
    purpose: str,
    code: str,
) -> dict:
    """Validate a purpose-specific, single-use OTP and update account flags."""
    validate_purpose(purpose)
    user = get_user_by_id(db, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    get_verification_destination(user, purpose)
    if _already_verified(user, purpose):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This contact method is already verified.",
        )

    record = get_pending_otp(db, user_id, purpose)
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No pending verification code.",
        )

    if is_otp_expired(record.expires_at):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Verification code has expired.",
        )

    if record.attempts >= OTP_MAX_ATTEMPTS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many incorrect attempts. Request a new code.",
        )

    if not verify_otp(code, record.otp_hash):
        increment_otp_attempts(db, record)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect verification code.",
        )

    record.verified_at = utc_now()
    if purpose == CONTACT_VERIFICATION:
        user.contact_verified = True
    else:
        user.email_verified = True

    # One successfully verified method activates the account. The other
    # method remains unverified until its own OTP is successfully checked.
    user.is_verified = bool(user.contact_verified or user.email_verified)

    try:
        db.commit()
        db.refresh(user)
    except Exception:
        db.rollback()
        raise

    return {
        "message": "Verification successful.",
        "contact_verified": bool(user.contact_verified),
        "email_verified": bool(user.email_verified),
        "is_verified": bool(user.is_verified),
    }
