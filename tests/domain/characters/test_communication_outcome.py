from criterivox.domain.characters.communication_message import (
    CommunicationPriority,
)
from criterivox.domain.characters.communication_outcome import (
    create_completion_message,
    create_uncertainty_message,
)


def test_uncertainty_message_is_created_with_high_priority() -> None:
    message = create_uncertainty_message(
        character_id="Veridat",
        event="warning_raised",
        content="The available evidence is insufficient.",
    )

    assert message.character_id == "Veridat"
    assert message.event == "warning_raised"
    assert message.content == "The available evidence is insufficient."
    assert message.priority is CommunicationPriority.HIGH


def test_completion_message_is_created_with_normal_priority() -> None:
    message = create_completion_message(
        character_id="Dharen",
        event="task_completed",
        content="The contextual structure is complete.",
    )

    assert message.character_id == "Dharen"
    assert message.event == "task_completed"
    assert message.content == "The contextual structure is complete."
    assert message.priority is CommunicationPriority.NORMAL


def test_uncertainty_message_remains_a_contextual_message() -> None:
    message = create_uncertainty_message(
        character_id="Pramon",
        event="warning_raised",
        content="Evidence does not fully support the claim.",
    )

    assert message.is_critical is False


def test_completion_message_is_not_marked_critical() -> None:
    message = create_completion_message(
        character_id="Bodhex",
        event="task_completed",
        content="The insight has been generated.",
    )

    assert message.is_critical is False