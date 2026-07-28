#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# ///

import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, parse_qs, urlencode

OUTPUT_DIR = Path.home() / "downloads" / "videos"


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
        print("Usage: ytdl.py <youtube-url>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    video_id = get_video_id(url)
    if not video_id:
        print("Could not extract video ID from URL", file=sys.stderr)
        sys.exit(1)

    title, author = get_metadata(url)

    filename = f"{sanitize(title)} - {sanitize(author)}.mp4"
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    filepath = OUTPUT_DIR / filename

    try:
        subprocess.run(
            [
                "yt-dlp",
                "-f", "bestvideo+bestaudio",
                "--merge-output-format", "mp4",
                "--postprocessor-args", "ffmpeg:-c:v libx264 -c:a aac",
                "-o", str(filepath),
                url,
            ],
            check=True,
        )
    except FileNotFoundError:
        print("yt-dlp not found on PATH. Install it with: brew install yt-dlp", file=sys.stderr)
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"yt-dlp failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(1)

    print(filepath)


if __name__ == "__main__":
    main()
