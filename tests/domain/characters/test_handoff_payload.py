import pytest

from criterivox.domain.characters.handoff_payload import HandoffPayload


def test_handoff_payload_can_be_created() -> None:
    payload = HandoffPayload(
        context={"task": "analysis"},
        result={"finding": "pattern detected"},
    )

    assert payload.context == {
        "task": "analysis",
    }
    assert payload.result == {
        "finding": "pattern detected",
    }


def test_handoff_payload_preserves_context() -> None:
    context = {
        "task": "analysis",
        "source": "context_engine",
    }

    payload = HandoffPayload(context=context)

    assert payload.context == context
    assert payload.has_context


def test_handoff_payload_can_exist_without_result() -> None:
    payload = HandoffPayload(
        context={"task": "analysis"},
    )

    assert payload.has_context
    assert not payload.has_result


def test_handoff_payload_detects_result() -> None:
    payload = HandoffPayload(
        context={"task": "analysis"},
        result="completed",
    )

    assert payload.has_result


def test_empty_context_is_allowed() -> None:
    payload = HandoffPayload()

    assert payload.context == {}
    assert not payload.has_context


def test_invalid_context_type_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="Handoff context must be a dictionary",
    ):
        HandoffPayload(
            context="invalid",  # type: ignore[arg-type]
        )