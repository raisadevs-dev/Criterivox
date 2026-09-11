from criterivox.application.failure_telemetry import FailureTelemetry, FailureType


def test_failure_telemetry_records_recoverable_failure() -> None:
    telemetry = FailureTelemetry()
    event = telemetry.record(
        task_id="TASK-1",
        failure_type=FailureType.CONTEXT_MISMATCH,
        character_id="anuka",
        summary="The supplied requirement does not fit the current context.",
        evidence=("context-check-1",),
    )

    assert event.failure_type is FailureType.CONTEXT_MISMATCH
    assert telemetry.latest("TASK-1") == event
    assert telemetry.for_task("TASK-1") == (event,)
