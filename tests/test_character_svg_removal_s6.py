from pathlib import Path


ROOT = Path(__file__).parents[1] / "presentation"


def test_presentation_contains_no_legacy_character_svg_references():
    offenders = []
    ignored_roots = {".widget_preview", ".dart_tool", "build"}
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in {".dart", ".html", ".js", ".json", ".yaml", ".md"}:
            continue
        relative = path.relative_to(ROOT)
        if any(part in ignored_roots for part in relative.parts):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore").lower()
        # Generated SVG strings are part of the current in-memory procedural
        # renderer. Legacy means file-backed SVG assets or flutter_svg usage.
        if "flutter_svg" in text or "assetspath" in text and ".svg" in text:
            offenders.append(str(relative))
    assert offenders == [], f"Legacy SVG character trace remains: {offenders}"


def test_no_file_backed_character_svg_assets_are_present():
    files = []
    ignored_roots = {".widget_preview", ".dart_tool", "build"}
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() != ".svg":
            continue
        relative = path.relative_to(ROOT)
        if any(part in ignored_roots for part in relative.parts):
            continue
        files.append(str(relative))
    assert files == []
