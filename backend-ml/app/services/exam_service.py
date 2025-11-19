# app/services/exam_service.py

from typing import Dict, List
import re

EXAM_DATABASE = [
    {
        "title": "GATE (CS)",
        "type": "Government",
        "eligibility": "btech engineering programming data structures algorithms",
        "apply_link": "https://gate.iitkgp.ac.in",
    },
    {
        "title": "SSC CGL",
        "type": "Government",
        "eligibility": "graduate reasoning maths english general awareness",
        "apply_link": "https://ssc.nic.in",
    },
    {
        "title": "ISRO Scientist",
        "type": "Government",
        "eligibility": "engineering programming electronics computer science",
        "apply_link": "https://www.isro.gov.in",
    },
    {
        "title": "TCS NQT",
        "type": "Private",
        "eligibility": "graduate aptitude programming communication",
        "apply_link": "https://www.tcs.com",
    },
    {
        "title": "Infosys InfyTQ",
        "type": "Private",
        "eligibility": "java python software development",
        "apply_link": "https://infytq.onwingspan.com",
    },
    {
        "title": "Google Data Internship",
        "type": "Internship",
        "eligibility": "python sql data science machine learning",
        "apply_link": "https://careers.google.com",
    },
]


def recommend_exams(profile: Dict):
    """
    Light AI-based exam matcher using keyword overlap from:
    - academic.level
    - skills (manual)
    - resumeInfo.skills
    """

    # Get academic
    education = profile.get("academic", {}).get("level", "").lower()

    # Extract skills (manual skills + resume skills)
    skills = []

    # manual profile builder skills
    for s in profile.get("skills", []):
        if isinstance(s, dict):
            skills.append(s.get("name", "").lower())

    # resume extracted skills
    resume_skills = profile.get("resumeInfo", {}).get("skills", [])
    skills += [s.lower() for s in resume_skills]

    combined_text = education + " " + " ".join(skills)

    # if no data, ask user to complete profile
    if not combined_text.strip():
        return {
            "profile_incomplete": True,
            "message": "Add your skills or upload resume for exam recommendations.",
            "recommended_exams": [],
        }

    results = []

    for exam in EXAM_DATABASE:
        score = 0
        eligibility_words = exam["eligibility"].split()

        for w in eligibility_words:
            if w in combined_text:
                score += 1

        results.append({
            "title": exam["title"],
            "type": exam["type"],
            "apply_link": exam["apply_link"],
            "eligibility_score": score * 20,  # convert matching to % similarity
        })

    # sort by best match
    results.sort(key=lambda x: x["eligibility_score"], reverse=True)

    return {
        "profile_incomplete": False,
        "recommended_exams": results[:6]
    }
