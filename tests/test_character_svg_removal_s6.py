from pathlib import Path


ROOT = Path(__file__).parents[1] / "presentation"


def test_presentation_contains_no_legacy_character_svg_references():
    offenders = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in {".dart", ".html", ".js", ".json", ".yaml", ".md"}:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore").lower()
        if ".svg" in text or "svgpicture" in text or "flutter_svg" in text:
            offenders.append(str(path.relative_to(ROOT)))
    assert offenders == [], f"Legacy SVG character trace remains: {offenders}"


def test_no_svg_character_files_are_present():
    files = [p for p in ROOT.rglob("*") if p.is_file() and p.suffix.lower() == ".svg"]
    assert files == []
