import glob
import json
import pytesseract

months = ["unor"]

try:
    with open("data.json") as file:
        data = json.load(file)
except:
    data = []

for month in months:
    for ext in ("jpg", "webp"):
        for file in glob.glob(f"{month}/*.original.{ext}"):
            print(file)
            text = pytesseract.image_to_string(file, lang="ces")
            text = "".join([l for l in text.splitlines() if " ago" not in l])
            data.append({"src": file, "text": text})

with open("data.json", "w") as file:
    json.dump(data, file)
