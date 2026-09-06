import asyncio

from criterivox.application.analysis_tasks import AnalysisTaskService
from criterivox.domain.analysis import AnalysisTaskSource, AnalysisTaskState


def test_workspace_and_chat_paths_share_the_same_task_model():
    service = AnalysisTaskService()
    workspace = service.create_task(task="Analyze this", data={"a": 1}, context={"c": 1}, source=AnalysisTaskSource.WORKSPACE)
    chat = service.create_task(task="Analyze this", data={"a": 1}, context={"c": 1}, source=AnalysisTaskSource.CHAT)
    assert workspace.task_id != chat.task_id
    assert workspace.task == chat.task
    assert workspace.data == chat.data
    assert workspace.context == chat.context


def test_execution_is_authoritative_and_produces_real_result():
    service = AnalysisTaskService()
    task = service.create_task(task="Analyze this", data={"a": 1, "b": 2}, context={"c": 1}, source=AnalysisTaskSource.WORKSPACE)
    result = asyncio.run(service.execute(task.task_id))
    assert result.state is AnalysisTaskState.COMPLETED
    assert result.result is not None
    assert len(result.result.observations) == 2
    assert len(result.result.findings) == 2


def test_publish_hook_receives_state_changes():
    service = AnalysisTaskService()
    states = []
    async def publish(item):
        states.append(item.state)
    service.publish = publish
    task = service.create_task(task="Analyze this", data={}, context={}, source=AnalysisTaskSource.CHAT)
    asyncio.run(service.execute(task.task_id))
    assert states[0] is AnalysisTaskState.RECEIVED
    assert AnalysisTaskState.ANALYZING in states
    assert states[-1] is AnalysisTaskState.COMPLETED
