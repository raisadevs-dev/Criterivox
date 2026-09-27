from pathlib import Path


ROOT = Path(__file__).parents[1]
PROFILE = (
    ROOT
    / "presentation"
    / "lib"
    / "character"
    / "character_visual_profile.dart"
)
RUNTIME = (
    ROOT
    / "presentation"
    / "lib"
    / "character"
    / "session_character_animation.dart"
)
GENERATOR = (
    ROOT
    / "presentation"
    / "lib"
    / "character"
    / "generated_vector_animation.dart"
)


EXPECTED_STATES = {
    "IDLE",
    "RECEIVE",
    "WORK",
    "COMMUNICATE",
    "HANDOFF",
    "COMPLETE",
    "WARNING",
}


def read(path: Path) -> str:
    return path.read_text(
        encoding="utf-8",
        errors="ignore",
    )


def test_current_character_renderer_has_visual_profiles():
    text = read(PROFILE)

    assert "class CharacterVisualProfile" in text
    assert "static const Map<String, CharacterVisualProfile> registry" in text

    for character_id in (
        "dharen",
        "vivren",
        "tarkis",
        "sandre",
        "pramon",
        "syvax",
        "bodhex",
        "manis",
        "anuka",
        "viveda",
        "kaelen",
        "anukor",
        "medrus",
        "epistre",
        "veridat",
    ):
        assert f"'{character_id}'" in text


def test_current_character_renderer_has_session_animation_boundary():
    text = read(RUNTIME)

    assert "class SessionCharacterAnimation" in text
    assert "AnimationController" in text
    assert "CharacterRuntimeView" in text
    assert "CharacterVisualProfile" in text


def test_current_character_renderer_preserves_semantic_state_mapping():
    text = read(RUNTIME)

    assert "CharacterAnimationStateMapper.fromRuntime" in text
    assert "CharacterAnimationStateMapper.bloomSignal" in text

    # The renderer consumes semantic runtime states rather than
    # defining independent application state.


def test_generated_vector_animation_is_secondary_representation():
    text = read(GENERATOR)

    assert "class GeneratedVectorAnimation" in text
    assert "String svgFrame" in text
    assert "viewBox=\"0 0 238 286\"" in text

    # Generated SVG is an in-memory secondary representation.
    # It is not a file-backed character-asset dependency.

def test_complete_roster_has_no_generic_visual_fallback():
    text = read(PROFILE)

    for character_id in (
        "dharen", "vivren", "tarkis", "sandre", "pramon",
        "syvax", "bodhex", "manis", "anuka", "viveda",
        "kaelen", "anukor", "medrus", "epistre", "veridat",
    ):
        assert f"'{character_id}': CharacterVisualProfile(" in text
