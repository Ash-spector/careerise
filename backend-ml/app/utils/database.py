# app/utils/database.py
import json, os, threading
from typing import Any, Dict

# Separate files for clarity
USER_DB = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "users.json"))
PROFILE_DB = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data", "profiles.json"))
_lock = threading.Lock()

def _read(path: str) -> Dict[str, Any]:
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        try:
            return json.load(f)
        except Exception:
            return {}

def _write(path: str, data: Dict[str, Any]) -> None:
    tmp = path + ".tmp"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    os.replace(tmp, path)

# ✅ USER DATA (for login/signup)
def get_user(email: str) -> Dict[str, Any] | None:
    with _lock:
        db = _read(USER_DB)
        return db.get(email)

def upsert_user(email: str, doc: Dict[str, Any]) -> None:
    with _lock:
        db = _read(USER_DB)
        db[email] = doc
        _write(USER_DB, db)

# ✅ PROFILE DATA (for skills, academic, resume info)
def get_profile(user_id: str) -> Dict[str, Any] | None:
    with _lock:
        db = _read(PROFILE_DB)
        return db.get(user_id)

def upsert_profile(user_id: str, doc: Dict[str, Any]) -> None:
    with _lock:
        db = _read(PROFILE_DB)
        db[user_id] = doc
        _write(PROFILE_DB, db)
