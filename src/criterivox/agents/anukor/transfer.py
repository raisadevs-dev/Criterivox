from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Mapping
from criterivox.runtime.characters.backbone.set4 import TransferRecord

@dataclass(frozen=True)
class TransferAssessment:
    source_home: str
    destination_home: str
    source_artifact: str
    compatibility: str
    adaptation_required: bool
    adaptation_reference: str|None
    status: str
    reason: str
    def to_dict(self): return self.__dict__.copy()

class AnukorTransfer:
    """Assess and record cross-home transfer without silently claiming success."""
    def __init__(self, store_service):
        self.store_service=store_service

    def assess(self, *, source_home: str, destination_home: str, source_artifact: str,
               source_context: str|None=None, target_context: str|None=None,
               compatibility: str="UNKNOWN", adaptation_required: bool=False,
               adaptation_reference: str|None=None) -> TransferAssessment:
        if not source_home or not destination_home or not source_artifact:
            raise ValueError("source_home, destination_home and source_artifact are required")
        same=source_home==destination_home
        if same:
            return TransferAssessment(source_home,destination_home,source_artifact,"INAPPLICABLE",False,None,"REJECTED","Source and destination homes are identical.")
        if compatibility not in {"COMPATIBLE","CONDITIONAL","INCOMPATIBLE","UNKNOWN"}:
            raise ValueError("compatibility must be COMPATIBLE, CONDITIONAL, INCOMPATIBLE or UNKNOWN")
        if compatibility=="INCOMPATIBLE":
            return TransferAssessment(source_home,destination_home,source_artifact,compatibility,False,None,"REJECTED","Transfer is incompatible with the target context.")
        if compatibility in {"CONDITIONAL","UNKNOWN"} and not adaptation_required:
            return TransferAssessment(source_home,destination_home,source_artifact,compatibility,True,adaptation_reference,"ADAPTATION_REQUIRED","Target compatibility is conditional or unknown.")
        return TransferAssessment(source_home,destination_home,source_artifact,compatibility,adaptation_required,adaptation_reference,"READY_FOR_TRANSFER","Transfer conditions are recorded; delivery is not claimed.")

    def record(self, *, journey_id: str, transfer_id: str, source_home: str,
               destination_home: str, source_artifact: str, status: str,
               compatibility: str, adaptation_required: bool,
               source_context: str|None=None, target_context: str|None=None,
               adaptation_reference: str|None=None) -> str:
        record=TransferRecord(
            transfer_id=transfer_id, journey_id=journey_id, source_home=source_home,
            destination_home=destination_home, source_artifact=source_artifact,
            source_context=source_context, target_context=target_context,
            compatibility=compatibility, adaptation_required=adaptation_required,
            adaptation_reference=adaptation_reference, status=status)
        return self.store_service.record_transfer(record)
