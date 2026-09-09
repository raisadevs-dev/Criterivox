from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from difflib import SequenceMatcher
from typing import Any, Iterable

from criterivox.domain.data_foundation import ConfirmationStatus, DataFoundation

ALLOWED_RECIPIENTS = frozenset({"syvax", "dharen", "kaelen"})
CONFIRMED_STATUSES = frozenset({ConfirmationStatus.USER_CONFIRMED, ConfirmationStatus.USER_CORRECTED})

@dataclass(frozen=True, slots=True)
class IntentGuess:
    label: str
    score: float
    evidence: tuple[str, ...] = ()

@dataclass(frozen=True, slots=True)
class SchemaPreflight:
    matched_fields: tuple[str, ...]
    unmatched_fields: tuple[str, ...]
    match_ratio: float
    auto_fill: bool
    requires_clarification: bool

@dataclass(frozen=True, slots=True)
class PreviewReport:
    foundation_id: str
    material_set_id: str
    question: str
    source_count: int
    candidate_count: int
    fields: tuple[str, ...]
    anomalies: int
    missingness: int
    confirmation_status: str
    intent_guesses: tuple[IntentGuess, ...] = ()
    schema_preflight: SchemaPreflight | None = None

@dataclass(frozen=True, slots=True)
class StewardshipLogEntry:
    material_set_id: str
    foundation_id: str
    timestamp: str
    task_ids: tuple[str, ...] = ()
    event: str = "MATERIAL_RECEIVED"
    detail: str = ""
    recipient: str | None = None

@dataclass(frozen=True, slots=True)
class ConflictResolution:
    field: str
    home_value: Any
    chat_value: Any
    winner: str
    result: Any

@dataclass
class SandreStewardship:
    """S5 stewardship policies. Research semantics are never inferred here."""
    logs: list[StewardshipLogEntry] = field(default_factory=list)
    approved_intents: dict[str, str] = field(default_factory=dict)
    conditional_provenance: dict[str, dict[str, bool]] = field(default_factory=dict)

    def predict_intent(self, *, source_name: str, source_type: str, recent_task_ids: Iterable[str] = (), prompt_history: Iterable[str] = ()) -> tuple[IntentGuess, ...]:
        text = " ".join((source_name, source_type, *recent_task_ids, *prompt_history)).lower()
        rules = {
            "analysis material": ("analysis", "analyze", "dataset", "data", "csv", "excel"),
            "research evidence": ("paper", "study", "research", "evidence", "literature", "report"),
            "context material": ("context", "background", "requirement", "brief", "notes"),
            "reference material": ("reference", "source", "citation", "url", "link"),
            "supporting material": ("file", "document", "folder", "attachment"),
        }
        scored = []
        for label, keywords in rules.items():
            hits = tuple(k for k in keywords if k in text)
            score = min(0.99, 0.25 + 0.12 * len(hits)) if hits else 0.05
            scored.append(IntentGuess(label, round(score, 3), hits))
        return tuple(sorted(scored, key=lambda item: (-item.score, item.label))[:3])

    def approve_intent(self, foundation_id: str, label: str, allowed: Iterable[str]) -> str:
        value = str(label).strip()
        if value not in {str(x).strip() for x in allowed}:
            raise ValueError("Intent approval must select one of the presented guesses.")
        self.approved_intents[foundation_id] = value
        return value

    @staticmethod
    def schema_preflight(supplied_fields: Iterable[str], expected_fields: Iterable[str], *, threshold: float = 0.80) -> SchemaPreflight:
        supplied = {str(v).strip() for v in supplied_fields if str(v).strip()}
        expected = {str(v).strip() for v in expected_fields if str(v).strip()}
        if not expected:
            return SchemaPreflight(tuple(sorted(supplied)), (), 0.0, False, True)
        matched: set[str] = set()
        for field in supplied:
            if field in expected:
                matched.add(field)
                continue
            best = max((SequenceMatcher(None, field.lower(), candidate.lower()).ratio(), candidate) for candidate in expected)
            if best[0] >= 0.90:
                matched.add(best[1])
        ratio = len(matched) / len(expected)
        return SchemaPreflight(tuple(sorted(matched)), tuple(sorted(expected - matched)), round(ratio, 3), ratio >= threshold, ratio < threshold)

    def preview(self, foundation: DataFoundation, *, material_set_id: str | None = None, intent_guesses: tuple[IntentGuess, ...] = (), schema_preflight: SchemaPreflight | None = None) -> PreviewReport:
        fields = tuple(sorted({key for row in foundation.canonical_data for key in row}))
        return PreviewReport(foundation.foundation_id, material_set_id or foundation.foundation_id, "Is this what you intended to submit?", len(foundation.sources), len(foundation.candidates), fields, foundation.quality.anomaly_count, foundation.quality.missing_count, foundation.confirmation_status.value, intent_guesses, schema_preflight)

    @staticmethod
    def route(recipient: str) -> str:
        target = recipient.strip().lower()
        if target not in ALLOWED_RECIPIENTS:
            raise ValueError("Unsupported stewardship recipient.")
        return target

    @staticmethod
    def can_handoff(foundation: DataFoundation) -> bool:
        return foundation.confirmation_status in CONFIRMED_STATUSES

    def set_conditional_provenance(self, foundation_id: str, choices: dict[str, bool]) -> dict[str, bool]:
        clean = {str(k).strip(): bool(v) for k, v in choices.items() if str(k).strip()}
        self.conditional_provenance[foundation_id] = clean
        return dict(clean)

    def record(self, foundation: DataFoundation, *, task_ids: Iterable[str] = (), event: str = "MATERIAL_RECEIVED", detail: str = "", recipient: str | None = None) -> StewardshipLogEntry:
        entry = StewardshipLogEntry(foundation.foundation_id, foundation.foundation_id, datetime.now(timezone.utc).isoformat(), tuple(str(v) for v in task_ids if str(v).strip()), event, detail, self.route(recipient) if recipient else None)
        self.logs.append(entry)
        return entry

    def search_logs(self, query: str = "") -> tuple[StewardshipLogEntry, ...]:
        needle = query.strip().lower()
        if not needle:
            return tuple(reversed(self.logs))
        return tuple(entry for entry in reversed(self.logs) if needle in " ".join((entry.material_set_id, entry.foundation_id, entry.timestamp, entry.event, entry.detail, entry.recipient or "", *entry.task_ids)).lower())

    @staticmethod
    def merge_conflicts(home: dict[str, Any], chat: dict[str, Any], winners: dict[str, str]) -> tuple[dict[str, Any], tuple[ConflictResolution, ...]]:
        fields = sorted(set(home) | set(chat))
        merged: dict[str, Any] = {}
        resolutions: list[ConflictResolution] = []
        for field in fields:
            hv, cv = home.get(field), chat.get(field)
            if hv == cv:
                merged[field] = hv if field in home else cv
                continue
            winner = winners.get(field)
            if winner not in {"home", "chat"}:
                raise ValueError(f"Conflict requires an explicit winner for field '{field}'.")
            result = hv if winner == "home" else cv
            merged[field] = result
            resolutions.append(ConflictResolution(field, hv, cv, winner, result))
        return merged, tuple(resolutions)

__all__ = ["ALLOWED_RECIPIENTS", "CONFIRMED_STATUSES", "ConflictResolution", "IntentGuess", "PreviewReport", "SandreStewardship", "SchemaPreflight", "StewardshipLogEntry"]
