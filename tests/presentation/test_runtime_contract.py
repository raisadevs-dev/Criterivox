import pytest

from criterivox.domain.characters import CharacterState
from criterivox.presentation.contract import PresentationContract


def test_contract_serializes_renderer_independent_state() -> None:
    contract = PresentationContract.from_state(
        "Dharen",
        CharacterState.WORK,
        message="Dharen is working.",
        event="ANALYSIS_STARTED",
    )

    payload = contract.to_dict()

    assert payload["contract_version"] == 1
    assert payload["character_id"] == "Dharen"
    assert payload["character_state"] == "work"
    assert payload["animation"] == "work"
    assert payload["message"] == "Dharen is working."
    assert payload["event"] == "ANALYSIS_STARTED"


def test_contract_rejects_invalid_character_state() -> None:
    with pytest.raises(TypeError):
        PresentationContract.from_state("Dharen", "WORK")  # type: ignore[arg-type]
