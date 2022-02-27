import time
from selenium import webdriver

driver = webdriver.Firefox()
driver.get("https://instagram.com")

input()

driver.get("https://instagram.com/porgovska_drbna")

input()

try:
    imgs = []
    while True:
        try:
            next = driver.find_element_by_css_selector('[aria-label="Next"]')
        except:
            break

        parent = next.find_element_by_xpath("..")
        imgs.append(
            parent.find_element_by_css_selector("img").get_attribute("src")
        )

        next.click()
        time.sleep(0.3)

finally:
    [print(img) for img in imgs]
