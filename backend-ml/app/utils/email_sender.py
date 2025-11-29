# app/utils/email_sender.py

import os
import httpx
from fastapi import HTTPException

RESEND_API_KEY = os.getenv("re_hjdRkSHs_9uxPJDnfwPvbF6EQWUQ2VtsA")

async def send_otp_email(email: str, otp: str):
    if not RESEND_API_KEY:
        raise HTTPException(status_code=500, detail="Missing RESEND_API_KEY")

    url = "https://api.resend.com/emails"

    html = f"""
    <p>Your Careerise OTP is:</p>
    <h2>{otp}</h2>
    <p>Valid for 5 minutes.</p>
    """

    payload = {
        "from": "Acme <onboarding@resend.dev>",    # ALWAYS valid
        "to": [email],                             # MUST be a list
        "subject": "Your Careerise OTP",
        "html": html
    }

    headers = {
        "Authorization": f"Bearer {RESEND_API_KEY}",
        "Content-Type": "application/json"
    }

    try:
        async with httpx.AsyncClient(timeout=20.0) as client:
            res = await client.post(url, json=payload, headers=headers)

        print("📨 RESEND RESPONSE:", res.text)

        if res.status_code >= 400:
            raise HTTPException(status_code=500, detail=f"Resend error: {res.text}")

        print(f"📨 OTP sent successfully to {email}")
        return True

    except Exception as e:
        print("❌ Email sending failed:", e)
        raise HTTPException(status_code=500, detail=str(e))
