from pathlib import Path


ROOT = Path(__file__).parents[1] / "presentation"


IGNORED_DIRECTORIES = {
    ".dart_tool",
    "build",
    ".widget_preview",
}


def source_files():
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue

        if any(
            part in IGNORED_DIRECTORIES
            for part in path.parts
        ):
            continue

        if path.suffix.lower() not in {
            ".dart",
            ".html",
            ".js",
            ".json",
            ".yaml",
            ".md",
        }:
            continue

        yield path


def test_presentation_contains_no_legacy_character_svg_dependencies():
    offenders = []

    for path in source_files():
        text = path.read_text(
            encoding="utf-8",
            errors="ignore",
        ).lower()

        forbidden = (
            "flutter_svg",
            "svgpicture",
            "assetbundlesvg",
        )

        if any(marker in text for marker in forbidden):
            offenders.append(
                str(path.relative_to(ROOT))
            )

    assert offenders == [], (
        "Legacy SVG character dependency remains: "
        f"{offenders}"
    )


def test_no_file_backed_character_svg_assets_are_present():
    files = []

    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue

        if any(
            part in IGNORED_DIRECTORIES
            for part in path.parts
        ):
            continue

        if path.suffix.lower() != ".svg":
            continue

        files.append(
            str(path.relative_to(ROOT))
        )

    assert files == [], (
        "File-backed SVG character assets remain: "
        f"{files}"
    )


def test_generated_vector_animation_is_not_treated_as_legacy_asset_dependency():
    generator = (
        ROOT
        / "lib"
        / "character"
        / "generated_vector_animation.dart"
    )

    text = generator.read_text(
        encoding="utf-8",
        errors="ignore",
    )

    assert "class GeneratedVectorAnimation" in text
    assert "String svgFrame" in text