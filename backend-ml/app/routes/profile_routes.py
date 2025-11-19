# app/routes/profile_routes.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from app.utils.database import get_profile, upsert_profile  # ✅ updated imports

router = APIRouter(tags=["Profile"])

# ✅ Data Models
class Skill(BaseModel):
    name: str
    type: Optional[str] = None
    level: Optional[str] = None

class Academic(BaseModel):
    level: Optional[str] = ""
    field: Optional[str] = ""
    gpa: Optional[str] = ""
    achievements: List[Any] = []

class Preferences(BaseModel):
    workEnvironment: Optional[str] = ""
    arrangement: Optional[str] = ""
    companySize: Optional[str] = ""

class ResumeInfo(BaseModel):
    name: Optional[str] = ""
    email: Optional[str] = ""
    phone: Optional[str] = ""
    skills: List[str] = []
    education: Optional[str] = ""

class ProfilePayload(BaseModel):
    userId: str
    name: Optional[str] = ""
    email: Optional[str] = ""
    skills: List[Skill] = []
    academic: Optional[Academic] = Academic()
    interests: List[Dict[str, Any]] = []
    preferences: Optional[Preferences] = Preferences()
    profileCompletion: int = 0
    resumeInfo: Optional[ResumeInfo] = ResumeInfo()


# ✅ Fetch User Profile (used by Flutter to pre-fill profile fields)
@router.get("/{user_id}")
def get_profile_route(user_id: str):
    try:
        doc = get_profile(user_id)
        if not doc:
            return {"message": "Profile not found", "profile": {}}
        return doc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch profile: {e}")


# ✅ Save or Update Profile (called from Flutter Save button)
@router.post("/save")
def save_profile(payload: ProfilePayload):
    try:
        # Convert payload to dictionary for saving
        profile_data = payload.model_dump()

        # Save/Update profile in profiles.json
        upsert_profile(payload.userId, profile_data)

        return {"status": "ok", "message": "Profile saved successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save profile: {e}")


# ✅ Optional Debug Route (to verify backend data)
@router.get("/debug/all")
def debug_all_profiles():
    """Quick debug route to view all profiles (for testing only)"""
    import os, json
    DATA_PATH = os.path.join("app", "data", "profiles.json")
    if not os.path.exists(DATA_PATH):
        return {"message": "No profiles.json found"}
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        return json.load(f)
