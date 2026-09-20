from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Iterator, overload


class ImplementationStatus(str, Enum):
    CURRENT = "CURRENT"
    PARTIAL = "PARTIAL"
    ARCHITECTURE_DEFINED = "ARCHITECTURE_DEFINED"
    REQUIRED = "REQUIRED"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True)
class CharacterDefinition:
    id: str
    display_name: str
    home: str
    role: str
    domain: str
    purpose: str
    responsibilities: tuple[str, ...] = ()
    capabilities: tuple[str, ...] = ()
    inputs: tuple[str, ...] = ()
    outputs: tuple[str, ...] = ()
    artifacts: tuple[str, ...] = ()
    events: tuple[str, ...] = ()
    state_types: tuple[str, ...] = ()
    storage_dependencies: tuple[str, ...] = ()
    permissions: tuple[str, ...] = ()
    handoff_targets: tuple[str, ...] = ()
    handoff_conditions: tuple[str, ...] = ()
    can_claim: tuple[str, ...] = ()
    cannot_claim: tuple[str, ...] = ()
    failure_responses: tuple[str, ...] = ()
    implementation_status: ImplementationStatus = ImplementationStatus.UNKNOWN
    source_references: tuple[str, ...] = ()


@dataclass(frozen=True)
class CapabilityDefinition:
    capability_id: str
    name: str
    description: str
    owner_character: str
    supporting_characters: tuple[str, ...] = ()
    domain: str = ""
    inputs: tuple[str, ...] = ()
    required_state: tuple[str, ...] = ()
    outputs: tuple[str, ...] = ()
    artifacts_created: tuple[str, ...] = ()
    events_created: tuple[str, ...] = ()
    permissions_required: tuple[str, ...] = ()
    authorization_required: bool = False
    handoff_targets: tuple[str, ...] = ()
    preconditions: tuple[str, ...] = ()
    postconditions: tuple[str, ...] = ()
    implementation_status: ImplementationStatus = ImplementationStatus.UNKNOWN
    failure_modes: tuple[str, ...] = ()


@dataclass(frozen=True)
class HandoffContract:
    sender: str
    receiver: str
    intent: str
    reason: str
    task_id: str
    journey_id: str
    context_reference: str | None
    input_artifacts: tuple[str, ...]
    requested_capability: str
    expected_output: str
    priority: str = "normal"
    status: str = "PROPOSED"
    created_at: str = ""


@dataclass(frozen=True)
class CharacterRegistry:
    characters: tuple[CharacterDefinition, ...]

    def __iter__(self) -> Iterator[CharacterDefinition]:
        return iter(self.characters)

    def __len__(self) -> int:
        return len(self.characters)

    @overload
    def __getitem__(self, index: int) -> CharacterDefinition:
        ...

    @overload
    def __getitem__(
        self,
        index: slice,
    ) -> tuple[CharacterDefinition, ...]:
        ...

    def __getitem__(
        self,
        index: int | slice,
    ) -> CharacterDefinition | tuple[CharacterDefinition, ...]:
        return self.characters[index]

    def by_id(self, character_id: str) -> CharacterDefinition:
        key = character_id.strip().lower()

        for item in self.characters:
            if item.id == key:
                return item

        raise KeyError(key)


@dataclass(frozen=True)
class CapabilityRegistry:
    capabilities: tuple[CapabilityDefinition, ...]

    def __iter__(self) -> Iterator[CapabilityDefinition]:
        return iter(self.capabilities)

    def __len__(self) -> int:
        return len(self.capabilities)

    @overload
    def __getitem__(self, index: int) -> CapabilityDefinition:
        ...

    @overload
    def __getitem__(
        self,
        index: slice,
    ) -> tuple[CapabilityDefinition, ...]:
        ...

    def __getitem__(
        self,
        index: int | slice,
    ) -> CapabilityDefinition | tuple[CapabilityDefinition, ...]:
        return self.capabilities[index]

    def by_id(self, capability_id: str) -> CapabilityDefinition:
        for item in self.capabilities:
            if item.capability_id == capability_id:
                return item

        raise KeyError(capability_id)