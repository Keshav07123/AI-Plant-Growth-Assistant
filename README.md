# AI Plant Growth Assistant

This project helps users identify plant issues from an image and gives care guidance.

It has:
- a FastAPI backend (`backend`) for ML prediction and helper APIs
- a frontend app (`frontend`) that calls backend endpoints
- ML model files (`models`) used during prediction

---

## 1) What this project does

After you upload a plant image, the backend can:
- identify likely plant + disease label
- calculate confidence percentage
- calculate a simple plant health score
- suggest remedies and prevention tips
- optionally fetch species metadata from iNaturalist

It also includes non-image helper APIs for:
- growth guidance (`/growth`)
- disease matching from symptoms (`/disease`)
- eco-reuse ideas (`/eco`)
- combined task router (`/agent`)

---

## 2) Folder structure (simple view)

- `backend/` - FastAPI app, routes, service logic
- `frontend/` - frontend app code
- `models/` - ML model files:
  - `final_plant_model.keras`
  - `leaf_detector.pt`

Important notes:
- `Project Plant.zip` and `teammate_zip_extract` are local-only and not part of repo history.
- `frontend` is currently a nested git repo in this project.

---

## 3) Tech stack

- Python 3.10+ recommended
- FastAPI + Uvicorn
- TensorFlow (disease classifier)
- Ultralytics YOLO (leaf detection/crop)
- OpenCV + Pillow + NumPy
- Flutter frontend (in `frontend`)

---

## 4) API tokens and environment variables

### What token is used?

Current env template file: `backend/.env.example`

```env
INAT_ACCESS_TOKEN=
```

### Is token mandatory right now?

- For current backend behavior, iNaturalist is queried through public endpoint logic.
- The `INAT_ACCESS_TOKEN` is kept for future/extended integrations.
- You can run the project without setting this token.

### How to set environment variables (optional)

Inside `backend/`:
1. Create a new file named `.env`
2. Copy content from `.env.example`
3. Add your token value if needed

Example:

```env
INAT_ACCESS_TOKEN=your_token_here
```

---

## 5) Prerequisites (for beginners)

Install these first:
- Python (3.10 or newer)
- Git
- (Optional for mobile testing) Android ADB tools
- (If running frontend) Flutter SDK

Check installations:

```bash
python --version
git --version
adb version
flutter --version
```

---

## 6) Backend setup (step-by-step)

Run all commands from project root unless specified.

### Step 1: go to backend

```bash
cd backend
```

### Step 2: install dependencies

```bash
python -m pip install -r requirements.txt
```

### Step 3: start backend server

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

If server starts correctly, it listens on:
- `http://127.0.0.1:8000`

### Step 4: health check

Open another terminal and run:

```bash
curl http://127.0.0.1:8000/health
```

Expected response:

```json
{"status":"ok"}
```

---

## 7) API endpoints explained

Base URL: `http://127.0.0.1:8000`

### A) Health endpoint

- `GET /health`
- Use: quick server status check

### B) Image prediction endpoint

- `POST /predict`
- Body: image file upload field name = `image`
- Query params:
  - `task=identify`
  - `task=disease`
  - optional `enrich=true`

Modes:
- `task=identify` -> faster path, skips YOLO leaf crop
- `task=disease` -> runs leaf detection before disease classification
- `enrich=true` -> attempts iNaturalist metadata enrichment

### C) Agent task router

- `POST /agent`
- JSON payload:
  - `task`: `growth` | `disease` | `eco`
  - `plant` (optional/required by task)
  - `symptoms` (for disease task)
  - `waste` (for eco task)

### D) Growth endpoint

- `GET /growth/{plant}`
- Use: get growth plan by plant name

### E) Plants endpoint

- `GET /plants`
- Use: list available plants and entries

### F) Disease match endpoint

- `POST /disease`
- JSON payload:
  - `symptoms`: list of symptom strings
  - `plant` (optional)

### G) Eco endpoint

- `GET /eco/{waste}`
- Use: get eco tasks from waste type

---

## 8) Quick API test examples

### Test `/agent` growth

```bash
curl -X POST "http://127.0.0.1:8000/agent" ^
  -H "Content-Type: application/json" ^
  -d "{\"task\":\"growth\",\"plant\":\"tomato\"}"
```

### Test `/disease` with symptoms

```bash
curl -X POST "http://127.0.0.1:8000/disease" ^
  -H "Content-Type: application/json" ^
  -d "{\"symptoms\":[\"yellow leaves\",\"spots\"],\"plant\":\"tomato\"}"
```

Note: above examples use Windows PowerShell/cmd line continuation style.

---

## 9) Frontend connection settings

Frontend API constants file:
- `frontend/lib/core/constants/api_constants.dart`

Current base URL:

```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

If backend runs on another machine/IP, update this value accordingly.

---

## 10) Android device testing (USB)

If app runs on physical Android device and backend runs on laptop:

```bash
adb devices
adb reverse tcp:8000 tcp:8000
```

Then app can call:
- `http://127.0.0.1:8000`

---

## 11) Common problems and fixes

### Problem: `ModuleNotFoundError` or import error

Fix:
- run commands from `backend` directory
- reinstall requirements

### Problem: port already in use

Fix:
- stop old server process, or run another port:

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001
```

Then update frontend base URL to `8001`.

### Problem: model loading fails

Fix:
- confirm model files exist:
  - `models/final_plant_model.keras`
  - `models/leaf_detector.pt`

### Problem: API not reachable from Android app

Fix:
- ensure backend is running
- run `adb reverse tcp:8000 tcp:8000` again
- verify frontend `baseUrl`

---

## 12) How to run full project quickly

1. Start backend:
   - `cd backend`
   - `python -m pip install -r requirements.txt`
   - `python -m uvicorn app.main:app --host 0.0.0.0 --port 8000`
2. Start frontend in another terminal (if needed):
   - `cd frontend`
   - `flutter pub get`
   - `flutter run`
3. Test backend health:
   - `curl http://127.0.0.1:8000/health`

If all steps pass, your project is ready to use.