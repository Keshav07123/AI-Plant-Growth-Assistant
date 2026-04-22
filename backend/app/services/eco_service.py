from __future__ import annotations

from pathlib import Path

from app.utils.file_loader import load_json

BACKEND_DIR = Path(__file__).resolve().parents[2]
DB_DIR = BACKEND_DIR / "db"
if not DB_DIR.exists():
    DB_DIR = BACKEND_DIR.parent / "teammate_zip_extract" / "Project Plant" / "db"
ECO_DB = DB_DIR / "eco_db.json"


def get_eco_tasks(waste_type: str) -> dict:
    data = load_json(ECO_DB)
    if not data:
        return {"error": "Eco database could not be loaded."}

    waste_key = waste_type.lower().replace(" ", "_")
    if waste_key in data:
        return {"waste_type": waste_type, "use_cases": data[waste_key]}
    return {"error": f"No tasks found for waste type '{waste_type}'."}
