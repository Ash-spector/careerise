from fastapi import APIRouter, HTTPException
import os, json

router = APIRouter(tags=["Recommendations"])

PROFILE_PATH = os.path.join("app", "data", "profiles.json")

def load_profiles():
    if not os.path.exists(PROFILE_PATH):
        return {}
    with open(PROFILE_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


# ================================================================
#  🚀 ADVANCED CAREER DATABASE (AI-LIKE RECOMMENDATIONS)
# ================================================================
CAREER_DB = {
    "Data Analyst": {
        "skills": ["python", "sql", "excel", "pandas"],
        "study_level": "Beginner",
        "course_link": "https://www.coursera.org/professional-certificates/google-data-analytics",
        "playlist_link": "https://www.youtube.com/playlist?list=PLh6T5unK3Jma2PbgM3N3aR6Vrn956SpaV",
        "roadmap": "Master SQL, Excel, Python, Pandas. Then build dashboards using PowerBI/Tableau."
    },

    "Machine Learning Engineer": {
        "skills": ["python", "machine learning", "tensorflow", "pytorch"],
        "study_level": "Intermediate",
        "course_link": "https://www.coursera.org/learn/machine-learning",
        "playlist_link": "https://www.youtube.com/playlist?list=PLZoTAELRMXVN_zzK830t6n3t1Qd23IcQZ",
        "roadmap": "Start with ML basics → Linear Regression → Neural Networks → Deep Learning → Deploy models."
    },

    "Frontend Developer": {
        "skills": ["html", "css", "javascript", "react"],
        "study_level": "Beginner",
        "course_link": "https://www.udemy.com/course/the-complete-web-developer-zero-to-mastery/",
        "playlist_link": "https://www.youtube.com/playlist?list=PLu0W_9lII9aiL0kysYk5-wFjvgLQ1QYxH",
        "roadmap": "HTML → CSS → JavaScript → React → Responsive design → Build portfolio projects."
    },

    "Backend Developer": {
        "skills": ["python", "django", "flask", "sql", "api"],
        "study_level": "Intermediate",
        "course_link": "https://www.udemy.com/course/python-django-the-practical-guide/",
        "playlist_link": "https://www.youtube.com/playlist?list=PLu0W_9lII9ah7DDtYtflgwMwpT3xmjXY9",
        "roadmap": "Learn APIs, Databases, Authentication, Deployment. Build real-world REST APIs."
    },

    "AI Engineer": {
        "skills": ["python", "machine learning", "data science"],
        "study_level": "Advanced",
        "course_link": "https://www.deeplearning.ai/",
        "playlist_link": "https://www.youtube.com/playlist?list=PLh6T5unK3JmYpQn1nO3MHaiA0oDBk8Qni",
        "roadmap": "Deep Learning, NLP, Transformers, Model training, model optimization."
    }
}
# ================================================================



# ================================================================
#  🚀 CAREER RECOMMENDATIONS API
# ================================================================
@router.get("/careers/{user_id}")
def recommend_careers(user_id: str):
    profiles = load_profiles()
    profile = profiles.get(user_id)

    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    # 📌 Collect all user skills
    user_skills = []

    # Manual skills (profile builder)
    for s in profile.get("skills", []):
        if isinstance(s, dict):
            user_skills.append(s.get("name", "").lower())

    # Resume extracted skills
    resume_skills = profile.get("resumeInfo", {}).get("skills", [])
    user_skills += [s.lower() for s in resume_skills]

    if not user_skills:
        return {
            "message": "Add more skills or upload resume",
            "careers": []
        }

    results = []

    for career, data in CAREER_DB.items():
        required = [x.lower() for x in data["skills"]]
        overlap = len([s for s in required if s in user_skills])  # skill matching

        if overlap > 0:
            results.append({
                "role": career,
                "matchingScore": overlap * 20,
                "skillsRequired": data["skills"],
                "study_level": data["study_level"],
                "course_link": data["course_link"],
                "playlist_link": data["playlist_link"],
                "roadmap": data["roadmap"]
            })

    return results
