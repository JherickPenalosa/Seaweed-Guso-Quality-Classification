"""gUSo SMS delivery: Semaphore in production; one-account local OTP testing.

The OTP service owns code generation, hashing, expiry, and attempt limits.
This module receives an already-generated code and delivers it. A local test
prints the code ONLY in the private FastAPI console, never to the HTTP client.
"""

import hmac
import os
import re
from pathlib import Path

import requests
from dotenv import load_dotenv

from app.core.otp import OTP_EXPIRATION_MINUTES


# backend/app/services/sms_service.py -> backend/.env
load_dotenv(Path(__file__).resolve().parents[2] / ".env")
SEMAPHORE_OTP_URL = "https://api.semaphore.co/api/v4/otp"
_ACCEPTED_STATUSES = frozenset({"queued", "pending", "sent"})


def normalize_mobile_number(mobile_number: str) -> str:
    """Normalize PH phone numbers to 639XXXXXXXXX format."""
    if not isinstance(mobile_number, str):
        raise ValueError("Enter a valid Philippine mobile number.")

    digits = re.sub(r"[\s()\-]", "", mobile_number.strip())
    if digits.startswith("+"):
        digits = digits[1:]

    if re.fullmatch(r"09[0-9]{9}", digits):
        return "63" + digits[1:]
    if re.fullmatch(r"9[0-9]{9}", digits):
        return "63" + digits
    if re.fullmatch(r"639[0-9]{9}", digits):
        return digits

    raise ValueError("Enter a valid Philippine mobile number.")


def _send_local_console_otp(mobile_number: str, code: str) -> None:
    """Enable console OTP ONLY for a single development-only test number.

    WARNING: This does NOT verify phone ownership. Never run this mode on a
    public server, forwarded port, tunnel, or production deployment.
    """
    runtime_env = os.getenv("GUSO_RUNTIME_ENV", "").strip().lower()
    acknowledgment = os.getenv("GUSO_LOCAL_OTP_ACK", "").strip()
    test_phone = os.getenv("GUSO_DEV_OTP_PHONE", "").strip()

    if runtime_env != "development" or acknowledgment != "LOCAL_TEST_ONLY":
        raise RuntimeError("Local OTP requires explicit development-only settings.")
    if not test_phone:
        raise RuntimeError("Designated development test number is missing.")

    expected_number = normalize_mobile_number(test_phone)
    if not hmac.compare_digest(mobile_number, expected_number):
        raise RuntimeError("Local OTP is restricted to the designated test account.")

    # This is the only mode that reveals a code, and only to the local console.
    print("\n[gUSo LOCAL OTP TEST — NOT A DELIVERED SMS]", flush=True)
    print(f"Test verification code: {code}", flush=True)
    print("Enter this code in Swagger's /auth/otp/verify endpoint.\n", flush=True)


def _validate_semaphore_reply(reply: object, expected_number: str, expected_code: str) -> None:
    """Require provider acceptance without leaking phone/OTP into errors."""
    if not isinstance(reply, list) or len(reply) != 1 or not isinstance(reply[0], dict):
        raise RuntimeError("SMS gateway did not confirm acceptance.")

    record = reply[0]
    message_id = record.get("message_id")
    if not message_id or isinstance(message_id, bool):
        raise RuntimeError("SMS gateway did not confirm acceptance.")
    if str(record.get("status", "")).strip().lower() not in _ACCEPTED_STATUSES:
        raise RuntimeError("SMS gateway did not accept the message.")

    # A provider might encode 001234 as an integer 1234; restore leading 0s.
    returned_code = record.get("code")
    if (
        isinstance(returned_code, bool)
        or returned_code is None
        or re.fullmatch(r"[0-9]{1,6}", str(returned_code)) is None
        or str(returned_code).zfill(6) != expected_code
    ):
        raise RuntimeError("SMS gateway did not confirm the requested OTP.")

    returned_recipient = record.get("recipient")
    if returned_recipient is not None:
        try:
            actual_number = normalize_mobile_number(str(returned_recipient))
        except ValueError:
            raise RuntimeError("SMS gateway returned an invalid recipient.") from None
        if actual_number != expected_number:
            raise RuntimeError("SMS gateway returned the wrong recipient.")


def send_verification_sms(destination: str, code: str) -> None:
    """Dispatch one OTP using the explicitly selected SMS delivery mode."""
    if not isinstance(code, str) or re.fullmatch(r"[0-9]{6}", code) is None:
        raise ValueError("OTP must contain exactly six digits.")

    number = normalize_mobile_number(destination)
    provider = os.getenv("GUSO_SMS_PROVIDER", "semaphore").strip().lower()

    if provider == "local_console":
        _send_local_console_otp(number, code)
        return
    if provider != "semaphore":
        raise RuntimeError("Unsupported SMS provider configuration.")

    # Existing production path: Semaphore remains the default.
    api_key = os.getenv("SEMAPHORE_API_KEY", "").strip()
    sender_name = os.getenv("SEMAPHORE_SENDER_NAME", "").strip()
    if not api_key:
        raise RuntimeError("Semaphore API key is not configured.")

    message = (
        "Your gUSo verification code is {otp}. "
        f"Valid for {OTP_EXPIRATION_MINUTES} minutes. Do not share this code."
    )
    payload = {
        "apikey": api_key,
        "number": number,
        "message": message,
        "code": code,
    }
    if sender_name:
        payload["sendername"] = sender_name

    try:
        response = requests.post(SEMAPHORE_OTP_URL, data=payload, timeout=(5, 20))
    except requests.RequestException as exc:
        raise RuntimeError("SMS gateway connection failed.") from exc

    if not response.ok:
        # Do NOT include raw provider responses: they may contain the OTP.
        raise RuntimeError(f"SMS gateway rejected the request (HTTP {response.status_code}).")

    try:
        reply = response.json()
    except ValueError:
        raise RuntimeError("SMS gateway returned an invalid response.") from None

    _validate_semaphore_reply(reply, number, code)
    # Acceptance does not guarantee arrival on the recipient's handset.
