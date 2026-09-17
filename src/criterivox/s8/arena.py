"""Dependency-free local layered NLP boundary for S8 Debate Arena.

This is intentionally conservative: it structures human language into candidate
operations and never claims that language parsing establishes truth.
"""
from __future__ import annotations

from dataclasses import dataclass
import re


@dataclass(frozen=True)
class ArenaInterpretation:
    operation: str
    targets: tuple[str, ...]
    evidence_mentions: tuple[str, ...]
    proposed_alternative: str
    uncertainty: tuple[str, ...]


class LocalLayeredNLP:
    """Deterministic lexical parser used as an inspectable NLP boundary."""

    _challenge = re.compile(r"\b(challenge|wrong|incorrect|disagree|reconsider)\b", re.I)
    _evidence = re.compile(r"\b(evidence|source|citation|document|record)\b", re.I)
    _explain = re.compile(r"\b(why|explain|reason|basis|provenance)\b", re.I)

    def interpret(self, text: str, *, artifact_ids: tuple[str, ...] = ()) -> ArenaInterpretation:
        operation = "challenge" if self._challenge.search(text) else "explain" if self._explain.search(text) else "inspect"
        evidence = ("human-mentioned-evidence",) if self._evidence.search(text) else ()
        uncertainty = ("natural-language interpretation is provisional",)
        return ArenaInterpretation(operation, artifact_ids, evidence, text if operation == "challenge" else "", uncertainty)


class DebateArena:
    def __init__(self) -> None:
        self.nlp = LocalLayeredNLP()

    def interpret(self, text: str, *, artifact_ids: tuple[str, ...] = ()) -> ArenaInterpretation:
        return self.nlp.interpret(text, artifact_ids=artifact_ids)
