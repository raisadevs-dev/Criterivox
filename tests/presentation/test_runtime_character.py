import asyncio
import json

import pytest

from criterivox.infrastructure.runtime import (
    AnalysisRequest,
    DharenRuntime,
    RuntimeConnectionManager,
    parse_analysis_request,
)


class _Client:
    def __init__(self) -> None:
        self.messages: list[str] = []

    async def send_text(self, message: str) -> None:
        self.messages.append(message)


def test_dharen_runtime_emits_complete_lifecycle(monkeypatch) -> None:
    async def no_sleep(_: float) -> None:
        return None

    monkeypatch.setattr(
        "criterivox.infrastructure.runtime.asyncio.sleep",
        no_sleep,
    )

    connections = RuntimeConnectionManager()
    client = _Client()
    connections.clients.add(client)
    runtime = DharenRuntime(connections)

    asyncio.run(
        runtime.run_analysis(
            AnalysisRequest(
                data={"views": 1200, "likes": 84},
                context={"platform": "synthetic"},
                task="Analyze the supplied data in context.",
            )
        )
    )

    states = [json.loads(message)["character_state"] for message in client.messages]
    assert states == ["receive", "work", "communicate", "complete", "idle"]


def test_invalid_request_is_rejected() -> None:
    with pytest.raises(ValueError):
        parse_analysis_request(
            {
                "data": {},
                "context": {},
                "task": "",
            }
        )
