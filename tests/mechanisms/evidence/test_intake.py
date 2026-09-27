import pytest
from criterivox.s8.intake import CONTRACT, S8Intake


def valid():
    return {
        "contract": CONTRACT,
        "message_id": "m-1",
        "sender": "Dharen",
        "message_type": "research_context",
        "task": "Inspect evidence",
        "context": {"case": "synthetic"},
        "materials": [{"kind": "observation", "value": "x"}],
        "provenance": {"origin": "Dharen", "synthetic": True},
        "synthetic": True,
    }


def test_round_trip_preserves_member_and_synthetic_provenance():
    intake = S8Intake()
    parsed = intake.parse(valid())
    exported = intake.envelope(parsed)
    assert exported["sender"] == "Dharen"
    assert exported["synthetic"] is True
    assert exported["provenance"]["origin"] == "Dharen"


def test_rejects_wrong_contract():
    payload = valid()
    payload["contract"] = "wrong"
    with pytest.raises(ValueError):
        S8Intake().parse(payload)


def test_rejects_non_mapping_materials():
    payload = valid()
    payload["materials"] = ["not-structured"]
    with pytest.raises(ValueError):
        S8Intake().parse(payload)
