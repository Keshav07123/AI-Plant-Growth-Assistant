from __future__ import annotations

from pathlib import Path

from app.utils.file_loader import load_json

BACKEND_DIR = Path(__file__).resolve().parents[2]
DB_DIR = BACKEND_DIR / "db"
if not DB_DIR.exists():
    DB_DIR = BACKEND_DIR.parent / "teammate_zip_extract" / "Project Plant" / "db"
DISEASE_DB = DB_DIR / "disease_db.json"


def _to_common_name(raw_name: str) -> str:
    return " ".join(part.capitalize() for part in raw_name.replace("_", " ").split())


def _normalize(text: str) -> str:
    return "".join(ch for ch in text.lower() if ch.isalnum())


def _tokenize(text: str) -> set[str]:
    return {token for token in text.lower().replace("_", " ").split() if token}


def _plant_matches(candidate: str, plant_name: str) -> bool:
    c = candidate.strip().lower()
    p = plant_name.strip().lower()
    if not c or not p:
        return False
    return c == p or c in p or p in c


def match_disease(symptoms: list[str], plant_name: str | None = None) -> dict:
    data = load_json(DISEASE_DB)
    if not data:
        return {"error": "Disease database could not be loaded."}

    input_symptoms = {s.lower() for s in symptoms}
    best_match = None
    highest_score = 0

    for disease in data:
        disease_symptoms = {str(s).lower() for s in disease.get("symptoms", [])}
        match_count = len(input_symptoms.intersection(disease_symptoms))
        if plant_name:
            affected = [str(x) for x in disease.get("affected_plants", [])]
            if any(_plant_matches(item, plant_name) for item in affected):
                match_count += 2
        if match_count > highest_score:
            highest_score = match_count
            best_match = disease

    if not best_match or highest_score == 0:
        return {
            "disease": "No Match",
            "confidence": 0,
            "message": (
                "Symptoms do not closely match any known diseases in our system. "
                "Monitor the plant closely."
            ),
        }

    return {
        "disease": best_match.get("disease_name"),
        "disease_common_name": _to_common_name(str(best_match.get("disease_name", ""))),
        "plant_name": plant_name,
        "confidence": highest_score,
        "remedies": best_match.get("remedies", []),
        "prevention": best_match.get("prevention", []),
    }


def get_guidance_for_prediction(disease_name: str, plant_name: str | None = None) -> dict:
    data = load_json(DISEASE_DB)
    if not data:
        return {"remedies": [], "prevention": [], "disease_common_name": disease_name}

    target = _normalize(disease_name)
    best_match = None
    for item in data:
        db_name = str(item.get("disease_name", ""))
        if _normalize(db_name) == target:
            best_match = item
            break

    if best_match is None:
        for item in data:
            db_name = str(item.get("disease_name", ""))
            if target and (target in _normalize(db_name) or _normalize(db_name) in target):
                best_match = item
                break

    if best_match is None:
        # Fallback: choose closest disease by token overlap (e.g. "Late blight" -> "Early Blight").
        target_tokens = _tokenize(disease_name)
        best_score = 0
        for item in data:
            db_name = str(item.get("disease_name", ""))
            db_tokens = _tokenize(db_name)
            if not target_tokens or not db_tokens:
                continue
            score = len(target_tokens.intersection(db_tokens))
            if score > best_score:
                best_score = score
                best_match = item

    if best_match is None:
        return {"remedies": [], "prevention": [], "disease_common_name": _to_common_name(disease_name)}

    return {
        "disease_common_name": _to_common_name(str(best_match.get("disease_name", disease_name))),
        "plant_name": plant_name,
        "remedies": best_match.get("remedies", []),
        "prevention": best_match.get("prevention", []),
    }
