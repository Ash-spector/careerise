# app/routes/auth_routes.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
import secrets, time, json, os
from typing import Dict
from app.utils.email_sender import send_otp_email

router = APIRouter()

# Path to users.json at repo root (adjust if different)
DATA_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "users.json"))

def _load_users() -> Dict[str, dict]:
    if not os.path.exists(DATA_FILE):
        return {}
    try:
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}

def _save_users(data: Dict[str, dict]):
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

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

# ---------- SIGNUP (no OTP) ----------
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
        "created_at": int(time.time())
    }
    _save_users(users)
    return {"success": True, "userId": user_id, "name": payload.name}

# ---------- LOGIN ----------
@router.post("/login")
async def login(payload: LoginIn):
    users = _load_users()
    user = users.get(payload.email)
    if not user or user.get("password") != payload.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"success": True, "userId": user["id"], "name": user.get("name", "")}

# ---------- SEND OTP (forgot) ----------
@router.post("/send-otp")
async def send_otp(payload: SendOTP):
    users = _load_users()
    user = users.get(payload.email)
    # Always respond success to avoid user enumeration
    if not user:
        return {"success": True, "message": "If account exists, OTP sent"}

    otp = str(secrets.randbelow(900000) + 100000)
    user["otp"] = otp
    user["otp_ts"] = int(time.time())
    _save_users(users)

    # send email (may raise HTTPException)
    await send_otp_email(payload.email, otp)
    return {"success": True, "message": "OTP sent successfully"}

# ---------- VERIFY OTP ----------
@router.post("/verify-otp")
async def verify_otp(payload: VerifyOTP):
    users = _load_users()
    user = users.get(payload.email)
    if not user or "otp" not in user:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    if int(time.time()) - int(user.get("otp_ts", 0)) > 300:
        raise HTTPException(status_code=400, detail="OTP expired")
    if payload.otp != user.get("otp"):
        raise HTTPException(status_code=400, detail="Incorrect OTP")
    return {"success": True, "message": "OTP verified"}

# ---------- RESET PASSWORD ----------
@router.post("/reset-password")
async def reset_password(payload: ResetPassword):
    users = _load_users()
    user = users.get(payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if "otp" not in user or payload.otp != user.get("otp"):
        raise HTTPException(status_code=400, detail="Invalid OTP")
    if int(time.time()) - int(user.get("otp_ts", 0)) > 300:
        raise HTTPException(status_code=400, detail="OTP expired")
    # update password
    user["password"] = payload.new_password
    user.pop("otp", None)
    user.pop("otp_ts", None)
    _save_users(users)
    return {"success": True, "message": "Password reset successful"}
