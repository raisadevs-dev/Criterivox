from __future__ import annotations

from dataclasses import dataclass
import re

from .situation import SafetyLevel


@dataclass(frozen=True)
class SafetyAssessment:
    level: SafetyLevel
    reasons: tuple[str, ...]
    questions: tuple[str, ...]


class SituationSafetyRouter:
    """Early safety routing. It does not diagnose or decide facts from images."""

    IMMEDIATE = (
        re.compile(r"\b(?:unsafe|in danger|threatened|attacked|being hurt|being threatened)\b.{0,80}\b(?:right now|currently|at this moment)\b", re.I),
        re.compile(r"\b(?:right now|currently|at this moment)\b.{0,80}\b(?:unsafe|in danger|threatened|attacked|being hurt|being threatened)\b", re.I),
        re.compile(r"\b(?:someone|they|he|she)\b.{0,50}\b(?:is|are|was|were)\s+(?:threatening|attacking|hurting)\b", re.I),
        re.compile(r"\b(?:going to|will)\b.{0,50}\b(?:hurt|attack)\b", re.I),
        re.compile(r"\b(?:help me|help)\b.{0,50}\b(?:danger|unsafe|threat)\b", re.I),
    )
    SENSITIVE = (
        re.compile(r"\b(?:bully|bullying|harass|harassment|threaten|threatening|intimidat|exclude|excluded|coerc|blackmail)\w*\b", re.I),
        re.compile(r"\b(?:hit|punch|push|hurt|follow|corner)\w*\b", re.I),
    )

    def assess(self, text: str) -> SafetyAssessment:
        answer = re.search(r"User safety answer:\s*(yes|no|i'm not sure)\b", text, re.I)
        if answer and answer.group(1).lower() in {"no", "i'm not sure"}:
            return SafetyAssessment(
                SafetyLevel.SENSITIVE,
                ("The user reports no confirmed immediate danger, but the situation remains safety-sensitive.",),
                (
                    "What happened?",
                    "Has this happened more than once?",
                    "Is there a trusted adult or supportive person who knows?",
                ),
            )
        if answer and answer.group(1).lower() == "yes":
            return SafetyAssessment(
                SafetyLevel.IMMEDIATE,
                ("The user reports that they are not safe right now.",),
                ("Are you safe right now?",),
            )
        immediate = [p.pattern for p in self.IMMEDIATE if p.search(text)]
        if immediate:
            return SafetyAssessment(
                SafetyLevel.IMMEDIATE,
                ("The description contains a possible immediate-safety signal.",),
                ("Are you safe right now?",),
            )
        sensitive = [p.pattern for p in self.SENSITIVE if p.search(text)]
        if sensitive:
            return SafetyAssessment(
                SafetyLevel.SENSITIVE,
                ("The description may involve interpersonal harm or coercion.",),
                (
                    "What happened?",
                    "Has this happened more than once?",
                    "Do you feel unsafe right now?",
                    "Is there a trusted adult or supportive person who knows?",
                ),
            )
        return SafetyAssessment(SafetyLevel.ORDINARY, (), ())
