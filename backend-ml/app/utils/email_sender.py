# app/utils/email_sender.py

from fastapi_mail import FastMail, MessageSchema, MessageType
from app.email_config import email_config
from fastapi import HTTPException

async def send_otp_email(email: str, otp: str):
    """
    Sends a 6-digit OTP to the provided email using Gmail SMTP.
    Requires proper App Password configured in .env.
    """

    subject = "Your Careerise OTP Verification Code"

    # ✅ Beautiful HTML email template
    html_content = f"""
    <div style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
        <div style="max-width: 500px; margin: auto; background: #fff; padding: 20px; border-radius: 10px;">
            <h2 style="color: #7B3EFF; text-align: center;">Careerise Verification Code</h2>
            <p style="font-size: 16px; color: #333;">
                Hello 👋,<br><br>
                Here’s your one-time password (OTP) to verify your Careerise account:
            </p>
            <div style="text-align: center; margin: 20px 0;">
                <h1 style="letter-spacing: 4px; color: #7B3EFF;">{otp}</h1>
            </div>
            <p style="font-size: 14px; color: #555;">
                ⚠️ This OTP is valid for <strong>5 minutes</strong>. Please don’t share it with anyone.
            </p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="text-align: center; font-size: 13px; color: #777;">
                © 2025 Careerise — AI Career & Exam Insights Platform
            </p>
        </div>
    </div>
    """

    # ✅ Compose the message
    message = MessageSchema(
        subject=subject,
        recipients=[email],
        body=html_content,
        subtype=MessageType.html,
    )

    try:
        fm = FastMail(email_config)
        await fm.send_message(message)
        print(f"✅ OTP email sent successfully to {email}")
        return {"status": "sent"}

    except Exception as e:
        # ✅ Print and raise detailed error
        print(f"❌ Failed to send OTP email to {email}: {e}")
        raise HTTPException(status_code=500, detail=f"Email sending failed: {e}")
