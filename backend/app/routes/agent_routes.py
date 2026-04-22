from __future__ import annotations

from typing import Optional

from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.agent.agent_router import route_request
from app.services.disease_service import match_disease
from app.services.eco_service import get_eco_tasks
from app.services.growth_service import get_growth_plan, list_all_plant_names, list_all_plants
from app.utils.response_formatter import (
    format_disease_response,
    format_eco_response,
    format_growth_response,
)

router = APIRouter()


class AgentRequest(BaseModel):
    task: str = Field(..., description="growth | disease | eco")
    plant: Optional[str] = None
    symptoms: Optional[list[str]] = None
    waste: Optional[str] = None


class DiseaseRequest(BaseModel):
    symptoms: list[str] = Field(..., description="List of symptoms")
    plant: Optional[str] = None


@router.post("/agent")
def handle_agent_request(request: AgentRequest) -> dict:
    return route_request(request.model_dump(exclude_none=True))


@router.get("/growth/{plant}")
def get_plant_growth(plant: str) -> dict:
    result = get_growth_plan(plant)
    if "error" in result:
        return {"status": "error", "message": result["error"]}
    return format_growth_response(result)


@router.get("/plants")
def get_all_plants() -> dict:
    return {
        "status": "success",
        "data": {
            "plants": list_all_plant_names(),
            "plant_entries": list_all_plants(),
        },
    }


@router.post("/disease")
def get_disease_match(request: DiseaseRequest) -> dict:
    result = match_disease(request.symptoms, plant_name=request.plant)
    if "error" in result:
        return {"status": "error", "message": result["error"]}
    return format_disease_response(result)


@router.get("/eco/{waste}")
def get_eco_use_tasks(waste: str) -> dict:
    result = get_eco_tasks(waste)
    if "error" in result:
        return {"status": "error", "message": result["error"]}
    return format_eco_response(result)
