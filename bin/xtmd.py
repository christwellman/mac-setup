#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["playwright", "browser-cookie3"]
# ///

import re
import sys
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

OUTPUT_DIR = Path.home() / "downloads" / "threads"


def parse_tweet_url(url: str) -> str | None:
    parsed = urlparse(url)
    host = parsed.netloc.removeprefix("www.").removeprefix("mobile.")
    if host not in ("x.com", "twitter.com"):
        return None
    match = re.search(r"/status/(\d+)", parsed.path)
    if not match:
        return None
    return match.group(1)


def sanitize(name: str) -> str:
    name = re.sub(r'[\\/:*?"<>|]', "-", name)
    return re.sub(r"\s+", " ", name).strip()


def truncate_first_line(text: str, max_len: int = 80) -> str:
    first_line = text.strip().split("\n")[0].strip()
    if not first_line:
        return "Untitled thread"
    return first_line[:max_len].strip()


def yaml_escape(text: str) -> str:
    return text.replace('"', "'")


def select_photo_url(media_url_https: str) -> str:
    if re.search(r":\w+$", media_url_https):
        base = media_url_https.rsplit(":", 1)[0]
    else:
        base = media_url_https
    return f"{base}:orig"


def select_best_video_variant(variants: list[dict]) -> str | None:
    mp4_variants = [v for v in variants if v.get("content_type") == "video/mp4"]
    if not mp4_variants:
        return None
    best = max(mp4_variants, key=lambda v: v.get("bitrate", 0))
    return best["url"]


def walk_self_thread(entries: list[dict], target_tweet_id: str) -> list[dict]:
    start_idx = next(
        (i for i, e in enumerate(entries) if e["id"] == target_tweet_id), None
    )
    if start_idx is None:
        return []
    author_id = entries[start_idx]["author_id"]
    thread = []
    for entry in entries[start_idx:]:
        if entry["author_id"] != author_id:
            break
        thread.append(entry)
    return thread


TWEET_DETAIL_URL_FRAGMENT = "TweetDetail"


def _authenticated_cookies() -> list[dict]:
    import browser_cookie3

    try:
        cookie_jar = browser_cookie3.chrome(domain_name="x.com")
    except Exception:
        return []

    wanted = {"auth_token", "ct0"}
    found = {c.name: c.value for c in cookie_jar if c.name in wanted}
    return [
        {"name": name, "value": value, "domain": ".x.com", "path": "/"}
        for name, value in found.items()
    ]


def fetch_thread_json(tweet_url: str) -> dict:
    from playwright.sync_api import sync_playwright

    captured: dict = {}

    def handle_response(response):
        if TWEET_DETAIL_URL_FRAGMENT in response.url and response.status == 200:
            try:
                captured["data"] = response.json()
            except Exception:
                pass

    with sync_playwright() as p:
        try:
            browser = p.chromium.launch(headless=True)
        except Exception as e:
            if "Executable doesn't exist" in str(e):
                print(
                    "Chromium not installed for Playwright. Run: "
                    "uv run --with playwright python -m playwright install chromium",
                    file=sys.stderr,
                )
                sys.exit(1)
            raise
        context = browser.new_context()
        cookies = _authenticated_cookies()
        if cookies:
            context.add_cookies(cookies)
        page = context.new_page()
        page.on("response", handle_response)
        try:
            page.goto(tweet_url, wait_until="networkidle", timeout=30000)
        except Exception:
            pass
        browser.close()

    if "data" not in captured:
        print(
            "Could not capture thread data. Make sure you're logged into "
            "x.com in your Chrome browser and try again.",
            file=sys.stderr,
        )
        sys.exit(1)

    return captured["data"]


def _extract_media(legacy: dict) -> list[dict]:
    media_list = []
    for item in legacy.get("extended_entities", {}).get("media", []):
        media_type = item.get("type")
        if media_type == "photo":
            media_list.append(
                {"type": "photo", "url": select_photo_url(item["media_url_https"])}
            )
        elif media_type in ("video", "animated_gif"):
            variants = item.get("video_info", {}).get("variants", [])
            url = select_best_video_variant(variants)
            if url is not None:
                media_list.append({"type": media_type, "url": url})
    return media_list


def _tweet_result_to_entry(tweet_result: dict | None) -> dict | None:
    if not tweet_result:
        return None
    if tweet_result.get("__typename") == "TweetWithVisibilityResults":
        tweet_result = tweet_result.get("tweet", tweet_result)
    legacy = tweet_result.get("legacy")
    if legacy is None:
        return None
    user_result = tweet_result.get("core", {}).get("user_results", {}).get("result", {})
    user_core = user_result.get("core", {})
    return {
        "id": tweet_result.get("rest_id"),
        "author_id": user_result.get("rest_id"),
        "author_handle": user_core.get("screen_name"),
        "author_name": user_core.get("name"),
        "text": legacy.get("full_text", ""),
        "created_at": legacy.get("created_at", ""),
        "media": _extract_media(legacy),
    }


def extract_tweet_entries(raw_json: dict) -> list[dict]:
    entries_out = []
    instructions = (
        raw_json.get("data", {})
        .get("threaded_conversation_with_injections_v2", {})
        .get("instructions", [])
    )
    for instruction in instructions:
        if instruction.get("type") != "TimelineAddEntries":
            continue
        for entry in instruction.get("entries", []):
            content = entry.get("content", {})
            item_content = content.get("itemContent")
            if item_content:
                tweet_result = item_content.get("tweet_results", {}).get("result")
                parsed = _tweet_result_to_entry(tweet_result)
                if parsed:
                    entries_out.append(parsed)
                continue
            for item in content.get("items", []):
                nested_content = item.get("item", {}).get("itemContent")
                if not nested_content:
                    continue
                tweet_result = nested_content.get("tweet_results", {}).get("result")
                parsed = _tweet_result_to_entry(tweet_result)
                if parsed:
                    entries_out.append(parsed)
    return entries_out


def download_media(url: str, dest: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(request, timeout=30) as resp, open(dest, "wb") as f:
            f.write(resp.read())
    except Exception as e:
        print(f"Warning: failed to download {url}: {e}", file=sys.stderr)


def build_markdown(thread: list[dict], tweet_url: str, media_dir_name: str) -> str:
    target = thread[0]
    title = yaml_escape(truncate_first_line(target["text"]))
    author_display = yaml_escape(f'{target["author_name"]} (@{target["author_handle"]})')
    lines = [
        "---",
        f'title: "{title}"',
        f'author: "{author_display}"',
        f"url: {tweet_url}",
        f"tweet_count: {len(thread)}",
        "---",
        "",
        f'# {target["author_name"]} (@{target["author_handle"]})',
        "",
        f"**Thread:** {tweet_url}",
        f"**Tweets:** {len(thread)}",
        "",
    ]
    for i, tweet in enumerate(thread, start=1):
        lines.append(f"## {i}")
        lines.append("")
        lines.append(tweet["text"])
        lines.append("")
        for j, media in enumerate(tweet["media"], start=1):
            ext = "jpg" if media["type"] == "photo" else "mp4"
            lines.append(f"![](./{media_dir_name}/{i:02d}-{j}.{ext})")
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: xtmd.py <tweet-url>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    tweet_id = parse_tweet_url(url)
    if not tweet_id:
        print("Could not extract tweet ID from URL", file=sys.stderr)
        sys.exit(1)

    raw_json = fetch_thread_json(url)
    entries = extract_tweet_entries(raw_json)
    thread = walk_self_thread(entries, tweet_id)
    if not thread:
        print(
            "Could not find tweet in captured data (deleted, protected, or blocked)",
            file=sys.stderr,
        )
        sys.exit(1)

    target = thread[0]
    base_name = f'{sanitize(truncate_first_line(target["text"]))} - {sanitize(target["author_handle"])}'
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    has_media = any(tweet["media"] for tweet in thread)
    if has_media:
        media_dir = OUTPUT_DIR / base_name
        media_dir.mkdir(parents=True, exist_ok=True)
        for i, tweet in enumerate(thread, start=1):
            for j, media in enumerate(tweet["media"], start=1):
                ext = "jpg" if media["type"] == "photo" else "mp4"
                download_media(media["url"], media_dir / f"{i:02d}-{j}.{ext}")

    markdown = build_markdown(thread, url, base_name)
    filepath = OUTPUT_DIR / f"{base_name}.md"
    filepath.write_text(markdown, encoding="utf-8")
    print(filepath)


if __name__ == "__main__":
    main()
