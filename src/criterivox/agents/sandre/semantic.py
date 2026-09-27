"""Sandre semantic enrichment capability facade."""
from __future__ import annotations
from typing import Any
from ..application.s5_advanced_runtime import SemanticTagger, SchemaDriftHealer

class SandreSemantic:
    def __init__(self) -> None:
        self.tagger=SemanticTagger()
        self.schema=SchemaDriftHealer()
    def enrich(self, rows: list[dict[str,Any]], context: dict[str,Any]) -> dict[str,Any]:
        return self.tagger.tag(rows,context)
    def inspect_drift(self, old: list[str], new: list[str]) -> dict[str,Any]:
        return self.schema.diff(old,new)
    def propose_repair(self, rows: list[dict[str,Any]], old: list[str], new: list[str], aliases: dict[str,str]|None=None) -> dict[str,Any]:
        return self.schema.patch(rows,old,new,aliases)

__all__=["SandreSemantic"]
