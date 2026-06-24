"""Generate IAM-OIDC-AD-Flow.pdf from docs/IAM-OIDC-AD-Flow.md"""
from __future__ import annotations

import re
from pathlib import Path

try:
    from fpdf import FPDF
except ImportError:
    raise SystemExit("Run: pip install fpdf2>=2.7.0")

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "IAM-OIDC-AD-Flow.md"
OUTPUT = ROOT / "docs" / "IAM-OIDC-AD-Flow.pdf"


def ascii_safe(text: str) -> str:
    replacements = {
        "\u2013": "-",
        "\u2014": "-",
        "\u00b7": "|",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u2192": "->",
    }
    for src, dst in replacements.items():
        text = text.replace(src, dst)
    return text.encode("latin-1", "replace").decode("latin-1")


class DocPDF(FPDF):
    def footer(self):
        self.set_y(-12)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 8, ascii_safe(f"Keycloak + AD + OIDC SSO  |  Page {self.page_no()}"), align="C")


def render_markdown(pdf: DocPDF, text: str) -> None:
    in_code = False
    table_buffer: list[str] = []

    def w() -> float:
        return pdf.epw

    def flush_table() -> None:
        nonlocal table_buffer
        if not table_buffer:
            return
        pdf.set_font("Helvetica", "", 9)
        for row in table_buffer:
            if re.match(r"^\|[-:\s|]+\|$", row.strip()):
                continue
            cells = [c.strip() for c in row.strip().strip("|").split("|")]
            line = "  |  ".join(cells)
            pdf.multi_cell(w(), 4.5, ascii_safe(line))
        pdf.ln(2)
        table_buffer = []

    for raw_line in text.splitlines():
        line = raw_line.rstrip()

        if line.strip().startswith("```"):
            if in_code:
                in_code = False
                pdf.set_font("Courier", "", 8)
                pdf.ln(1)
            else:
                flush_table()
                in_code = True
                pdf.ln(1)
                pdf.set_font("Courier", "", 8)
            continue

        if in_code:
            pdf.multi_cell(w(), 3.8, ascii_safe(line))
            continue

        if line.strip().startswith("|"):
            table_buffer.append(line)
            continue
        flush_table()

        if not line.strip():
            pdf.ln(2)
            continue

        if line.startswith("# "):
            pdf.ln(4)
            pdf.set_font("Helvetica", "B", 16)
            pdf.multi_cell(w(), 7, ascii_safe(line[2:].strip()))
            pdf.ln(2)
            continue

        if line.startswith("## "):
            pdf.ln(3)
            pdf.set_font("Helvetica", "B", 13)
            pdf.set_fill_color(240, 240, 240)
            pdf.multi_cell(w(), 6, ascii_safe("  " + line[3:].strip()), fill=True)
            pdf.ln(2)
            continue

        if line.startswith("### "):
            pdf.ln(2)
            pdf.set_font("Helvetica", "B", 11)
            pdf.multi_cell(w(), 5, ascii_safe(line[4:].strip()))
            pdf.ln(1)
            continue

        if line.startswith("---"):
            pdf.ln(2)
            continue

        if line.startswith("- "):
            pdf.set_font("Helvetica", "", 10)
            pdf.set_x(pdf.l_margin)
            pdf.multi_cell(w(), 5, ascii_safe("- " + line[2:].strip()))
            continue

        if re.match(r"^\d+\.\s", line):
            pdf.set_font("Helvetica", "", 10)
            pdf.set_x(pdf.l_margin)
            pdf.multi_cell(w(), 5, ascii_safe(line.strip()))
            continue

        pdf.set_font("Helvetica", "", 10)
        pdf.set_x(pdf.l_margin)
        pdf.multi_cell(w(), 5, ascii_safe(line.strip()))

    flush_table()


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Missing source: {SOURCE}")

    body = SOURCE.read_text(encoding="utf-8")
    # Skip YAML-style title block before first # if needed; file starts with #
    pdf = DocPDF()
    pdf.set_auto_page_break(auto=True, margin=14)
    pdf.set_margins(18, 18, 18)
    pdf.add_page()

    pdf.set_font("Helvetica", "", 9)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(0, 5, ascii_safe("Talha Bilal - Portfolio technical guide"), new_x="LMARGIN", new_y="NEXT")
    pdf.set_text_color(0, 0, 0)
    pdf.ln(2)

    render_markdown(pdf, body)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    pdf.output(str(OUTPUT))
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
