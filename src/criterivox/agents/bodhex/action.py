from __future__ import annotations
from typing import Any, Mapping
from criterivox.character_backbone.operations import OperationEngine

class BodhexActionPreparer:
    """Character-owned facade for governed action-contract preparation.

    Preparation is distinct from execution. Consequential execution remains behind
    OperationEngine authorization and adapter boundaries.
    """
    def __init__(self, engine: OperationEngine|None=None):
        self.engine=engine or OperationEngine()

    def prepare(self, message: str, *, conversation_id="bodhex", context: Mapping[str,Any]|None=None, requested_by="human"):
        result=self.engine.handle({"message":message,"conversation_id":conversation_id,"requested_by":requested_by,"context":dict(context or {})})
        return result

    def prepare_command(self, command_id: str, *, authorization_reference: str|None=None):
        cmd=self.engine.commands[command_id]
        return self.engine.prepare(cmd, authorization_reference=authorization_reference)
