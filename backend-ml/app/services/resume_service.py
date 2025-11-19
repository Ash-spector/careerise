# app/services/resume_service.py
import re
import os
from typing import List, Dict

# PDF + DOCX text extraction
def _read_pdf(path: str) -> str:
    import pdfplumber
    text_chunks = []
    with pdfplumber.open(path) as pdf:
        for p in pdf.pages:
            text_chunks.append(p.extract_text() or "")
    return "\n".join(text_chunks)

def _read_docx(path: str) -> str:
    # works well for simple extraction
    import docx2txt
    return docx2txt.process(path) or ""

EMAIL_RE = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
PHONE_RE = re.compile(r"(\+?\d[\d\s\-]{7,}\d)")
# crude “name” guess: first non-empty line before email
def _guess_name(text: str, email: str) -> str:
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    if not lines:
        return ""
    if email:
        for i, l in enumerate(lines):
            if email in l:
                # try previous 1-2 lines
                for j in range(max(0, i-2), i):
                    cand = lines[j]
                    if 2 <= len(cand.split()) <= 4 and cand[0].isalpha():
                        return cand
    # else first line as fallback
    return lines[0] if len(lines[0].split()) <= 5 else ""

# a seed skills dictionary (extend as needed)
SKILL_BANK = {
    # programming
    "python","java","javascript","typescript","c","c++","dart","flutter","kotlin","swift",
    # data
    "sql","mysql","postgresql","mongodb","pandas","numpy","matplotlib","scikit-learn","tensorflow","pytorch",
    # web/app
    "react","node","express","django","flask","fastapi","html","css","rest api","graphql",
    # cloud/devops
    "docker","kubernetes","aws","gcp","azure","git","ci/cd","linux",
    # soft skills
    "communication","leadership","teamwork","problem solving","time management",
}

# normalize text for matching
def _normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s.lower().strip())

def _extract_skills(text: str) -> List[str]:
    t = _normalize(text)
    found = set()
    for sk in SKILL_BANK:
        if sk in t:
            found.add(sk.title() if " " not in sk else " ".join(w.title() for w in sk.split()))
    # also try bullet lines like "Skills: Python, SQL, ... "
    m = re.findall(r"skills?[:\-]\s*(.+)", text, flags=re.IGNORECASE)
    for block in m:
        for token in re.split(r"[,\|/•·]", block):
            tok = _normalize(token)
            if not tok:
                continue
            for sk in SKILL_BANK:
                if sk in tok:
                    found.add(sk.title() if " " not in sk else " ".join(w.title() for w in sk.split()))
    return sorted(found)

def extract_resume_data(path: str) -> Dict:
    ext = path.lower().split(".")[-1]
    if ext == "pdf":
        text = _read_pdf(path)
    elif ext == "docx":
        text = _read_docx(path)
    else:
        raise ValueError("Unsupported file type")

    email = EMAIL_RE.search(text)
    email = email.group(0) if email else ""

    phone = PHONE_RE.search(text)
    phone = phone.group(0) if phone else ""

    skills = _extract_skills(text)
    name = _guess_name(text, email)

    # try education hint
    edu = ""
    edu_match = re.search(r"(B\.?Tech|B\.?E\.?|BSc|MSc|MCA|MBA|Diploma).{0,40}(CS|IT|Computer|Electronics)?",
                          text, flags=re.IGNORECASE)
    if edu_match:
        edu = edu_match.group(0).strip()

    return {
        "name": name or "Candidate",
        "email": email,
        "phone": phone,
        "skills": skills,
        "education": edu,
        "raw_length": len(text),
    }
