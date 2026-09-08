import pytest

from criterivox.domain.analysis import AnalysisTask, AnalysisTaskSource, AnalysisTaskState, InvalidAnalysisTransition


def task():
    return AnalysisTask.create(task="Investigate the supplied context", data={"dataset": "local"}, context={"audience": "research"}, source=AnalysisTaskSource.WORKSPACE)


def test_task_has_single_identity_and_explicit_source():
    item = task()
    assert item.task_id.startswith("AN-")
    assert item.source is AnalysisTaskSource.WORKSPACE
    assert item.state is AnalysisTaskState.CREATED


def test_valid_lifecycle_is_enforced():
    item = task()
    for state in (AnalysisTaskState.RECEIVED, AnalysisTaskState.VALIDATING, AnalysisTaskState.PROCESSING, AnalysisTaskState.ANALYZING, AnalysisTaskState.RESULT_READY):
        item.transition(state)
    assert item.state is AnalysisTaskState.RESULT_READY


def test_invalid_transition_is_rejected():
    with pytest.raises(InvalidAnalysisTransition):
        task().transition(AnalysisTaskState.COMPLETED)


def test_empty_task_is_rejected():
    with pytest.raises(ValueError):
        AnalysisTask.create(task="   ", data={}, context={}, source=AnalysisTaskSource.CHAT)


def test_reference_limit_is_bounded():
    with pytest.raises(ValueError):
        AnalysisTask.create(task="x", data={}, context={}, source=AnalysisTaskSource.CHAT, references=tuple(str(i) for i in range(51)))
