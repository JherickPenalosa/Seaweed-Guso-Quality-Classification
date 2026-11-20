"""gUSo OTP API: preserve SMS verification and add email verification.

Both channels require the account's password before a code can be sent or
checked. Each code is generated, hashed, expired and verified by otp_service;
this router never exposes raw OTPs or provider credentials.

SMS endpoints (unchanged):
    POST /auth/otp/send
    POST /auth/otp/verify

Email endpoints (new):
    POST /auth/otp/email/send
    POST /auth/otp/email/verify
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from app.core.security import verify_password
from app.database.database import get_db
from app.database.repository import get_user_by_contact_num, get_user_by_email
from app.schemas.otp import (
    SmsOtpRequest,
    SmsOtpSendResponse,
    SmsOtpVerifyRequest,
    SmsOtpVerifyResponse,
)
from app.services.email_service import send_verification_email
from app.services.otp_service import (
    CONTACT_VERIFICATION,
    EMAIL_VERIFICATION,
    send_verification_otp,
    verify_verification_otp,
)
from app.services.sms_service import normalize_mobile_number, send_verification_sms


router = APIRouter(prefix="/auth/otp")


class EmailOtpRequest(BaseModel):
    """Use the account's registered email and password."""

    email: EmailStr = Field(description="Registered gUSo email address")
    password: str = Field(min_length=1, max_length=128, repr=False)


class EmailOtpVerifyRequest(EmailOtpRequest):
    """Email OTP confirmation: six ASCII digits (no leading spaces)."""

    code: str = Field(
        min_length=6,
        max_length=6,
        pattern=r"^[0-9]{6}$",
        description="Six-digit email verification code",
        repr=False,
    )


def authenticate_verification_user(
    db: Session,
    contact_num: str,
    password: str,
):
    """Existing SMS sign-in check, preserved for compatibility."""
    normalized = normalize_mobile_number(contact_num)
    national = normalized[2:]

    candidates = [
        contact_num.strip(),
        "0" + national,
        normalized,
        "+" + normalized,
        national,
    ]

    user = None
    for number in dict.fromkeys(candidates):
        user = get_user_by_contact_num(db, number)
        if user is not None:
            break

    if user is None or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid mobile number or password.",
        )

    return user


def authenticate_email_verification_user(
    db: Session,
    email: str,
    password: str,
):
    """Authenticate without revealing whether an email is registered."""
    normalized_email = str(email).strip().lower()
    user = get_user_by_email(db, normalized_email)

    if user is None or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    return user


# ---------------------------------------------------------------------------
# Existing SMS OTP endpoints — URLs and payloads are unchanged.
# ---------------------------------------------------------------------------

@router.post(
    "/send",
    response_model=SmsOtpSendResponse,
    status_code=status.HTTP_200_OK,
    tags=["SMS Verification"],
)
def send_sms_otp(
    data: SmsOtpRequest,
    db: Session = Depends(get_db),
):
    user = authenticate_verification_user(
        db=db,
        contact_num=data.contact_num,
        password=data.password,
    )

    return send_verification_otp(
        db=db,
        user_id=user.user_id,
        purpose=CONTACT_VERIFICATION,
        deliver_code=send_verification_sms,
    )


@router.post(
    "/verify",
    response_model=SmsOtpVerifyResponse,
    status_code=status.HTTP_200_OK,
    tags=["SMS Verification"],
)
def verify_sms_otp(
    data: SmsOtpVerifyRequest,
    db: Session = Depends(get_db),
):
    user = authenticate_verification_user(
        db=db,
        contact_num=data.contact_num,
        password=data.password,
    )

    return verify_verification_otp(
        db=db,
        user_id=user.user_id,
        purpose=CONTACT_VERIFICATION,
        code=data.code,
    )


# ---------------------------------------------------------------------------
# New email OTP endpoints — only the registered email receives the code.
# ---------------------------------------------------------------------------

@router.post(
    "/email/send",
    response_model=SmsOtpSendResponse,
    status_code=status.HTTP_200_OK,
    tags=["Email Verification"],
)
def send_email_otp(
    data: EmailOtpRequest,
    db: Session = Depends(get_db),
):
    user = authenticate_email_verification_user(
        db=db,
        email=str(data.email),
        password=data.password,
    )

    # Reuses the five-minute expiration, resend cooldown and hashed OTP
    # storage from File 116, but delivers to the registered email via Gmail.
    return send_verification_otp(
        db=db,
        user_id=user.user_id,
        purpose=EMAIL_VERIFICATION,
        deliver_code=send_verification_email,
    )


@router.post(
    "/email/verify",
    response_model=SmsOtpVerifyResponse,
    status_code=status.HTTP_200_OK,
    tags=["Email Verification"],
)
def verify_email_otp(
    data: EmailOtpVerifyRequest,
    db: Session = Depends(get_db),
):
    user = authenticate_email_verification_user(
        db=db,
        email=str(data.email),
        password=data.password,
    )

    return verify_verification_otp(
        db=db,
        user_id=user.user_id,
        purpose=EMAIL_VERIFICATION,
        code=data.code,
    )