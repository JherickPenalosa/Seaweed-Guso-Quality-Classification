"""Deliver gUSo OTPs via Gmail SMTP, Brevo, or safe local testing.

This module only delivers codes. OTP creation, hashing, expiry, rate limits,
and verification belong to the existing FastAPI OTP services.

Gmail (dedicated project email):
    GUSO_EMAIL_PROVIDER=gmail
    GUSO_GMAIL_ADDRESS=<your project Gmail address>
    GUSO_GMAIL_APP_PASSWORD=<Google App Password, not account password>
    GUSO_EMAIL_SENDER_NAME=gUSo

Brevo (existing option):
    GUSO_EMAIL_PROVIDER=brevo
    BREVO_API_KEY=<Brevo API key>
    BREVO_SENDER_EMAIL=<verified Brevo sender>
    BREVO_SENDER_NAME=gUSo

Local testing (no actual email is sent):
    GUSO_EMAIL_PROVIDER=local_console
    GUSO_RUNTIME_ENV=development
    GUSO_LOCAL_EMAIL_OTP_ACK=LOCAL_EMAIL_TEST_ONLY
    GUSO_DEV_OTP_EMAIL=<one test email address you control>

Never put credentials in frontend code, Git, screenshots, or logs.
"""

import os
import re
import smtplib
import ssl
from email.message import EmailMessage
from email.utils import formataddr
from pathlib import Path

import requests
from dotenv import load_dotenv


load_dotenv(Path(__file__).resolve().parents[2] / ".env")

BREVO_SEND_URL = "https://api.brevo.com/v3/smtp/email"
GMAIL_SMTP_HOST = "smtp.gmail.com"
GMAIL_SMTP_PORT = 465


class EmailDeliveryError(RuntimeError):
    """Raised when email delivery cannot be confirmed by the sender."""


def normalize_email_address(address: str) -> str:
    """Validate an ordinary email address; registration also uses EmailStr."""
    if not isinstance(address, str):
        raise ValueError("Invalid email address.")

    value = address.strip().lower()
    if not value or len(value) > 254 or any(c.isspace() for c in value):
        raise ValueError("Invalid email address.")

    parts = value.split("@")
    if len(parts) != 2:
        raise ValueError("Invalid email address.")
    local, domain = parts

    if (
        not local
        or len(local) > 64
        or local.startswith(".")
        or local.endswith(".")
        or ".." in local
        or not re.fullmatch(r"[a-z0-9!#$%&'*+/=?^_`{|}~.\-]+", local)
    ):
        raise ValueError("Invalid email address.")

    labels = domain.split(".")
    if len(labels) < 2 or len(labels[-1]) < 2:
        raise ValueError("Invalid email address.")
    if not all(
        re.fullmatch(r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?", label)
        for label in labels
    ):
        raise ValueError("Invalid email address.")
    return value


def _validate_code(code: str) -> None:
    if not isinstance(code, str) or not re.fullmatch(r"[0-9]{6}", code):
        raise ValueError("OTP must contain exactly six digits.")


def _message_for(code: str, purpose: str) -> tuple[str, str]:
    if purpose == "email_verification":
        return (
            "Verify your gUSo email",
            f"Your gUSo email verification code is {code}.\n\n"
            "This code expires in 5 minutes. Do not share it.\n\n"
            "If you did not create a gUSo account, ignore this message.",
        )
    if purpose == "password_reset":
        return (
            "Reset your gUSo password",
            f"Your gUSo password recovery code is {code}.\n\n"
            "This code expires in 5 minutes. Do not share it.\n\n"
            "If you did not request a password reset, ignore this message.",
        )
    raise ValueError("Unsupported email OTP purpose.")


def _sender_name(value: str) -> str:
    name = value.strip()
    if not name or len(name) > 120 or "\n" in name or "\r" in name:
        raise EmailDeliveryError("Email sender name is invalid.")
    return name


def _send_gmail(recipient: str, subject: str, message: str) -> None:
    address_raw = os.getenv("GUSO_GMAIL_ADDRESS", "").strip()
    app_password = "".join(os.getenv("GUSO_GMAIL_APP_PASSWORD", "").split())
    sender_name = _sender_name(os.getenv("GUSO_EMAIL_SENDER_NAME", "gUSo"))

    if not address_raw or not app_password:
        raise EmailDeliveryError("Gmail email delivery is not configured.")
    try:
        sender = normalize_email_address(address_raw)
    except ValueError as exc:
        raise EmailDeliveryError("Gmail sender address is invalid.") from exc

    if not sender.endswith("@gmail.com"):
        raise EmailDeliveryError("Gmail sender must be a dedicated Gmail address.")

    email = EmailMessage()
    email["From"] = formataddr((sender_name, sender))
    email["To"] = recipient
    email["Subject"] = subject
    email.set_content(message)

    try:
        with smtplib.SMTP_SSL(
            GMAIL_SMTP_HOST,
            GMAIL_SMTP_PORT,
            context=ssl.create_default_context(),
            timeout=20,
        ) as smtp:
            smtp.login(sender, app_password)
            refused = smtp.send_message(email)
            if refused:
                raise EmailDeliveryError("Gmail SMTP did not accept the recipient.")
    except smtplib.SMTPAuthenticationError as exc:
        raise EmailDeliveryError(
            "Gmail authentication failed. Check the Gmail address and App Password."
        ) from exc
    except EmailDeliveryError:
        raise
    except (smtplib.SMTPException, OSError) as exc:
        raise EmailDeliveryError("Unable to send email through Gmail SMTP.") from exc


def _send_brevo(recipient: str, subject: str, message: str) -> None:
    api_key = os.getenv("BREVO_API_KEY", "").strip()
    sender_raw = os.getenv("BREVO_SENDER_EMAIL", "").strip()
    sender_name = _sender_name(os.getenv("BREVO_SENDER_NAME", "gUSo"))

    if not api_key or not sender_raw:
        raise EmailDeliveryError("Brevo email delivery is not configured.")
    try:
        sender = normalize_email_address(sender_raw)
    except ValueError as exc:
        raise EmailDeliveryError("Brevo sender email is invalid.") from exc

    payload = {
        "sender": {"email": sender, "name": sender_name},
        "to": [{"email": recipient}],
        "subject": subject,
        "textContent": message,
    }
    try:
        response = requests.post(
            BREVO_SEND_URL,
            headers={
                "api-key": api_key,
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            json=payload,
            timeout=(5, 20),
        )
    except requests.RequestException as exc:
        raise EmailDeliveryError("Email provider connection failed.") from exc

    if response.status_code != 201:
        raise EmailDeliveryError(
            f"Email provider rejected the message (HTTP {response.status_code})."
        )
    try:
        result = response.json()
    except ValueError as exc:
        raise EmailDeliveryError("Email provider response was invalid.") from exc
    if (
        not isinstance(result, dict)
        or not isinstance(result.get("messageId"), str)
        or not result["messageId"]
    ):
        raise EmailDeliveryError("Email provider did not confirm acceptance.")


def send_email_otp(destination: str, code: str, *, purpose: str) -> None:
    """Send an OTP. Returning means sender acceptance, not inbox receipt."""
    recipient = normalize_email_address(destination)
    _validate_code(code)
    subject, message = _message_for(code, purpose)
    provider = os.getenv("GUSO_EMAIL_PROVIDER", "brevo").strip().lower()

    if provider == "local_console":
        try:
            matches_test_address = (
                normalize_email_address(os.getenv("GUSO_DEV_OTP_EMAIL", ""))
                == recipient
            )
        except ValueError:
            matches_test_address = False
        allowed = (
            os.getenv("GUSO_RUNTIME_ENV", "").strip().lower() == "development"
            and os.getenv("GUSO_LOCAL_EMAIL_OTP_ACK", "").strip()
            == "LOCAL_EMAIL_TEST_ONLY"
            and matches_test_address
        )
        if not allowed:
            raise EmailDeliveryError(
                "Local email testing is not enabled for this test address."
            )
        print("\n[gUSo LOCAL EMAIL OTP TEST — NOT EMAIL DELIVERY]", flush=True)
        print("Test email OTP: " + code, flush=True)
        print("Enter this code only in your private local test session.\n", flush=True)
        return

    if provider == "gmail":
        _send_gmail(recipient, subject, message)
        return
    if provider == "brevo":
        _send_brevo(recipient, subject, message)
        return
    raise EmailDeliveryError("Unsupported email delivery provider.")


def send_verification_email(destination: str, code: str) -> None:
    """Callback to use later with the email registration OTP flow."""
    send_email_otp(destination, code, purpose="email_verification")


def send_password_reset_email(destination: str, code: str) -> None:
    """Callback to use later for recovery through a verified email."""
    send_email_otp(destination, code, purpose="password_reset")
