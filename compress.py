import glob
from PIL import Image

months = ["zari", "rijen", "listopad", "prosines", "leden", "unor"]

for month in months:
    for ext in ("jpg", "webp"):
        for file in glob.glob(f"{month}/*.original.{ext}"):
            print(file)

            image = Image.open(file)
            resized = image.resize((480, 853))
            resized.save(
                file.replace(".original", ""),
                format="JPEG",
                optimize=True,
                quality=65,
            )
