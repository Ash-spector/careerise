# app/routes/exam_routes.py
from fastapi import APIRouter, HTTPException
from app.utils.database import get_profile
from app.services.exam_service import recommend_exams

router = APIRouter()

@router.get("/{user_id}")
def exams_route(user_id: str):
    # helpful logs for debugging
    print("🔍 Exam route hit for user:", user_id)

    profile = get_profile(user_id)
    print("📌 Loaded profile:", bool(profile))

    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    result = recommend_exams(profile)
    print("📌 Exam result keys:", list(result.keys()))
    return result
