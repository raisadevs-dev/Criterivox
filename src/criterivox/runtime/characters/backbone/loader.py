from __future__ import annotations
import json
from pathlib import Path
from .models import CharacterDefinition, CharacterRegistry, CapabilityDefinition, CapabilityRegistry, ImplementationStatus

ROOT=Path(__file__).resolve().parents[3]
CONFIG_ROOT=ROOT/"configs"/"character_chat"

def _load(name):
    with (CONFIG_ROOT/name).open("r",encoding="utf-8") as f:return json.load(f)

def load_character_registry():
    data=_load("character_registry.json")
    return CharacterRegistry(tuple(CharacterDefinition(**{**x,"implementation_status":ImplementationStatus(x["implementation_status"])}) for x in data["characters"]))

def load_capability_registry():
    data=_load("capability_registry.json")
    return CapabilityRegistry(tuple(CapabilityDefinition(**{**x,"implementation_status":ImplementationStatus(x["implementation_status"])}) for x in data["capabilities"]))

def load_message_chips():
    return _load("message_chips.json")
