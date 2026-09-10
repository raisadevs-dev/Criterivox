from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class ResidenceStatus(str, Enum):
    OWNER = "owner"
    ROOMMATE = "roommate"
    FAMILY = "family"
    CROSS_HOME = "cross_home"


class InteractionStatus(str, Enum):
    ACTIVE = "active"
    GUEST_FRIEND = "guest_friend"
    RESIDENT = "resident"


@dataclass(frozen=True, slots=True)
class CharacterResidence:
    character_id: str
    home_id: str
    home_purpose: str
    residence_status: ResidenceStatus
    interaction_locations: tuple[str, ...]
    interaction_statuses: tuple[InteractionStatus, ...]


RESIDENCE_REGISTRY: dict[str, CharacterResidence] = {
    "sandre": CharacterResidence("sandre", "data_home", "Data Foundation / Data Stewardship", ResidenceStatus.OWNER, ("character_chat", "data_stewardship"), (InteractionStatus.RESIDENT, InteractionStatus.ACTIVE)),
    "kaelen": CharacterResidence("kaelen", "data_home", "Data Foundation / Data Stewardship", ResidenceStatus.ROOMMATE, ("character_chat", "context_workspace"), (InteractionStatus.RESIDENT, InteractionStatus.ACTIVE)),
    "dharen": CharacterResidence("dharen", "context_home", "Context Structuring / Contextual Handoff", ResidenceStatus.OWNER, ("character_chat", "context_workspace", "analysis_workspace"), (InteractionStatus.RESIDENT, InteractionStatus.ACTIVE)),
    "anuka": CharacterResidence("anuka", "context_home", "Context Structuring / Adaptive Context", ResidenceStatus.ROOMMATE, ("character_chat", "context_workspace"), (InteractionStatus.RESIDENT, InteractionStatus.ACTIVE)),
    "vivren": CharacterResidence("vivren", "intelligence_home", "Intelligence / Reasoning", ResidenceStatus.OWNER, ("character_chat",), (InteractionStatus.GUEST_FRIEND,)),
    "tarkis": CharacterResidence("tarkis", "intelligence_home", "Intelligence / Reasoning", ResidenceStatus.FAMILY, ("character_chat",), (InteractionStatus.GUEST_FRIEND,)),
}


def get_residence(character_id: str) -> CharacterResidence:
    return RESIDENCE_REGISTRY[character_id.strip().lower()]


__all__ = ["CharacterResidence", "InteractionStatus", "ResidenceStatus", "RESIDENCE_REGISTRY", "get_residence"]
