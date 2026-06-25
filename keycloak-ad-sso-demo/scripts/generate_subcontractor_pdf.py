"""Generate PDF from HTML subcontractor or proposal documents."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ensure_playwright() -> None:
    try:
        import playwright  # noqa: F401
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "playwright"])
    subprocess.check_call([sys.executable, "-m", "playwright", "install", "chromium"])


def generate(html: Path, output: Path, footer: str) -> None:
    if not html.exists():
        raise SystemExit(f"Missing HTML: {html}")

    ensure_playwright()
    from playwright.sync_api import sync_playwright

    uri = html.resolve().as_uri()
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(uri, wait_until="networkidle")
        page.pdf(
            path=str(output),
            format="A4",
            print_background=True,
            margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
            prefer_css_page_size=True,
        )
        browser.close()
    print(f"Wrote {output}")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--html",
        default=str(ROOT / "docs" / "subcontractor" / "talha-delivery-offer.html"),
    )
    parser.add_argument(
        "--output",
        default=str(ROOT / "docs" / "Talha-Bilal-SecureLink-Delivery-Offer.pdf"),
    )
    args = parser.parse_args()
    generate(Path(args.html), Path(args.output), "")


if __name__ == "__main__":
    main()
