from criterivox.domain.characters.communication_truth import (
    CommunicationTruth,
)


def test_waiting_state_cannot_claim_progress() -> None:
    truth = CommunicationTruth()

    assert truth.status_message() == "waiting"
    assert not truth.can_claim_progress()
    assert not truth.can_claim_completion()
    assert not truth.can_claim_result()


def test_in_progress_state_can_claim_progress() -> None:
    truth = CommunicationTruth(in_progress=True)

    assert truth.status_message() == "in_progress"
    assert truth.can_claim_progress()
    assert not truth.can_claim_completion()


def test_completed_state_can_claim_completion() -> None:
    truth = CommunicationTruth(completed=True)

    assert truth.status_message() == "completed"
    assert truth.can_claim_progress()
    assert truth.can_claim_completion()


def test_result_available_can_claim_result() -> None:
    truth = CommunicationTruth(
        completed=True,
        result_available=True,
    )

    assert truth.can_claim_result()


def test_warning_takes_priority_in_status() -> None:
    truth = CommunicationTruth(
        in_progress=True,
        warning=True,
    )

    assert truth.status_message() == "warning"
    assert truth.can_claim_warning()


def test_warning_does_not_claim_completion() -> None:
    truth = CommunicationTruth(warning=True)

    assert not truth.can_claim_completion()


def test_result_without_completion_is_allowed() -> None:
    truth = CommunicationTruth(result_available=True)

    assert truth.can_claim_result()
    assert not truth.can_claim_completion()


def test_communication_truth_is_immutable() -> None:
    truth = CommunicationTruth()

    assert truth.completed is False
    assert truth.in_progress is False


def test_completed_and_progress_flags_are_independent() -> None:
    truth = CommunicationTruth(
        completed=True,
        in_progress=False,
    )

    assert truth.completed
    assert not truth.in_progress
    assert truth.can_claim_completion()