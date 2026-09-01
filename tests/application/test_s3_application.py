import pytest
from pydantic import ValidationError

from criterivox.application.contracts import (
    ApplicationIntent,
    ApplicationRequest,
    ApplicationEventType,
)
from criterivox.application.service import (
    ApplicationService,
    UnsupportedCapabilityError,
)
from criterivox.application.provider import DeterministicAnalysisProvider


def make_request(intent=ApplicationIntent.ANALYZE):
    return ApplicationRequest(
        intent=intent,
        task="Analyze the supplied synthetic data.",
        data={"views": 1200, "likes": 84},
        context={"platform": "synthetic", "audience": "students"},
        source="syvax",
    )


def test_application_request_rejects_unknown_fields():
    with pytest.raises(ValidationError):
        ApplicationRequest(
            intent="analyze",
            task="test",
            unexpected="not allowed",
        )


def test_analysis_uses_provider_and_returns_structured_result():
    events = []
    service = ApplicationService(
        provider=DeterministicAnalysisProvider(),
        event_sink=events.append,
    )
    result = service.handle(make_request())

    assert result.status == "completed"
    assert result.intent is ApplicationIntent.ANALYZE
    assert result.data["data_items"] == 2
    assert events[0].event_type is ApplicationEventType.ANALYSIS_STARTED
    assert events[1].event_type is ApplicationEventType.ANALYSIS_COMPLETED
    assert events[1].character_id == "Dharen"


def test_reserved_capability_is_explicitly_unsupported():
    service = ApplicationService(provider=DeterministicAnalysisProvider())
    with pytest.raises(UnsupportedCapabilityError):
        service.handle(make_request(ApplicationIntent.COMPARE))


def test_request_size_limit_is_preserved():
    with pytest.raises(ValidationError):
        ApplicationRequest(
            intent="analyze",
            task="x",
            data={str(i): i for i in range(1001)},
        )
