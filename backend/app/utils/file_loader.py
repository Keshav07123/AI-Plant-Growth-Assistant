from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def load_json(file_path: str | Path) -> Any | None:
    """Safely read and parse a JSON file."""
    path = Path(file_path)
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
