from criterivox.domain.characters import CharacterState
from criterivox.presentation.contract import PresentationContract


def test_sandre_state_can_carry_foundation_metadata():
    contract = PresentationContract.from_state(
        "sandre", CharacterState.COMMUNICATE,
        message="Review required.", event="USER_CONFIRMATION_REQUIRED",
        foundation_id="DF-TEST", foundation_source_count=2,
        foundation_candidate_count=4, foundation_confirmation="uncertain",
    )
    payload = contract.to_dict()
    assert payload["character_id"] == "sandre"
    assert payload["character_state"] == "communicate"
    assert payload["foundation_id"] == "DF-TEST"
    assert payload["foundation_candidate_count"] == 4
