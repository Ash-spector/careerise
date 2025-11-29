# app/utils/email_sender.py

import os
import httpx
from fastapi import HTTPException

# ✅ Load API key from environment variable (correct)
RESEND_API_KEY = os.getenv("re_hjdRkSHs_9uxPJDnfwPvbF6EQWUQ2VtsA")

async def send_otp_email(email: str, otp: str):
    if not RESEND_API_KEY:
        raise HTTPException(status_code=500, detail="Email service not configured (missing API key)")

    url = "https://api.resend.com/emails"

    html = f"""
    <div style="font-family: Arial, sans-serif;">
      <h2>Careerise OTP Verification</h2>
      <p>Your OTP code is:</p>
      <h1 style="letter-spacing:4px">{otp}</h1>
      <p>This code is valid for 5 minutes.</p>
    </div>
    """

    payload = {
        "from": "Careerise <onboarding@resend.dev>",
        "to": email,
        "subject": "Your Careerise OTP",
        "html": html,
    }

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            res = await client.post(
                url,
                json=payload,
                headers={"Authorization": f"Bearer {RESEND_API_KEY}"}
            )

        if res.status_code >= 400:
            print("❌ Resend API ERROR:", res.text)
            raise HTTPException(status_code=500, detail=f"Resend error: {res.text}")

        print("📨 OTP sent via Resend to:", email)
        return True

    except Exception as e:
        print("❌ Email send error:", e)
        raise HTTPException(status_code=500, detail=f"Email sending failed: {e}")
