from __future__ import annotations

import io
import os
import sys
from pathlib import Path
from typing import Any

import cv2
import numpy as np
import requests
import tensorflow as tf
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from ultralytics import YOLO

if __package__ in (None, ""):
    # Allow `python app/main.py` by adding backend root to sys.path.
    sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.disease_labels import DISEASE_LABELS
from app.routes.agent_routes import router as agent_router
from app.services.disease_service import get_guidance_for_prediction

ROOT_DIR = Path(__file__).resolve().parents[2]
MODELS_DIR = ROOT_DIR / "models"
DISEASE_MODEL_PATH = MODELS_DIR / "final_plant_model.keras"
LEAF_MODEL_PATH = MODELS_DIR / "leaf_detector.pt"

app = FastAPI(title="Plant AI Backend", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(agent_router)

disease_model: Any | None = None
leaf_detector: Any | None = None
LEAF_CLASS_NAME = "leaf"


def ensure_models_loaded() -> None:
    """Load heavy ML models lazily so assistant endpoints stay responsive."""
    global disease_model, leaf_detector
    if disease_model is None:
        disease_model = tf.keras.models.load_model(DISEASE_MODEL_PATH)
    if leaf_detector is None:
        leaf_detector = YOLO(str(LEAF_MODEL_PATH))


def preprocess_for_disease_model(image: Image.Image) -> np.ndarray:
    image = image.convert("RGB").resize((224, 224))
    arr = np.asarray(image, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)


def resize_for_inference(image: Image.Image, max_side: int = 1280) -> Image.Image:
    """Cap very large phone images to reduce inference latency."""
    image = image.convert("RGB")
    w, h = image.size
    longest = max(w, h)
    if longest <= max_side:
        return image
    scale = max_side / float(longest)
    new_size = (max(1, int(w * scale)), max(1, int(h * scale)))
    return image.resize(new_size, Image.Resampling.LANCZOS)


def detect_best_leaf_crop(image: Image.Image) -> tuple[Image.Image, dict[str, Any] | None]:
    ensure_models_loaded()
    rgb = np.array(image.convert("RGB"))
    bgr = cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)
    results = leaf_detector.predict(source=bgr, verbose=False, conf=0.25)
    if not results:
        return image, None

    res = results[0]
    if res.boxes is None or len(res.boxes) == 0:
        return image, None

    best_idx = int(np.argmax(res.boxes.conf.cpu().numpy()))
    box = res.boxes.xyxy.cpu().numpy()[best_idx]
    conf = float(res.boxes.conf.cpu().numpy()[best_idx])
    cls_idx = int(res.boxes.cls.cpu().numpy()[best_idx])
    cls_name = leaf_detector.model.names.get(cls_idx, str(cls_idx))

    if cls_name != LEAF_CLASS_NAME:
        return image, None

    h, w = rgb.shape[:2]
    x1, y1, x2, y2 = [int(v) for v in box]
    x1 = max(0, x1)
    y1 = max(0, y1)
    x2 = min(w, x2)
    y2 = min(h, y2)
    if x2 <= x1 or y2 <= y1:
        return image, None

    crop = rgb[y1:y2, x1:x2]
    crop_image = Image.fromarray(crop)
    return crop_image, {"bbox": [x1, y1, x2, y2], "confidence": conf}


def parse_label(label: str) -> tuple[str, str]:
    if "___" in label:
        plant, disease = label.split("___", 1)
    else:
        plant, disease = label, "unknown"
    return plant.replace("_", " "), disease.replace("_", " ")


def health_score_from_disease(disease_name: str, confidence: float) -> tuple[int, str]:
    if disease_name.lower() == "healthy":
        return 95, "Healthy"
    severity_penalty = int(35 + confidence * 45)
    score = max(5, 100 - severity_penalty)
    if score >= 70:
        status = "Watch"
    elif score >= 40:
        status = "Needs Care"
    else:
        status = "Critical"
    return score, status


def fetch_inaturalist_species(plant_name: str) -> dict[str, Any] | None:
    try:
        response = requests.get(
            "https://api.inaturalist.org/v1/taxa",
            params={"q": plant_name, "rank": "species", "per_page": 1},
            timeout=8,
        )
        response.raise_for_status()
        data = response.json()
        results = data.get("results") or []
        if not results:
            return None
        top = results[0]
        return {
            "id": top.get("id"),
            "name": top.get("name"),
            "preferred_common_name": top.get("preferred_common_name"),
            "wikipedia_url": top.get("wikipedia_url"),
        }
    except Exception:
        return None


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/predict")
async def predict(
    image: UploadFile = File(...),
    task: str = "identify",
    enrich: bool = False,
) -> dict[str, Any]:
    ensure_models_loaded()
    if task not in {"identify", "disease"}:
        raise HTTPException(status_code=400, detail="task must be identify or disease")

    raw = await image.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Empty image file")

    # Android clients often omit MIME type or send application/octet-stream; validate bytes.
    try:
        input_image = Image.open(io.BytesIO(raw))
        input_image.load()
    except Exception as exc:
        raise HTTPException(
            status_code=400,
            detail=f"Uploaded file must be an image ({exc})",
        ) from exc

    resized_image = resize_for_inference(input_image, max_side=1280)

    if task == "identify":
        # Faster: skip YOLO (saves noticeable CPU); classifier still reads the full photo.
        leaf_crop, leaf_meta = resized_image, None
    else:
        leaf_crop, leaf_meta = detect_best_leaf_crop(resized_image)
    model_input = preprocess_for_disease_model(leaf_crop)
    probs = disease_model.predict(model_input, verbose=0)[0]
    pred_idx = int(np.argmax(probs))
    confidence = float(probs[pred_idx])
    raw_label = DISEASE_LABELS[pred_idx]
    plant_name, disease_name = parse_label(raw_label)
    health_score, health_status = health_score_from_disease(disease_name, confidence)
    guidance = get_guidance_for_prediction(disease_name=disease_name, plant_name=plant_name)
    # Optional metadata call — slow network; keep off unless ?enrich=true
    inat = fetch_inaturalist_species(plant_name) if enrich else None

    result = {
        "task": task,
        "plant_name": plant_name,
        "disease_name": disease_name,
        "confidence_percent": round(confidence * 100, 2),
        "plant_health_score": health_score,
        "health_status": health_status,
        "disease_common_name": guidance.get("disease_common_name", disease_name),
        "remedies": guidance.get("remedies", []),
        "prevention": guidance.get("prevention", []),
        "leaf_detection": leaf_meta,
        "inaturalist": inat,
    }
    return result


if __name__ == "__main__":
    import uvicorn

    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("app.main:app", host=host, port=port, reload=False)
