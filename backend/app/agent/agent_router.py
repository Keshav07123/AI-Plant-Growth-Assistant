from __future__ import annotations

import logging

from app.services.disease_service import match_disease
from app.services.eco_service import get_eco_tasks
from app.services.growth_service import get_growth_plan
from app.utils.response_formatter import (
    format_disease_response,
    format_eco_response,
    format_growth_response,
)

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


def route_request(input_data: dict) -> dict:
    if not isinstance(input_data, dict):
        return {"status": "error", "message": "Invalid input format. Must be a dictionary."}

    task = input_data.get("task")
    if not task:
        return {"status": "error", "message": "Task is required."}

    if task == "growth":
        plant = input_data.get("plant")
        if not plant:
            return {"status": "error", "message": "Plant is required for growth task."}
        logger.info("Routing growth task for plant: %s", plant)
        result = get_growth_plan(plant)
        if "error" in result:
            return {"status": "error", "message": result["error"]}
        return format_growth_response(result)

    if task == "disease":
        symptoms = input_data.get("symptoms")
        plant = input_data.get("plant")
        if not symptoms or not isinstance(symptoms, list):
            return {
                "status": "error",
                "message": "Symptoms list is required and cannot be empty for disease task.",
            }
        logger.info("Routing disease task with symptoms: %s", symptoms)
        result = match_disease(symptoms, plant_name=plant)
        if "error" in result:
            return {"status": "error", "message": result["error"]}
        return format_disease_response(result)

    if task == "eco":
        waste = input_data.get("waste")
        if not waste:
            return {"status": "error", "message": "Waste is required for eco task."}
        logger.info("Routing eco task for waste: %s", waste)
        result = get_eco_tasks(waste)
        if "error" in result:
            return {"status": "error", "message": result["error"]}
        return format_eco_response(result)

    return {"status": "error", "message": f"Unknown task: {task}"}
