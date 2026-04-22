# FastAPI backend for Plant AI app

## What this backend does

- Loads `models/final_plant_model.keras` for disease classification.
- Loads `models/leaf_detector.pt` to detect/crop the leaf area before classification.
- Exposes a single endpoint used by Flutter:
  - `POST /predict?task=identify` — faster path (skips YOLO leaf crop; good for crop/plant family from the photo).
  - `POST /predict?task=disease` — runs leaf detector then the classifier (better when diagnosing leaf disease).
  - Optional: `POST /predict?task=disease&enrich=true` — adds iNaturalist metadata (slower network call).

## Run backend on laptop

From `backend/`:

```bash
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Health check:

```bash
curl http://127.0.0.1:8000/health
```

## Connect Android phone via USB debugging

1. Enable developer options + USB debugging on phone.
2. Connect phone by USB.
3. Verify ADB:

```bash
adb devices
```

4. Forward phone `127.0.0.1:8000` to laptop `127.0.0.1:8000`:

```bash
adb reverse tcp:8000 tcp:8000
```

This allows Flutter app on Android to call backend URL `http://127.0.0.1:8000`.

## Flutter side

- API URL is set in `frontend/lib/core/constants/api_constants.dart`.
- Ensure dependencies are installed:

```bash
cd ../frontend
flutter pub get
flutter run
```

## Notes

- iNaturalist endpoint used here is metadata search (`/v1/taxa`) for enrichment only.
- It does not provide direct public image-identification inference in standard v2 docs.
