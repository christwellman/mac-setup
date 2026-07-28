#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["youtube-transcript-api"]
# ///

import json
import re
import sys
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, parse_qs, urlencode

from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter

OUTPUT_DIR = Path.home() / "downloads" / "transcripts"


def get_video_id(url: str) -> str:
    parsed = urlparse(url)
    host = parsed.netloc.removeprefix("www.").removeprefix("m.")
    if host == "youtu.be":
        return parsed.path.lstrip("/")
    if host.endswith("youtube.com"):
        if parsed.path == "/watch":
            return parse_qs(parsed.query).get("v", [""])[0]
        for prefix in ("/shorts/", "/embed/", "/live/"):
            if parsed.path.startswith(prefix):
                return parsed.path.removeprefix(prefix).split("/")[0]
    return ""


def get_metadata(url: str) -> tuple[str, str]:
    oembed_url = "https://www.youtube.com/oembed?" + urlencode(
        {"url": url, "format": "json"}
    )
    try:
        with urllib.request.urlopen(oembed_url, timeout=10) as resp:
            data = json.load(resp)
        return data.get("title", "Unknown Title"), data.get("author_name", "Unknown Author")
    except Exception:
        return "Unknown Title", "Unknown Author"


def sanitize(name: str) -> str:
    name = re.sub(r'[\\/:*?"<>|]', "-", name)
    return re.sub(r"\s+", " ", name).strip()


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: ytmd.py <youtube-url>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    video_id = get_video_id(url)
    if not video_id:
        print("Could not extract video ID from URL", file=sys.stderr)
        sys.exit(1)

    title, author = get_metadata(url)

    api = YouTubeTranscriptApi()
    try:
        fetched = api.fetch(video_id, languages=["en", "en-US", "en-GB"])
    except Exception:
        transcript_list = api.list(video_id)
        for t in transcript_list:
            if t.language_code.startswith("en"):
                fetched = t.fetch()
                break
        else:
            print("No English transcript found for this video.", file=sys.stderr)
            sys.exit(1)

    text = TextFormatter().format_transcript(fetched)

    filename = f"{sanitize(title)} - {sanitize(author)}.md"
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    filepath = OUTPUT_DIR / filename

    yaml_title = title.replace('"', "'")
    yaml_author = author.replace('"', "'")

    with open(filepath, "w", encoding="utf-8") as f:
        f.write("---\n")
        f.write(f'title: "{yaml_title}"\n')
        f.write(f'author: "{yaml_author}"\n')
        f.write(f"video: {url}\n")
        f.write("---\n\n")
        f.write(f"# {title}\n\n")
        f.write(f"**Author:** {author}\n\n")
        f.write("## Transcript\n\n")
        f.write(text)
        f.write("\n")

    print(filepath)


if __name__ == "__main__":
    main()
