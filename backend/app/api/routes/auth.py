"""gUSo authentication, recovery, and authenticated account deletion routes.

DELETE /auth/me requires a valid bearer token, current password, and the
literal confirmation DELETE. All app-owned records are removed transactionally.
"""

from importlib import import_module
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, SecretStr
from sqlalchemy import delete, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.core.auth_dependencies import get_current_user
from app.core.security import verify_password
from app.database.database import get_db
from app.database.models import (
    ClassificationImage,
    ClassificationRecord,
    OtpVerification,
    User,
)
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    RegisterResponse,
)
from app.schemas.password_reset import (
    PasswordResetConfirm,
    PasswordResetRequest,
    PasswordResetResponse,
)
from app.services.auth_service import login_user, register_user


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    """Create an account. Mobile number verification remains a separate step."""
    return register_user(db=db, data=data)


@router.post(
    "/login",
    response_model=LoginResponse,
    status_code=status.HTTP_200_OK,
)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    return login_user(db=db, data=data)


# The existing recovery endpoints call this service, installed in File 106.
def _password_reset_service():
    """Keep login/registration available if recovery is not configured."""
    try:
        return import_module("app.services.password_reset_service")
    except ModuleNotFoundError as exc:
        if exc.name != "app.services.password_reset_service":
            raise
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Password recovery is not configured yet.",
        ) from exc


@router.post(
    "/password-reset/request",
    response_model=PasswordResetResponse,
    status_code=status.HTTP_202_ACCEPTED,
    responses={503: {"description": "Recovery service is not yet configured"}},
)
def request_password_reset(
    data: PasswordResetRequest,
    db: Session = Depends(get_db),
):
    """Return a generic response that does not disclose account existence."""
    service = _password_reset_service()
    service.request_password_reset(db=db, identifier=data.identifier)
    return PasswordResetResponse(
        message=(
            "If an account with a verified recovery method exists, "
            "a recovery code will be sent."
        )
    )


@router.post(
    "/password-reset/confirm",
    response_model=PasswordResetResponse,
    status_code=status.HTTP_200_OK,
    responses={503: {"description": "Recovery service is not yet configured"}},
)
def confirm_password_reset(
    data: PasswordResetConfirm,
    db: Session = Depends(get_db),
):
    """Change the password only after the recovery service validates its OTP."""
    service = _password_reset_service()
    service.confirm_password_reset(
        db=db,
        identifier=data.identifier,
        code=data.code,
        new_password=data.new_password.get_secret_value(),
    )
    return PasswordResetResponse(
        message="Password updated successfully. Please log in again."
    )


class DeleteAccountRequest(BaseModel):
    """Require an explicit irreversible action and password reauthentication."""

    password: SecretStr = Field(min_length=1, max_length=128, repr=False)
    confirmation: Literal["DELETE"]


@router.delete(
    "/me",
    status_code=status.HTTP_200_OK,
    summary="Permanently delete the authenticated user's account",
    responses={
        401: {"description": "Invalid, expired, or revoked JWT"},
        403: {"description": "Incorrect account password"},
    },
)
def delete_my_account(
    data: DeleteAccountRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete only the caller's account and all its gUSo-owned data.

    Remove image blobs before classifications, then OTP rows, then the user
    so foreign keys remain satisfied. A single transaction ensures that a
    database error cannot leave a partially deleted account.

    The caller's JWT stops working because its associated User no longer
    exists. Historical DB backups and external SMS-provider logs are outside
    this app-table deletion scope.
    """
    user_id = current_user.user_id
    previously_authorized_version = current_user.auth_token_version

    try:
        # Lock the account while reauthenticating and deleting. Refresh the
        # loaded ORM state so a concurrent password reset cannot be ignored.
        user = (
            db.query(User)
            .filter(User.user_id == user_id)
            .populate_existing()
            .with_for_update()
            .one_or_none()
        )
        if user is None or user.auth_token_version != previously_authorized_version:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Your session is no longer valid. Please log in again.",
            )

        if not verify_password(data.password.get_secret_value(), user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Incorrect password. Account was not deleted.",
            )

        owned_classification_ids = select(ClassificationRecord.classification_id).where(
            ClassificationRecord.user_id == user_id
        )
        db.execute(
            delete(ClassificationImage).where(
                ClassificationImage.classification_id.in_(owned_classification_ids)
            )
        )
        db.execute(
            delete(ClassificationRecord).where(ClassificationRecord.user_id == user_id)
        )
        db.execute(delete(OtpVerification).where(OtpVerification.user_id == user_id))
        deleted = db.execute(delete(User).where(User.user_id == user_id))
        if deleted.rowcount != 1:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="The account could not be deleted. Please try again.",
            )
        db.commit()
    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unable to delete account. No changes were saved.",
        ) from exc

    return {"message": "Account permanently deleted.", "deleted": True}

# =====================================================
# DELETE ACCOUNT — AUTHENTICATED AND PASSWORD CONFIRMED
# =====================================================

import logging

from pydantic import BaseModel, ConfigDict, Field, SecretStr

from app.core.auth_dependencies import get_current_user
from app.core.security import verify_password
from app.database.models import (
    ClassificationImage,
    ClassificationRecord,
    OtpVerification,
    User,
)


_account_delete_logger = logging.getLogger(__name__)


class DeleteAccountRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    password: SecretStr = Field(
        min_length=1,
        max_length=128,
    )


@router.delete(
    "/account",
    status_code=status.HTTP_200_OK,
    summary="Permanently delete the authenticated account",
)
def delete_account(
    data: DeleteAccountRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Delete the authenticated user's account and related
    records after verifying the current password.

    All database deletions occur in one transaction.
    Never accept a target user ID from the client.
    """

    try:
        # Serialize deletion against other transactions
        # that reference this user.
        user = (
            db.query(User)
            .filter(
                User.user_id == current_user.user_id
            )
            .with_for_update()
            .one_or_none()
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is no longer available.",
            )

        # The JWT alone is not enough to delete the account.
        password = data.password.get_secret_value()

        if not verify_password(
            password,
            user.password_hash,
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Current password is incorrect.",
            )

        # Select only this user's classifications.
        classification_ids = [
            row[0]
            for row in (
                db.query(
                    ClassificationRecord.classification_id
                )
                .filter(
                    ClassificationRecord.user_id
                    == user.user_id
                )
                .all()
            )
        ]

        # 1. Delete stored image binary data first.
        if classification_ids:
            (
                db.query(ClassificationImage)
                .filter(
                    ClassificationImage.classification_id.in_(
                        classification_ids
                    )
                )
                .delete(synchronize_session=False)
            )

        # 2. Delete classification records.
        (
            db.query(ClassificationRecord)
            .filter(
                ClassificationRecord.user_id
                == user.user_id
            )
            .delete(synchronize_session=False)
        )

        # 3. Delete all OTP verification records.
        (
            db.query(OtpVerification)
            .filter(
                OtpVerification.user_id
                == user.user_id
            )
            .delete(synchronize_session=False)
        )

        # 4. Delete the account last.
        db.delete(user)

        # Commit all changes together.
        db.commit()

        # Existing JWTs are no longer authorized because
        # the account no longer exists.
        return {
            "deleted": True,
            "message": "Account deleted successfully.",
        }

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()

        _account_delete_logger.exception(
            "Account deletion transaction failed."
        )

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=(
                "Unable to delete the account. "
                "No deletion was confirmed."
            ),
        )
