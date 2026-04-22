import requests


def main() -> None:
    url = "http://127.0.0.1:8000/predict?task=disease"
    image_path = r"..\frontend\assets\plant_bg.png"
    with open(image_path, "rb") as f:
        files = {"image": ("plant_bg.png", f, "image/png")}
        r = requests.post(url, files=files, timeout=120)
    print(r.status_code)
    print(r.text[:1000])


if __name__ == "__main__":
    main()
