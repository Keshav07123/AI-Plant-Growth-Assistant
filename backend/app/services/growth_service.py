from __future__ import annotations

from pathlib import Path

from app.utils.file_loader import load_json

BACKEND_DIR = Path(__file__).resolve().parents[2]
DB_DIR = BACKEND_DIR / "db"
if not DB_DIR.exists():
    DB_DIR = BACKEND_DIR.parent / "teammate_zip_extract" / "Project Plant" / "db"
PLANT_DB_1 = DB_DIR / "plant_dataset.json"
PLANT_DB_2 = DB_DIR / "plant_dataset_part2.json"


def _normalize_name(value: str) -> str:
    return "".join(ch for ch in value.lower() if ch.isalnum() or ch.isspace()).strip()


def _load_merged_plants() -> dict:
    data1 = load_json(PLANT_DB_1) or {"plants": {}}
    data2 = load_json(PLANT_DB_2) or {"plants": {}}
    return {**data1.get("plants", {}), **data2.get("plants", {})}


def list_all_plant_names() -> list[str]:
    merged_plants = _load_merged_plants()
    names: set[str] = set()
    for key, info in merged_plants.items():
        common_name = str(info.get("common_name", "")).strip()
        if common_name:
            names.add(common_name)
        else:
            names.add(key.replace("_", " ").strip())
    return sorted(names)


def list_all_plants() -> list[dict[str, str]]:
    merged_plants = _load_merged_plants()
    results: list[dict[str, str]] = []
    for key, info in merged_plants.items():
        scientific_name = key.replace("_", " ").strip()
        common_name = str(info.get("common_name", "")).strip() or scientific_name
        results.append(
            {
                "name": common_name,
                "scientific_name": scientific_name,
            }
        )
    results.sort(key=lambda item: item["name"].lower())
    return results


def get_growth_plan(plant_name: str) -> dict:
    merged_plants = _load_merged_plants()
    target = _normalize_name(plant_name)

    target_plant = None
    for key, info in merged_plants.items():
        common_name = str(info.get("common_name", "")).strip()
        key_norm = _normalize_name(key.replace("_", " "))
        common_norm = _normalize_name(common_name)
        if target and (target == key_norm or target == common_norm):
            target_plant = info
            break

    if target_plant is None and target:
        for key, info in merged_plants.items():
            common_name = str(info.get("common_name", "")).strip()
            key_norm = _normalize_name(key.replace("_", " "))
            common_norm = _normalize_name(common_name)
            if target in key_norm or target in common_norm or key_norm in target or common_norm in target:
                target_plant = info
                break

    if target_plant is None and target:
        # Last-pass token overlap to better match model outputs to DB labels.
        best_score = 0
        for key, info in merged_plants.items():
            common_name = str(info.get("common_name", "")).strip()
            key_tokens = set(_normalize_name(key.replace("_", " ")).split())
            common_tokens = set(_normalize_name(common_name).split())
            target_tokens = set(target.split())
            score = len(target_tokens.intersection(key_tokens.union(common_tokens)))
            if score > best_score:
                best_score = score
                target_plant = info
        if best_score == 0:
            target_plant = None

    if not target_plant:
        return {"error": f"Plant '{plant_name}' not found in the database."}

    return {
        "common_name": target_plant.get("common_name", plant_name),
        "growth_plan": target_plant.get("growth_plan", []),
        "recurring_care_tasks": target_plant.get("recurring_care_tasks", {}),
        "tips": target_plant.get("quick_tips", []),
    }
