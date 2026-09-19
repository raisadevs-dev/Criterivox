from pathlib import Path
from criterivox.character_backbone.loader import load_character_registry,load_capability_registry,load_message_chips
from criterivox.character_backbone.validator import validate_registries
from criterivox.character_backbone.chips import validate_message_chips
from criterivox.character_backbone.datasets import load_jsonl,REQUIRED_TRAIN,REQUIRED_TEST

def test_registry_has_15_unique_characters():
    r=load_character_registry(); assert len(r.characters)==15; assert len({c.id for c in r.characters})==15

def test_capability_references_are_grounded():
    assert not validate_registries(load_character_registry(),load_capability_registry())

def test_role_boundaries_are_distinct():
    r={x.id:x for x in load_character_registry()}
    assert r["syvax"].home!=r["anukor"].home
    assert "adapt" in " ".join(r["anuka"].responsibilities).lower()
    assert "transfer" in " ".join(r["anukor"].responsibilities).lower()
    assert r["vivren"].id!=r["tarkis"].id
    assert r["medrus"].id!=r["veridat"].id
    assert r["epistre"].id!=r["viveda"].id
    assert r["pramon"].id!=r["bodhex"].id

def test_unimplemented_calendar_is_explicitly_required():
    c=load_capability_registry().by_id("calendar_execution")
    assert c.implementation_status.value=="REQUIRED"
    assert c.authorization_required is True

def test_chips_validate():
    validate_message_chips(load_message_chips())

def test_training_and_testing_validate_and_do_not_overlap():
    root=Path(__file__).resolve().parents[1]
    train=load_jsonl(root/"data/character_chat/set1_training.jsonl",REQUIRED_TRAIN)
    test=load_jsonl(root/"data/character_chat/set1_testing.jsonl",REQUIRED_TEST)
    assert train and test
    assert {x["id"] for x in train}.isdisjoint({x["id"] for x in test})
