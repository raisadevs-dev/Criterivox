from criterivox.domain.characters.communication_truth import (
    CommunicationTruth,
)


def test_waiting_character_does_not_claim_progress() -> None:
    truth = CommunicationTruth()

    assert truth.status_message() == "waiting"
    assert not truth.can_claim_progress()


def test_active_character_can_communicate_progress() -> None:
    truth = CommunicationTruth(in_progress=True)

    assert truth.status_message() == "in_progress"
    assert truth.can_claim_progress()


def test_completed_character_can_communicate_completion() -> None:
    truth = CommunicationTruth(completed=True)

    assert truth.status_message() == "completed"
    assert truth.can_claim_completion()


def test_result_is_not_claimed_without_result() -> None:
    truth = CommunicationTruth(completed=True)

    assert not truth.can_claim_result()


def test_result_can_be_communicated_when_available() -> None:
    truth = CommunicationTruth(
        completed=True,
        result_available=True,
    )

    assert truth.can_claim_result()


def test_warning_is_communicated_as_warning() -> None:
    truth = CommunicationTruth(warning=True)

    assert truth.status_message() == "warning"
    assert truth.can_claim_warning()


def test_warning_does_not_create_false_completion_claim() -> None:
    truth = CommunicationTruth(warning=True)

    assert not truth.can_claim_completion()


def test_in_progress_does_not_claim_completion() -> None:
    truth = CommunicationTruth(in_progress=True)

    assert truth.can_claim_progress()
    assert not truth.can_claim_completion()


def test_completed_state_does_not_require_in_progress_flag() -> None:
    truth = CommunicationTruth(completed=True)

    assert truth.completed
    assert not truth.in_progress
    assert truth.can_claim_completion()


def test_communication_claims_follow_actual_state() -> None:
    waiting = CommunicationTruth()
    working = CommunicationTruth(in_progress=True)
    completed = CommunicationTruth(
        completed=True,
        result_available=True,
    )

    assert waiting.status_message() == "waiting"
    assert working.status_message() == "in_progress"
    assert completed.status_message() == "completed"

    assert not waiting.can_claim_progress()
    assert working.can_claim_progress()
    assert completed.can_claim_completion()
    assert completed.can_claim_result()