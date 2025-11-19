# app/main.py
import os, sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.append(BASE_DIR)

from app.routes.auth_routes import router as auth_router
from app.routes.resume_routes import router as resume_router
from app.routes.profile_routes import router as profile_router
from app.routes.recommendation_routes import router as recommendation_router
from app.routes.exam_routes import router as exam_router

app = FastAPI(
    title="Careerise Backend",
    version="2.0.0",
    description="Careerise backend — Career, Exam & Internship recommendations"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# register routers
app.include_router(auth_router, prefix="/auth", tags=["Auth"])
app.include_router(resume_router, prefix="/resume", tags=["Resume"])
app.include_router(profile_router, prefix="/profile", tags=["Profile"])
app.include_router(recommendation_router, prefix="/recommend", tags=["Recommendations"])

# **Register exam_router under both preferred paths**
app.include_router(exam_router, prefix="/exams", tags=["Exams"])                # -> /exams/{user_id}
app.include_router(exam_router, prefix="/recommend/exams", tags=["Exams"])     # -> /recommend/exams/{user_id}

@app.get("/")
def root():
    return {"message": "Careerise Backend Running ✅"}
