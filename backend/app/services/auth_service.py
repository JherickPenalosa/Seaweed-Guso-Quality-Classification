"""Account registration and login for gUSo.

A user may activate their account by verifying either the registered email
address or the registered mobile number. Verification of one method never
implies verification of the other.

OTP sending and verification remain in the separate OTP service and API.
"""

from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.database.repository import (
    create_user,
    get_user_by_contact_num,
    get_user_by_email,
)
from app.schemas.auth import LoginRequest, RegisterRequest


def register_user(db: Session, data: RegisterRequest) -> dict:
    """Register an account without granting access before OTP verification."""
    first_name = data.first_name.strip()
    last_name = data.last_name.strip()
    full_name = f"{first_name} {last_name}"

    # Email remains optional. Preserve the existing registration contract.
    email = str(data.email).strip().lower() if data.email else None
    contact_num = data.contact_num.strip()

    if email is not None and get_user_by_email(db, email) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email is already registered.",
        )

    if get_user_by_contact_num(db, contact_num) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Contact number is already registered.",
        )

    password_hash = hash_password(data.password)

    try:
        user = create_user(
            db=db,
            full_name=full_name,
            email=email,
            contact_num=contact_num,
            password_hash=password_hash,
        )
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with the provided information already exists.",
        ) from exc

    return {
        "message": "Registration successful.",
        "user": {
            "user_id": user.user_id,
            "full_name": user.full_name,
            "email": user.email,
            "contact_num": user.contact_num,
            "is_verified": user.is_verified,
        },
    }


def login_user(db: Session, data: LoginRequest) -> dict:
    """Log in only after a real email or phone OTP has been verified."""
    identifier = data.identifier.strip()

    if "@" in identifier:
        user = get_user_by_email(db, identifier.lower())
    else:
        user = get_user_by_contact_num(db, identifier)

    # Verify credentials before disclosing account verification status.
    if user is None or not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email/contact number or password.",
        )

    verified_mobile = bool(user.contact_num and user.contact_verified)
    verified_email = bool(user.email and user.email_verified)

    # Require both an activated account and a genuinely verified contact
    # method. Do not use development/demo mode to bypass this check.
    if not user.is_verified or not (verified_mobile or verified_email):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Your account is not verified. Please verify your registered "
                "email address or mobile number before logging in."
            ),
        )

    access_token = create_access_token(
        user_id=user.user_id,
        token_version=user.auth_token_version,
    )

    return {
        "message": "Login successful.",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "user_id": user.user_id,
            "full_name": user.full_name,
            "email": user.email,
            "contact_num": user.contact_num,
            "is_verified": user.is_verified,
        },
    }
