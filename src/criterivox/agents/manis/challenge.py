from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from criterivox.human.collaboration_engine import CollaborationEngine

@dataclass(frozen=True)
class ChallengeAssessment:
    text: str
    challenge_type: str
    affected_assumptions: tuple[str,...]=()
    affected_options: tuple[str,...]=()
    severity: str="review"
    def to_dict(self): return {"text":self.text,"challenge_type":self.challenge_type,"affected_assumptions":list(self.affected_assumptions),"affected_options":list(self.affected_options),"severity":self.severity}

class ManisChallenge:
    """Character-owned facade for recording artifact/decision-grounded human challenges."""
    def __init__(self, engine: CollaborationEngine|None=None):
        self.engine=engine or CollaborationEngine()

    def assess(self, text: str, *, challenge_type="assumption", affected_assumptions=(), affected_options=(), severity="review"):
        if not text or not text.strip(): raise ValueError("challenge text is required")
        if challenge_type not in {"assumption","evidence","logic","tradeoff","scope","feasibility","risk","alternative"}:
            raise ValueError("unsupported challenge type")
        return ChallengeAssessment(text.strip(),challenge_type,tuple(affected_assumptions),tuple(affected_options),severity)

    def record(self, session_id: str, actor: str, text: str):
        assessment=self.assess(text)
        return self.engine.challenge(session_id,actor,assessment.text)
