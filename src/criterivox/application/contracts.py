from __future__ import annotations

from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, model_validator


CONTRACT_VERSION = 1
MAX_PAYLOAD_BYTES = 32_000
MAX_TOP_LEVEL_FIELDS = 1_000


class ApplicationIntent(str, Enum):
    ANALYZE = "analyze"
    COMPARE = "compare"
    EXPLORE = "explore"
    PLAN = "plan"
    INSIGHTS = "insights"
    EXPLAIN = "explain"


class ApplicationEventType(str, Enum):
    ANALYSIS_REQUESTED = "analysis_requested"
    ANALYSIS_STARTED = "analysis_started"
    ANALYSIS_COMPLETED = "analysis_completed"
    EXPLANATION_REQUESTED = "explanation_requested"
    EXPLANATION_READY = "explanation_ready"


class ApplicationErrorCode(str, Enum):
    INVALID_INPUT = "invalid_input"
    UNSUPPORTED_CAPABILITY = "unsupported_capability"
    MALFORMED_REQUEST = "malformed_request"
    UNKNOWN_EVENT = "unknown_event"
    PROVIDER_FAILURE = "provider_failure"
    TRANSPORT_FAILURE = "transport_failure"
    INTERNAL_ERROR = "internal_error"


class DataContext(BaseModel):
    model_config = ConfigDict(extra="forbid")

    data: dict[str, Any] = Field(default_factory=dict)
    context: dict[str, Any] = Field(default_factory=dict)

    @model_validator(mode="after")
    def validate_limits(self) -> "DataContext":
        if len(self.data) > MAX_TOP_LEVEL_FIELDS or len(self.context) > MAX_TOP_LEVEL_FIELDS:
            raise ValueError("Data or context contains too many top-level fields.")
        return self


class ApplicationRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    contract_version: int = Field(default=CONTRACT_VERSION, ge=1, le=CONTRACT_VERSION)
    intent: ApplicationIntent
    task: str = Field(min_length=1, max_length=500)
    data: dict[str, Any] = Field(default_factory=dict)
    context: dict[str, Any] = Field(default_factory=dict)
    source: str = Field(default="syvax", min_length=1, max_length=40)

    @model_validator(mode="after")
    def validate_limits(self) -> "ApplicationRequest":
        if len(self.data) > MAX_TOP_LEVEL_FIELDS or len(self.context) > MAX_TOP_LEVEL_FIELDS:
            raise ValueError("Request contains too many top-level fields.")
        if len(self.model_dump_json()) > MAX_PAYLOAD_BYTES:
            raise ValueError("Application request is too large.")
        return self


class ApplicationEvent(BaseModel):
    model_config = ConfigDict(extra="forbid")

    contract_version: int = CONTRACT_VERSION
    event_type: ApplicationEventType
    intent: ApplicationIntent
    request_id: str = Field(min_length=1, max_length=80)
    character_id: str | None = Field(default=None, max_length=40)
    result: dict[str, Any] | None = None


class ApplicationResult(BaseModel):
    model_config = ConfigDict(extra="forbid")

    contract_version: int = CONTRACT_VERSION
    request_id: str
    intent: ApplicationIntent
    status: str
    summary: str
    data: dict[str, Any] = Field(default_factory=dict)


class ApplicationError(BaseModel):
    model_config = ConfigDict(extra="forbid")

    contract_version: int = CONTRACT_VERSION
    code: ApplicationErrorCode
    message: str
    request_id: str | None = None


__all__ = [
    "ApplicationError",
    "ApplicationErrorCode",
    "ApplicationEvent",
    "ApplicationEventType",
    "ApplicationIntent",
    "ApplicationRequest",
    "ApplicationResult",
    "CONTRACT_VERSION",
    "DataContext",
]
