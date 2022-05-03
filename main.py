import time
from selenium import webdriver
from selenium.webdriver.common.by import By

driver = webdriver.Firefox()
driver.get("https://instagram.com")

input()

driver.get("https://instagram.com/porgovska_drbna")

input()

try:
    imgs = []
    while True:
        try:
            next = driver.find_element(
                by=By.CSS_SELECTOR, value='[aria-label="Next"]'
            )
        except:
            break

        parent = next.find_element(by=By.XPATH, value="..")
        imgs.append(
            parent.find_element(by=By.CSS_SELECTOR, value="img").get_attribute(
                "src"
            )
        )

        next.click()
        time.sleep(0.3)

finally:
    [print(img) for img in imgs]
