from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from .set4 import Set4Runtime, DecisionRecord, ChallengeRecord, OutcomeRecord, KnowledgeRecord, TransferRecord
from uuid import uuid4
from datetime import datetime, timezone
def now(): return datetime.now(timezone.utc).isoformat()
@dataclass(frozen=True, slots=True)
class GovernanceResult: record_id:str; status:str; workflow_outcome:str
class GovernanceService:
 def __init__(self,runtime=None): self.runtime=runtime or Set4Runtime()
 def challenge(self,journey_id,target_type,target_id,human_input,challenge_type="ASSUMPTION",objection=""):
  r=ChallengeRecord(f"CH-{uuid4()}",journey_id,target_type,target_id,human_input,challenge_type,objection,created_at=now())
  return GovernanceResult(self.runtime.record_challenge(r),"PERSISTED","challenge_persisted")
 def decision(self,journey_id,options,selected_option,human_actor,rationale=None,modification=None):
  r=DecisionRecord(f"DEC-{uuid4()}",journey_id,tuple(options),None,(),selected_option,human_actor,modification,rationale,(),(),(),"PENDING",now())
  return GovernanceResult(self.runtime.record_decision(r),"RECORDED","decision_recorded")
 def outcome(self,record:OutcomeRecord):
  return GovernanceResult(self.runtime.record_outcome(record),"RECORDED","result_recorded")
