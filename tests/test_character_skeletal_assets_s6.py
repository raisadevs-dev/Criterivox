import re
from pathlib import Path

PROFILE = (
    Path(__file__).parents[1]
    / "presentation"
    / "lib"
    / "character"
    / "character_visual_profile.dart"
)
ANIMATION = (
    Path(__file__).parents[1]
    / "presentation"
    / "lib"
    / "character"
    / "generated_vector_animation.dart"
)

EXPECTED_STATES = {"IDLE", "RECEIVE", "WORK", "COMMUNICATE", "HANDOFF", "COMPLETE", "WARNING"}


def load_profile_source():
    return PROFILE.read_text(encoding="utf-8")


def test_current_character_registry_contains_distinct_profiles():
    text = load_profile_source()
    ids = set(re.findall(r"'([a-z]+)': CharacterVisualProfile\(", text))
    assert ids
    assert "dharen" in ids
    assert len(ids) == len(set(ids))


def test_current_character_profiles_have_distinct_visual_signatures():
    text = load_profile_source()
    profiles = re.findall(
        r"'([a-z]+)': CharacterVisualProfile\((.*?)\),\n",
        text,
        flags=re.DOTALL,
    )
    signatures = set()
    for character_id, body in profiles:
        hair = re.search(r"hair:\s*(Color\([^\n]+\))", body)
        accent = re.search(r"accent:\s*(Color\([^\n]+\))", body)
        accessory = re.search(r"accessory:\s*CharacterAccessory\.([a-zA-Z_]+)", body)
        assert hair and accent and accessory, character_id
        signatures.add((hair.group(1), accent.group(1), accessory.group(1)))
    assert len(signatures) == len(profiles)


def test_generated_vector_animation_is_the_current_runtime_contract():
    text = ANIMATION.read_text(encoding="utf-8")
    assert "class GeneratedVectorAnimation" in text
    assert "String svgFrame(" in text
    assert 'viewBox="0 0 238 286"' in text
    assert "No PNG/GIF files are required." in text
