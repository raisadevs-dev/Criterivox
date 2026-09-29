from __future__ import annotations

import json
from pathlib import Path

from .models import (
    CapabilityDefinition,
    CapabilityRegistry,
    CharacterDefinition,
    CharacterRegistry,
    ImplementationStatus,
)


def _project_root() -> Path:
    """Resolve repository root independently of the process working directory."""
    return Path(__file__).resolve().parents[5]


CONFIG_ROOT = _project_root() / "configs" / "character_chat"


def _load(name: str) -> dict:
    with (CONFIG_ROOT / name).open("r", encoding="utf-8") as handle:
        return json.load(handle)


def load_character_registry() -> CharacterRegistry:
    data = _load("character_registry.json")
    return CharacterRegistry(
        tuple(
            CharacterDefinition(
                **{
                    **item,
                    "implementation_status": ImplementationStatus(
                        item["implementation_status"]
                    ),
                }
            )
            for item in data["characters"]
        )
    )


def load_capability_registry() -> CapabilityRegistry:
    data = _load("capability_registry.json")
    return CapabilityRegistry(
        tuple(
            CapabilityDefinition(
                **{
                    **item,
                    "implementation_status": ImplementationStatus(
                        item["implementation_status"]
                    ),
                }
            )
            for item in data["capabilities"]
        )
    )


def load_message_chips() -> dict:
    return _load("message_chips.json")
