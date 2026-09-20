from criterivox.application.character_chat import UNIFIED_RUNTIME
from criterivox.character_backbone.loader import load_message_chips
from criterivox.presentation.contract import PresentationContract
from criterivox.domain.characters import CharacterState

def test_message_chips_are_loadable_from_canonical_versioned_file():
    chips = load_message_chips()
    assert chips["schema_version"] == "2.0"
    assert chips["mapping"]["What is happening?"] == "QUERY_CURRENT_STATE"

def test_unified_response_contains_frontend_contract_fields():
    result = UNIFIED_RUNTIME.handle("Show provenance", character_id="epistre", task_id="contract-test")
    assert result.machine["capability"] == "trace_provenance"
    assert result.machine["responsible_character"] == "epistre"
    contract = PresentationContract.from_state(
        "epistre", CharacterState.COMMUNICATE,
        message=result.human_text, event="CHARACTER_CHAT_RESPONSE",
        unified_journey_id="J-test",
        unified_intent=result.language.intent,
        unified_entities=result.language.entities,
        unified_target=result.language.target,
        unified_requested_output=result.language.requested_output,
        unified_confidence=result.language.confidence,
        unified_source=result.language.source,
        unified_capability=result.machine.get("capability"),
        unified_responsible_character=result.machine.get("responsible_character"),
        unified_authorization=result.machine.get("authorization"),
        unified_state_source=result.machine.get("state_source"),
        unified_workflow_outcome=result.machine.get("workflow_outcome"),
        unified_status=result.machine.get("status"),
    )
    payload = contract.to_dict()
    assert payload["unified_intent"] == "SHOW_PROVENANCE"
    assert payload["unified_capability"] == "trace_provenance"
    assert payload["unified_responsible_character"] == "epistre"

def test_unavailable_action_is_explicitly_non_executing():
    result = UNIFIED_RUNTIME.handle("Execute calendar action", character_id="bodhex")
    assert result.machine["status"] == "CAPABILITY_UNAVAILABLE"
    assert result.machine["workflow_outcome"] == "no_state_change"
