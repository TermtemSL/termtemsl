import time
import json
import csv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException

URL = "https://www.th-sl.com/search-by-act/"
SCROLL_PAUSE_TIME = 2
OUTPUT_JSON = "video_links.json"


def setup_driver():
    """
    Initialize and configure a Selenium Chrome WebDriver in headless mode.

    This function sets up Chrome with necessary options for scraping:
    - Runs in headless mode (no visible browser window)
    - Sets a fixed window size to ensure all elements are rendered properly
    - Adds performance and compatibility flags for stable execution

    Returns:
        driver (webdriver.Chrome): Configured Chrome WebDriver instance
    """
    options = Options()

    options.add_argument("--headless=new")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("user-agent=Mozilla/5.0")

    driver = webdriver.Chrome(options=options)
    return driver


def load_all_items(driver):
    """
    Dynamically load all sign language items from the webpage.

    This function:
    1. Scrolls to the bottom of the page
    2. Detects and clicks the "Load More" ("เพิ่มเติม") button
    3. Waits for new items to load
    4. Repeats the process until no more new items are available

    It ensures that all dynamically loaded content is fully rendered
    before extraction.

    Args:
        driver (webdriver.Chrome): Active Selenium WebDriver
    """
    prev_count = 0

    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)

        elements = driver.find_elements(By.CSS_SELECTOR, "h3.title a")
        curr_count = len(elements)

        print(f"Loaded items: {curr_count}")

        try:
            load_more_btn = driver.find_element(By.XPATH, "//button[contains(text(),'เพิ่มเติม')]")

            if load_more_btn.is_displayed():
                print("Clicking 'Load More'...")
                
                driver.execute_script("arguments[0].scrollIntoView(true);", load_more_btn)
                time.sleep(1)

                driver.execute_script("arguments[0].click();", load_more_btn)
                time.sleep(3)

            else:
                print("No more button visible")
                break

        except NoSuchElementException:
            print("No 'Load More' button found")
            break

        if curr_count == prev_count:
            print("No new items loaded → stop")
            break

        prev_count = curr_count

def extract_links(driver):
    """
    Extract all unique video page URLs from the loaded webpage.

    This function:
    - Finds all anchor tags inside the title elements
    - Extracts the href attribute (video page URL)
    - Removes duplicate links

    Args:
        driver (webdriver.Chrome): Active Selenium WebDriver

    Returns:
        links (list): List of unique video page URLs
    """
    elements = driver.find_elements(By.CSS_SELECTOR, "h3.title a")

    links = []
    for el in elements:
        href = el.get_attribute("href")
        if href:
            links.append(href)

    links = list(set(links))

    print(f"Total unique links: {len(links)}")
    return links

def save_json(links):
    """
    Save extracted video links into a JSON file.

    Each link is stored with a unique ID for easier tracking.

    Args:
        links (list): List of video page URLs
    """
    data = [{"id": i+1, "url": link} for i, link in enumerate(links)]

    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def main():
    """
    Main execution pipeline for scraping video page URLs.

    Workflow:
    1. Initialize WebDriver
    2. Open the target webpage
    3. Load all dynamic content (scroll + click "Load More")
    4. Extract all video links
    5. Save results to a JSON file
    6. Close the browser

    This function orchestrates the entire scraping process.
    """
    driver = setup_driver()
    driver.get(URL)

    print("Loading page...")
    time.sleep(5)

    load_all_items(driver)

    links = extract_links(driver)

    save_json(links)

    driver.quit()

    print("Done")

if __name__ == "__main__":
    main()