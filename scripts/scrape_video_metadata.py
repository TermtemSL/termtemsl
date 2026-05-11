import os
import json
import time
import requests
import re
from bs4 import BeautifulSoup
from tqdm import tqdm

INPUT_JSON = "video_links.json"
BASE_DIR = "../data"
OUTPUT_METADATA = os.path.join(BASE_DIR, "video_metadata.json")

HEADERS = {
    "User-Agent": "Mozilla/5.0"
}


def clean_filename(name: str) -> str:
    """
    Remove invalid characters from filenames.
    """
    return re.sub(r'[\\/*?:"<>|]', "", name).strip()


def load_links():
    """
    Load video page URLs from JSON file.
    """
    with open(INPUT_JSON, "r", encoding="utf-8") as f:
        return json.load(f)


def scrape_page(url: str):
    """
    Scrape a single video page.

    Extract:
    - word (sign name)
    - video URL (mp4)
    - category

    Returns:
        (word, video_url, category)
    """
    res = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(res.text, "html.parser")

    word_tag = soup.select_one(".elementor-shortcode")
    word = word_tag.text.strip() if word_tag else "unknown"

    video_tag = soup.select_one("video source")
    video_url = video_tag["src"] if video_tag else None

    category_tag = soup.select_one(".post_tags a")
    category = category_tag.text.strip() if category_tag else "unknown"

    return word, video_url, category


def download_video(video_url: str, save_path: str):
    """
    Download video from URL and save to file.
    """
    res = requests.get(video_url, headers=HEADERS)
    with open(save_path, "wb") as f:
        f.write(res.content)

def clean_category(category: str) -> str:
    """
    Remove the word 'หมวด' from category if it exists.
    """
    category = category.replace("หมวด", "")
    return category.strip()

def clean_word(word: str) -> str:
    """
    Remove text inside parentheses (both Thai and English).
    Example: "ดีเบต (Debate)" → "ดีเบต"
    """
    word = re.sub(r"\s*\(.*?\)", "", word)
    return word.strip()

def main():
    links_data = load_links()

    os.makedirs(BASE_DIR, exist_ok=True)

    metadata = []
    id_counter = 1

    for item in tqdm(links_data):
        url = item["url"]

        try:
            word, video_url, category = scrape_page(url)

            if not video_url:
                continue

            word = clean_word(word)
            category = clean_category(category)

            safe_word = clean_filename(word)
            safe_category = clean_filename(category)

            category_path = os.path.join(BASE_DIR, safe_category)
            os.makedirs(category_path, exist_ok=True)

            video_path = os.path.join(category_path, f"{safe_word}.mp4")

            if os.path.exists(video_path):
                video_path = os.path.join(
                    category_path, f"{safe_word}_{id_counter}.mp4"
                )

            download_video(video_url, video_path)

            metadata.append({
                "id": id_counter,
                "url": url,
                "word": word,
                "category": category,
                "video_path": video_path,
                "landmarks": None,
                "label_id": None,
                "split": "train",
                "frames": None,
            })

            id_counter += 1

            time.sleep(1)

        except Exception as e:
            print(f"Error with {url}: {e}")

    with open(OUTPUT_METADATA, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)

    print("Done scraping metadata")


if __name__ == "__main__":
    main()