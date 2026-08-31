import pytest

from criterivox.domain.events import (
    DomainEvent,
    EventType,
    create_event,
)


def test_event_vocabulary_is_defined() -> None:
    assert EventType.DATA_RECEIVED.value == "data_received"
    assert EventType.CONTEXT_UPDATED.value == "context_updated"
    assert EventType.TASK_IDENTIFIED.value == "task_identified"
    assert EventType.ANALYSIS_REQUESTED.value == "analysis_requested"
    assert EventType.ANALYSIS_STARTED.value == "analysis_started"
    assert EventType.ANALYSIS_COMPLETED.value == "analysis_completed"
    assert EventType.INSIGHT_GENERATED.value == "insight_generated"
    assert EventType.EXPLANATION_REQUESTED.value == "explanation_requested"
    assert EventType.EXPLANATION_READY.value == "explanation_ready"
    assert EventType.WARNING_RAISED.value == "warning_raised"
    assert EventType.TASK_COMPLETED.value == "task_completed"


def test_event_can_be_created() -> None:
    event = create_event(
        EventType.DATA_RECEIVED,
        {"source": "test"},
    )

    assert isinstance(event, DomainEvent)
    assert event.event_type is EventType.DATA_RECEIVED
    assert event.payload["source"] == "test"
    assert event.event_id


def test_event_without_payload_can_be_created() -> None:
    event = create_event(EventType.TASK_COMPLETED)

    assert event.event_type is EventType.TASK_COMPLETED
    assert event.payload == {}


def test_event_payload_is_immutable() -> None:
    event = create_event(
        EventType.DATA_RECEIVED,
        {"source": "test"},
    )

    with pytest.raises(TypeError):
        event.payload["source"] = "changed"


def test_event_identifier_cannot_be_empty() -> None:
    with pytest.raises(ValueError):
        DomainEvent(
            event_type=EventType.DATA_RECEIVED,
            event_id="",
        )


def test_event_type_must_be_valid() -> None:
    with pytest.raises(TypeError):
        DomainEvent(
            event_type="data_received",  # type: ignore[arg-type]
        )


def test_event_payload_must_be_mapping() -> None:
    with pytest.raises(TypeError):
        DomainEvent(
            event_type=EventType.DATA_RECEIVED,
            payload=["invalid"],  # type: ignore[arg-type]
        )


def test_each_created_event_gets_unique_identifier() -> None:
    first = create_event(EventType.DATA_RECEIVED)
    second = create_event(EventType.DATA_RECEIVED)

    assert first.event_id != second.event_id