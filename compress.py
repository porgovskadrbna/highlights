import glob
from PIL import Image

years = ["2022"]
months = ["cerven", "zari", "rijen"]

for year in years:
    for month in months:
        for ext in ("jpg", "webp"):
            for file in glob.glob(f"media/{year}/{month}/*.original.{ext}"):
                print(file)

                image = Image.open(file)
                resized = image.resize((480, 853))
                resized.save(
                    file.replace(".original", ""),
                    format="JPEG",
                    optimize=True,
                    quality=65,
                )
