from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
import secrets, time, json, os
from typing import Dict
from app.utils.email_sender import send_otp_email

router = APIRouter()

# ✅ Path to local JSON database
DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "users.json")


# ✅ Utility functions
def _load_users() -> Dict[str, dict]:
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return {}


def _save_users(data: Dict[str, dict]):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)


def _make_token(user_id: str) -> str:
    return secrets.token_urlsafe(24)


# ✅ MODELS
class SignupIn(BaseModel):
    name: str
    email: EmailStr
    password: str


class LoginIn(BaseModel):
    email: EmailStr
    password: str


class SendOTP(BaseModel):
    email: EmailStr


class VerifyOTP(BaseModel):
    email: EmailStr
    otp: str


class ResetPassword(BaseModel):
    email: EmailStr
    otp: str
    new_password: str


# ✅ SIGNUP
@router.post("/signup")
async def signup(payload: SignupIn):
    users = _load_users()

    if payload.email in users:
        raise HTTPException(status_code=400, detail="User already exists")

    user_id = secrets.token_hex(8)
    users[payload.email] = {
        "id": user_id,
        "name": payload.name,
        "email": payload.email,
        "password": payload.password,
        "created_at": int(time.time()),
        "skillScore": 0,
        "completion": 0,
    }

    token = _make_token(user_id)
    users[payload.email]["token"] = token
    _save_users(users)

    return {
        "userId": user_id,
        "name": payload.name,
        "token": token,
        "skillScore": 0,
        "completion": 0,
    }


# ✅ LOGIN
@router.post("/login")
async def login(payload: LoginIn):
    users = _load_users()
    user = users.get(payload.email)

    if not user or user["password"] != payload.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = _make_token(user["id"])
    user["token"] = token
    _save_users(users)

    return {
        "userId": user["id"],
        "name": user["name"],
        "token": token,
        "skillScore": user["skillScore"],
        "completion": user["completion"],
    }


# ✅ SEND OTP (Forgot Password)
@router.post("/send-otp")
async def send_otp(payload: SendOTP):
    users = _load_users()
    user = users.get(payload.email)

    # Security: always respond success (even if email not found)
    if not user:
        return {"success": True, "message": "If account exists, OTP sent"}

    otp = str(secrets.randbelow(900000) + 100000)
    users[payload.email]["otp"] = otp
    users[payload.email]["otp_ts"] = int(time.time())
    _save_users(users)

    await send_otp_email(payload.email, otp)

    return {"success": True, "message": "OTP sent successfully"}


# ✅ VERIFY OTP
@router.post("/verify-otp")
async def verify_otp(payload: VerifyOTP):
    users = _load_users()
    user = users.get(payload.email)

    if not user or "otp" not in user:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if int(time.time()) - user["otp_ts"] > 300:
        raise HTTPException(status_code=400, detail="OTP expired")

    if payload.otp != user["otp"]:
        raise HTTPException(status_code=400, detail="Incorrect OTP")

    # OTP verified, keep OTP for password reset if needed
    return {
        "success": True,
        "message": "OTP verified successfully",
    }


# ✅ RESET PASSWORD (new)
@router.post("/reset-password")
async def reset_password(payload: ResetPassword):
    users = _load_users()
    user = users.get(payload.email)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Validate OTP
    if "otp" not in user or payload.otp != user["otp"]:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    # ✅ Update password and clean up OTP
    user["password"] = payload.new_password
    user.pop("otp", None)
    user.pop("otp_ts", None)
    _save_users(users)

    return {"success": True, "message": "Password reset successful"}
