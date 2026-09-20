from __future__ import annotations
import json
from pathlib import Path
import yaml
from .models import CharacterDefinition, CharacterRegistry, CapabilityDefinition, CapabilityRegistry, ImplementationStatus

ROOT=Path(__file__).resolve().parents[3]
CONFIG_ROOT=ROOT/"configs"/"character_chat"

def _load(name):
    path=CONFIG_ROOT/name
    with path.open("r",encoding="utf-8") as f:
        if path.suffix in {".yaml", ".yml"}:
            return yaml.safe_load(f)
        return json.load(f)

def load_character_registry():
    data=_load("character_registry.yaml")
    return CharacterRegistry(tuple(CharacterDefinition(**{**x,"implementation_status":ImplementationStatus(x["implementation_status"])}) for x in data["characters"]))

def load_capability_registry():
    data=_load("capability_registry.yaml")
    return CapabilityRegistry(tuple(CapabilityDefinition(**{**x,"implementation_status":ImplementationStatus(x["implementation_status"])}) for x in data["capabilities"]))

def load_message_chips():
    return _load("message_chips.v2.json")
