import json
from pathlib import Path


ASSET = Path(__file__).parents[1] / "presentation" / "web" / "character_runtime" / "characters.json"


EXPECTED = {"dharen", "syvax", "sandre", "kaelen", "anuka", "vivren", "tarkis"}
STATES = {"IDLE", "RECEIVE", "WORK", "COMMUNICATE", "HANDOFF", "COMPLETE", "WARNING"}
REQUIRED_BONES = {"root", "pelvis", "torso", "neck", "head", "upper_arm_l", "forearm_l", "upper_arm_r", "forearm_r", "thigh_l", "shin_l", "thigh_r", "shin_r"}


def load():
    return json.loads(ASSET.read_text(encoding="utf-8"))


def test_skeletal_registry_contains_all_characters():
    data = load()
    assert data["format"] == "criterivox-skeletal-v2"
    assert set(data["characters"]) == EXPECTED


def test_shared_humanoid_rig_is_complete_and_hierarchical():
    data = load()
    bones = {bone["name"]: bone for bone in data["rig"]["bones"]}
    assert REQUIRED_BONES <= bones.keys()
    assert bones["root"]["parent"] is None
    for name, bone in bones.items():
        if bone["parent"] is not None:
            assert bone["parent"] in bones, name


def test_semantic_animation_tracks_cover_every_state():
    data = load()
    assert set(data["semanticStates"]) == STATES
    assert set(data["animationTracks"]) == STATES
    for state in STATES:
        track = data["animationTracks"][state]
        assert track["duration"] > 0
        assert isinstance(track["loop"], bool)
        assert track["bones"]


def test_character_visual_identity_is_not_a_single_generic_skin():
    data = load()
    signatures = {(c["hair"], c["accessory"], c["silhouette"]) for c in data["characters"].values()}
    assert len(signatures) == len(EXPECTED)
