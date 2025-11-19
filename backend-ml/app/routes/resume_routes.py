# app/routes/resume_routes.py
import os
from uuid import uuid4
from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from app.services.resume_service import extract_resume_data

UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "..", "uploads")
UPLOAD_DIR = os.path.abspath(UPLOAD_DIR)
os.makedirs(UPLOAD_DIR, exist_ok=True)

router = APIRouter(tags=["Resume"])

@router.post("/upload/{user_id}")
async def upload_resume(user_id: str, file: UploadFile = File(...)):
    try:
        ext = (file.filename or "").lower().split(".")[-1]
        if ext not in ["pdf", "docx"]:
            raise HTTPException(status_code=400, detail="Only PDF or DOCX allowed")

        fname = f"{uuid4().hex}.{ext}"
        fpath = os.path.join(UPLOAD_DIR, fname)
        with open(fpath, "wb") as out:
            out.write(await file.read())

        parsed = extract_resume_data(fpath)

        # minimal sanity
        if not parsed.get("skills"):
            parsed["skills"] = []

        return JSONResponse(
            content={"status": "ok", "user_id": user_id, "resume_info": parsed}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Resume parse failed: {e}")
