from __future__ import annotations
from dataclasses import dataclass, field
from enum import StrEnum
from typing import Any

class SituationLevel(StrEnum):
    HISTORY="HISTORY"; CURRENT="CURRENT"; NEXT="NEXT"

class TruthClass(StrEnum):
    RECORDED_FACT="RECORDED_FACT"; DERIVED_STATE="DERIVED_STATE"; PROJECTION="PROJECTION"
    UNKNOWN="UNKNOWN"; UNIMPLEMENTED="UNIMPLEMENTED"; BLOCKED="BLOCKED"

class NextType(StrEnum):
    RECORDED_NEXT_STEP="RECORDED_NEXT_STEP"; MULTIPLE_ELIGIBLE_STEPS="MULTIPLE_ELIGIBLE_STEPS"
    BLOCKED="BLOCKED"; NO_REMAINING_STEPS="NO_REMAINING_STEPS"; NOT_DETERMINED="NOT_DETERMINED"

@dataclass(frozen=True, slots=True)
class Journey:
    journey_id:str; conversation_id:str; task_id:str; goal:str; status:str
    created_at:str; updated_at:str; context_reference:str|None=None

@dataclass(frozen=True, slots=True)
class Checkpoint:
    checkpoint_id:str; journey_id:str; task_id:str; timestamp:str; current_step:str|None
    completed_steps:tuple[str,...]=(); active_step:str|None=None; remaining_steps:tuple[str,...]=()
    active_character:str|None=None; active_capability:str|None=None; state:str="UNKNOWN"
    blocked_reason:str|None=None; waiting_for:str|None=None; context_version:int=0
    artifact_refs:tuple[str,...]=(); event_refs:tuple[str,...]=()

@dataclass(frozen=True, slots=True)
class ExecutionEvent:
    event_id:str; journey_id:str; task_id:str; timestamp:str; event_type:str; actor:str
    capability:str|None=None; input_refs:tuple[str,...]=(); output_refs:tuple[str,...]=()
    previous_state:str|None=None; new_state:str|None=None; caused_by:str|None=None
    parent_event:str|None=None; status:str="RECORDED"; provenance:dict[str,Any]=field(default_factory=dict)

@dataclass(frozen=True, slots=True)
class SituationAwarenessResponse:
    level:SituationLevel
    history:tuple[dict[str,Any],...]=()
    current:dict[str,Any]|None=None
    next:dict[str,Any]|None=None
    blocking:dict[str,Any]|None=None
    changes:tuple[dict[str,Any],...]=()
    uncertainty:tuple[str,...]=()
    sources:tuple[str,...]=()
    truth_class:TruthClass=TruthClass.UNKNOWN
    status:str="NO_AUTHORITATIVE_RECORD"

    def to_dict(self)->dict[str,Any]:
        return {"level":self.level.value,"history":list(self.history),"current":self.current,"next":self.next,
                "blocking":self.blocking,"changes":list(self.changes),"uncertainty":list(self.uncertainty),
                "sources":list(self.sources),"truth_class":self.truth_class.value,"status":self.status}

@dataclass(frozen=True, slots=True)
class StateResolution:
    conversation_id:str|None; task_id:str|None; journey_id:str|None; ambiguous:bool=False
    candidates:tuple[str,...]=()
