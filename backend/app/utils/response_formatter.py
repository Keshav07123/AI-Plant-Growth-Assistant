from __future__ import annotations


def format_growth_response(data: dict) -> dict:
    return {
        "status": "success",
        "data": {
            "type": "growth_plan",
            "common_name": data.get("common_name"),
            "growth_plan": data.get("growth_plan", []),
            "recurring_care_tasks": data.get("recurring_care_tasks", {}),
            "tips": data.get("tips", []),
        },
    }


def format_disease_response(data: dict) -> dict:
    if data.get("disease") == "No Match":
        return {
            "status": "success",
            "data": {
                "type": "disease_match",
                "match_found": False,
                "message": data.get("message"),
            },
        }

    return {
        "status": "success",
        "data": {
            "type": "disease_match",
            "match_found": True,
            "disease": data.get("disease"),
            "disease_common_name": data.get("disease_common_name", data.get("disease")),
            "plant_name": data.get("plant_name"),
            "confidence": data.get("confidence"),
            "remedies": data.get("remedies", []),
            "prevention": data.get("prevention", []),
        },
    }


def format_eco_response(data: dict) -> dict:
    return {
        "status": "success",
        "data": {
            "type": "eco_tasks",
            "waste_type": data.get("waste_type"),
            "use_cases": data.get("use_cases", []),
        },
    }
