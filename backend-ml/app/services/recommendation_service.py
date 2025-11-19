# app/services/recommendation_service.py
from typing import List, Dict

# very simple mapping; expand for your needs
CAREER_CLUSTERS = {
    "Data Science": {"skills": {"Python","Pandas","Numpy","SQL","Scikit-Learn"}},
    "Machine Learning Engineer": {"skills": {"Python","Tensorflow","Pytorch","Numpy","Pandas"}},
    "Backend Developer": {"skills": {"Python","Django","Flask","Fastapi","SQL","Docker"}},
    "Frontend Developer": {"skills": {"JavaScript","React","HTML","CSS"}},
    "Mobile Developer": {"skills": {"Dart","Flutter","Kotlin","Swift"}},
    "Cloud/DevOps Engineer": {"skills": {"Docker","Kubernetes","AWS","GCP","Azure","Linux","CI/Cd"}},
}

EXAMS = [
    # govt (India-centric placeholders; tweak as needed)
    {"name":"GATE-CS", "type":"govt", "tags":["CS","Programming","Math"], "eligible_skills":["Python","Data Structures","Algorithms"]},
    {"name":"SSC CGL", "type":"govt", "tags":["General"], "eligible_skills":[]},
    {"name":"IBPS PO", "type":"govt", "tags":["General"], "eligible_skills":[]},
    # private / certs / internships
    {"name":"TCS NQT", "type":"private", "tags":["Aptitude","Programming"], "eligible_skills":["Java","Python","SQL"]},
    {"name":"Google Cloud Associate", "type":"private", "tags":["Cloud"], "eligible_skills":["GCP","Docker","Kubernetes"]},
    {"name":"AWS Cloud Practitioner", "type":"private", "tags":["Cloud"], "eligible_skills":["AWS"]},
    {"name":"Meta Front-End Cert", "type":"private", "tags":["Frontend"], "eligible_skills":["React","JavaScript","HTML","CSS"]},
]

def recommend_careers(user_skills: List[str], interests: List[Dict], preferences: Dict) -> List[Dict]:
    skills_set = {s.title() for s in user_skills}
    scored = []
    for career, cfg in CAREER_CLUSTERS.items():
        overlap = len(skills_set & {x.title() for x in cfg["skills"]})
        boost = 0
        if preferences.get("workEnvironment","").lower() == "remote" and career in ["Frontend Developer","Backend Developer","Mobile Developer"]:
            boost += 1
        scored.append({"career": career, "score": overlap + boost})
    scored.sort(key=lambda x: x["score"], reverse=True)
    return [c for c in scored if c["score"] > 0][:5]

def recommend_exams(user_skills: List[str], academic: Dict, preferences: Dict) -> List[Dict]:
    skills = {s.title() for s in user_skills}
    out = []
    for exam in EXAMS:
        req = set([x.title() for x in exam["eligible_skills"]])
        if not req or (req & skills):
            out.append(exam)
    # quick prioritization: cloud if cloud-ish, programming if dev-ish
    out.sort(key=lambda e: 0 if set([x.title() for x in e["eligible_skills"]]) & skills else 1)
    return out[:6]
