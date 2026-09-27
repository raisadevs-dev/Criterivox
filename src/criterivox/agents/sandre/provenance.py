"""Sandre provenance capability facade over the shared provenance ledger."""
from __future__ import annotations
from typing import Any
from ..application.s5_advanced_runtime import ProvenanceLedger

class SandreProvenance:
    def __init__(self) -> None: self.ledger=ProvenanceLedger()
    def record(self, foundation_id: str, event: str, snapshot: dict[str,Any]): return self.ledger.append(foundation_id,event,snapshot)
    def timeline(self, foundation_id: str): return self.ledger.timeline(foundation_id)
    def rewind(self, foundation_id: str, revision: int): return self.ledger.rewind(foundation_id,revision)

__all__=["SandreProvenance"]
