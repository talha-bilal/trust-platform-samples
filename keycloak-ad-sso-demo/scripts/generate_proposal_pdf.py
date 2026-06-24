"""Generate SecureLink customer proposal PDF from HTML (Playwright)."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTML = ROOT / "docs" / "proposal" / "securelink-proposal.html"
OUTPUT = ROOT / "docs" / "SecureLink-Customer-Implementation-Proposal.pdf"


def ensure_playwright() -> None:
    try:
        import playwright  # noqa: F401
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "playwright"])
    subprocess.check_call([sys.executable, "-m", "playwright", "install", "chromium"])


def main() -> None:
    if not HTML.exists():
        raise SystemExit(f"Missing HTML: {HTML}")

    ensure_playwright()
    from playwright.sync_api import sync_playwright

    uri = HTML.resolve().as_uri()
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(uri, wait_until="networkidle")
        page.pdf(
            path=str(OUTPUT),
            format="A4",
            print_background=True,
            margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
            prefer_css_page_size=True,
        )
        browser.close()

    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
