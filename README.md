# AI Plant Growth Assistant

AI Plant Growth Assistant is a plant health support project with:
- a Python FastAPI backend for plant disease prediction and care guidance
- a frontend app (inside `frontend`) that calls the backend APIs
- ML models in `models` used for leaf detection and disease classification

## What it does

- Accepts a plant image and predicts plant/disease information.
- Returns confidence, health score, and care/prevention guidance.
- Supports a faster identify mode and a disease-focused mode with leaf detection.
- Can optionally enrich results with iNaturalist species metadata.

## Project structure

- `backend` - FastAPI server and prediction logic
- `frontend` - frontend application (currently a nested git repo)
- `models` - trained model files (`.keras` and `.pt`)

## Backend API

Base URL (local): `http://127.0.0.1:8000`

- `GET /health` - service health check
- `POST /predict?task=identify` - faster mode, skips YOLO crop
- `POST /predict?task=disease` - disease mode, runs leaf detector first
- `POST /predict?task=disease&enrich=true` - disease mode + iNaturalist metadata

## Local setup

### 1) Install backend dependencies

From `backend`:

```bash
python -m pip install -r requirements.txt
```

### 2) Run backend

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 3) Test backend

```bash
curl http://127.0.0.1:8000/health
```

Expected response:

```json
{"status":"ok"}
```

## Android testing (USB)

If your frontend app runs on an Android device:

```bash
adb devices
adb reverse tcp:8000 tcp:8000
```

Then the app can call backend via `http://127.0.0.1:8000`.

## Notes

- `INAT_ACCESS_TOKEN` is available via `backend/.env.example` for future use.
- Large model files are included under `models`.
- `Project Plant.zip` and `teammate_zip_extract` are intentionally not included in git history.