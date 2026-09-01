from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

from .contracts import (
    ApplicationError,
    ApplicationErrorCode,
    ApplicationEvent,
    ApplicationEventType,
    ApplicationRequest,
    ApplicationResult,
)
from .provider import AnalysisProvider, DeterministicAnalysisProvider


class UnsupportedCapabilityError(ValueError):
    """Raised when a reserved capability has no S3 implementation."""


@dataclass
class ApplicationService:
    """Application boundary shared by Syvax and Bloom."""

    provider: AnalysisProvider
    event_sink: Callable[[ApplicationEvent], None] | None = None

    def handle(self, request: ApplicationRequest) -> ApplicationResult:
        if request.intent.value != "analyze":
            raise UnsupportedCapabilityError(
                f"Capability '{request.intent.value}' is reserved for a future sprint."
            )

        result = self.provider.analyze(
            data=request.data,
            context=request.context,
            task=request.task,
        )
        request_id = self._request_id(request)
        self._emit(
            ApplicationEvent(
                event_type=ApplicationEventType.ANALYSIS_STARTED,
                intent=request.intent,
                request_id=request_id,
            )
        )
        self._emit(
            ApplicationEvent(
                event_type=ApplicationEventType.ANALYSIS_COMPLETED,
                intent=request.intent,
                request_id=request_id,
                character_id="Dharen",
                result=result,
            )
        )
        return ApplicationResult(
            request_id=request_id,
            intent=request.intent,
            status="completed",
            summary=(
                f"Analysis completed: {result['data_items']} data items across "
                f"{result['data_fields']} fields; {result['context_fields']} context fields considered."
            ),
            data=result,
        )

    def error(self, code: ApplicationErrorCode, message: str) -> ApplicationError:
        return ApplicationError(code=code, message=message)

    @staticmethod
    def _request_id(request: ApplicationRequest) -> str:
        return f"{request.source}-{abs(hash(request.model_dump_json())):x}"

    def _emit(self, event: ApplicationEvent) -> None:
        if self.event_sink is not None:
            self.event_sink(event)


application_service = ApplicationService(
    provider=DeterministicAnalysisProvider(),
)

__all__ = [
    "ApplicationService",
    "UnsupportedCapabilityError",
    "application_service",
]
