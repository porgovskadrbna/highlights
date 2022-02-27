import glob
import json
import pytesseract

years = ["2021", "2022"]
months = ["zari", "rijen", "listopad", "prosinec", "leden", "unor"]

try:
    with open("data.json") as file:
        data = json.load(file)
except:
    data = []

for year in years:
    for month in months:
        for ext in ("jpg", "webp"):
            for file in glob.glob(f"media/{year}/{month}/*.original.{ext}"):
                print(file)

                text = pytesseract.image_to_string(file, lang="ces")
                text = "".join(
                    [l for l in text.splitlines() if " ago" not in l]
                )

                filename = file.replace(".original", "").replace(
                    ".webp", ".jpg"
                )
                data.append({"src": filename, "text": text})

with open("data.json", "w") as file:
    json.dump(data, file)
