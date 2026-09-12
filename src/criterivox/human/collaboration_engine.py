"""Human collaboration runtime for Gate 2.

Implements the agreed A-G runtime contract:
A) collaboration domain/session model and persistence
B) role/permission enforcement
C) Syvax -> candidate context -> human confirmation -> Dharen diff
D) adaptive consensus threshold with risk-aware escalation
E) Owner + N designated Resident multi-signatory action gate and receipt
F) shared outcome journal and attribution
G) Medrus/Viveda learning proposal -> human approval -> dataset/model update proposal

The engine is intentionally local-runtime infrastructure. It does not claim to
be a production identity provider, HSM, enclave, or cryptographic signing
service. Receipts are tamper-evident hashes over the authoritative event.
"""
from __future__ import annotations

from dataclasses import dataclass, asdict, field
from datetime import datetime, timezone
from pathlib import Path
from threading import RLock
from typing import Any
import hashlib, json, uuid

ROOT = Path("data/runtime")
STORE = ROOT / "collaboration_sessions.json"
LEARNING_STORE = ROOT / "learning_proposals.json"

ROLES = {"owner", "resident", "guest"}
PERMISSIONS = {
    "owner": {"read", "comment", "vote", "edit_context", "challenge", "execute", "sign", "manage_members", "approve_learning"},
    "resident": {"read", "comment", "vote", "edit_context", "challenge", "sign"},
    "guest": {"read", "comment"},
}
VISIBILITY = {"PUBLIC_TO_ROOM", "RESIDENT_ONLY", "OWNER_CONFIDENTIAL"}

@dataclass
class CollaborationMember:
    member_id: str
    display_name: str
    role: str
    active: bool = True

@dataclass
class CollaborationSession:
    session_id: str
    residence_id: str
    owner_id: str
    created_at: str
    members: list[dict[str, Any]] = field(default_factory=list)
    visibility: str = "PUBLIC_TO_ROOM"
    risk_level: str = "moderate"
    consensus_threshold: int = 70
    votes: dict[str, dict[str, str]] = field(default_factory=lambda: {"Option A": {}, "Option B": {}, "Option C": {}})
    threads: list[dict[str, Any]] = field(default_factory=list)
    candidate_context: list[dict[str, Any]] = field(default_factory=list)
    context_diffs: list[dict[str, Any]] = field(default_factory=list)
    challenges: list[dict[str, Any]] = field(default_factory=list)
    required_signatories: int = 1
    signatures: dict[str, dict[str, Any]] = field(default_factory=dict)
    outcomes: list[dict[str, Any]] = field(default_factory=list)

class CollaborationEngine:
    def __init__(self) -> None:
        self._lock = RLock()
        self.sessions: dict[str, CollaborationSession] = {}
        self._load()

    def _load(self) -> None:
        ROOT.mkdir(parents=True, exist_ok=True)
        if STORE.exists():
            try:
                raw = json.loads(STORE.read_text())
                self.sessions = {k: CollaborationSession(**v) for k, v in raw.items()}
            except (OSError, ValueError, TypeError):
                self.sessions = {}

    def _save(self) -> None:
        ROOT.mkdir(parents=True, exist_ok=True)
        tmp = STORE.with_suffix(".tmp")
        tmp.write_text(json.dumps({k: asdict(v) for k, v in self.sessions.items()}, indent=2, default=str))
        tmp.replace(STORE)

    def _member(self, s: CollaborationSession, member_id: str) -> CollaborationMember | None:
        for m in s.members:
            if m.get("member_id") == member_id or m.get("display_name") == member_id:
                return CollaborationMember(str(m.get("member_id", "")), str(m.get("display_name", "")), str(m.get("role", "guest")), bool(m.get("active", True)))
        return None

    def _require(self, s: CollaborationSession, member_id: str, permission: str) -> CollaborationMember:
        m = self._member(s, member_id)
        if m is None or not m.active or permission not in PERMISSIONS.get(m.role, set()):
            raise PermissionError(f"member lacks permission: {permission}")
        return m

    def create(self, residence_id: str, owner_id: str, owner_name: str = "House Owner") -> dict[str, Any]:
        with self._lock:
            sid = f"collab-{uuid.uuid4().hex[:18]}"
            s = CollaborationSession(sid, residence_id, owner_id, datetime.now(timezone.utc).isoformat(), [{"member_id": owner_id, "display_name": owner_name, "role": "owner", "active": True}])
            self.sessions[sid] = s; self._save(); return self.snapshot(sid, owner_id)

    def get_or_create(self, residence_id: str, owner_id: str, owner_name: str = "House Owner") -> dict[str, Any]:
        for s in self.sessions.values():
            if s.residence_id == residence_id and s.owner_id == owner_id:
                return self.snapshot(s.session_id, owner_id)
        return self.create(residence_id, owner_id, owner_name)

    def add_member(self, sid: str, actor: str, display_name: str, role: str = "resident", member_id: str | None = None) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "manage_members")
            if role not in ROLES or role == "owner": raise ValueError("only resident or guest may be added")
            mid = member_id or f"member-{uuid.uuid4().hex[:12]}"
            s.members.append({"member_id": mid, "display_name": display_name, "role": role, "active": True}); self._save()
            return self.snapshot(sid, actor)

    def configure(self, sid: str, actor: str, *, risk_level: str | None = None, required_signatories: int | None = None, visibility: str | None = None) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "manage_members")
            if risk_level is not None:
                s.risk_level = str(risk_level)
                s.consensus_threshold = {"low": 55, "moderate": 70, "high": 80, "critical": 90}.get(s.risk_level, 70)
            if required_signatories is not None: s.required_signatories = max(1, int(required_signatories))
            if visibility is not None:
                if visibility not in VISIBILITY: raise ValueError("invalid visibility")
                s.visibility = visibility
            self._save(); return self.snapshot(sid, actor)

    def comment(self, sid: str, actor: str, text: str, visibility: str = "PUBLIC_TO_ROOM") -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "comment")
            if visibility not in VISIBILITY: raise ValueError("invalid visibility")
            event = {"id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "actor": actor, "type": "thread_comment", "text": text, "visibility": visibility}
            s.threads.append(event); self._save(); return event

    def classify_context(self, sid: str, actor: str, text: str, *, confirm: bool = False, variable_type: str = "constraint") -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "comment")
            lowered = text.lower()
            kind = "goal" if any(x in lowered for x in ("goal", "objective", "need to")) else "data" if any(x in lowered for x in ("data", "evidence", "dataset", "metric", "result")) else "constraint" if any(x in lowered for x in ("must", "cannot", "limit", "budget", "deadline", "risk", "constraint")) else "discussion"
            candidate = {"id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "source_actor": actor, "raw_text": text, "classification": kind, "variable_type": variable_type, "status": "confirmed" if confirm else "candidate", "syvax": {"stage": "classification", "route": ["Syvax", "human_confirmation", "Dharen"]}}
            if kind == "discussion" and not confirm: candidate["status"] = "excluded_from_authoritative_context"
            s.candidate_context.append(candidate); self._save(); return candidate

    def confirm_context(self, sid: str, actor: str, candidate_id: str, accepted: bool) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "edit_context")
            candidate = next((x for x in s.candidate_context if x["id"] == candidate_id), None)
            if candidate is None: raise KeyError("candidate context not found")
            before = next((x for x in s.context_diffs if x.get("candidate_id") == candidate_id), None)
            candidate["status"] = "confirmed" if accepted else "rejected"
            diff = {"diff_id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "candidate_id": candidate_id, "actor": actor, "operation": "ADD" if accepted else "REJECT", "variable": candidate.get("variable_type"), "value": candidate.get("raw_text"), "source": "human_confirmed", "dharen": {"frame_action": "CONTEXT_ADD" if accepted else "CONTEXT_REJECT", "deterministic_authority": True}}
            if accepted: s.context_diffs.append(diff)
            self._save(); return {"candidate": candidate, "context_diff": diff, "previous": before}

    def vote(self, sid: str, actor: str, option: str) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "vote")
            if option not in s.votes: raise ValueError("unknown option")
            for votes in s.votes.values(): votes.pop(actor, None)
            s.votes[option][actor] = datetime.now(timezone.utc).isoformat(); self._save(); return self.consensus(sid)

    def consensus(self, sid: str) -> dict[str, Any]:
        s = self.sessions[sid]; counts = {k: len(v) for k, v in s.votes.items()}; total = sum(counts.values()); leader = max(counts, key=counts.get) if total else None; pct = round((counts[leader] / total) * 100) if leader and total else 0
        return {"counts": counts, "total": total, "leader": leader, "consensus_percent": pct, "threshold": s.consensus_threshold, "aligned": bool(leader and pct >= s.consensus_threshold), "manis_friction": bool(total and pct < s.consensus_threshold), "risk_level": s.risk_level}

    def challenge(self, sid: str, actor: str, text: str) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "challenge")
            event = {"id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "actor": actor, "agent": "Manis", "text": text}
            s.challenges.append(event); self._save(); return event

    def sign(self, sid: str, actor: str, action: dict[str, Any]) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; m = self._require(s, actor, "sign")
            if m.role != "resident": raise PermissionError("required signatory must be a designated Resident")
            payload = {"session_id": sid, "actor": actor, "role": m.role, "action": action, "at": datetime.now(timezone.utc).isoformat()}
            digest = hashlib.sha256(json.dumps(payload, sort_keys=True, default=str).encode()).hexdigest()
            s.signatures[actor] = {"role": m.role, "at": payload["at"], "receipt": digest, "action_hash": hashlib.sha256(json.dumps(action, sort_keys=True).encode()).hexdigest()}; self._save(); return self.dispatch_status(sid)

    def owner_sign(self, sid: str, actor: str, action: dict[str, Any]) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; m = self._require(s, actor, "sign")
            if m.role != "owner": raise PermissionError("owner signature required")
            payload = {"session_id": sid, "actor": actor, "role": m.role, "action": action, "at": datetime.now(timezone.utc).isoformat()}
            digest = hashlib.sha256(json.dumps(payload, sort_keys=True, default=str).encode()).hexdigest(); s.signatures[actor] = {"role": m.role, "at": payload["at"], "receipt": digest}; self._save(); return self.dispatch_status(sid)

    def dispatch_status(self, sid: str) -> dict[str, Any]:
        s = self.sessions[sid]; owner_signed = any(v.get("role") == "owner" for v in s.signatures.values()); residents = [k for k,v in s.signatures.items() if v.get("role") == "resident"]; ready = owner_signed and len(residents) >= s.required_signatories
        return {"required": {"owner": True, "resident_count": s.required_signatories}, "signed": {"owner": owner_signed, "residents": residents}, "unlocked": ready, "execution_boundary": "Bodhex", "cryptographic_receipts": True, "receipt_type": "tamper_evident_runtime_hash"}

    def dispatch(self, sid: str, actor: str, action: dict[str, Any]) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "execute"); gate = self.dispatch_status(sid)
            if not gate["unlocked"]: raise PermissionError("multi-signatory gate is locked")
            event = {"dispatch_id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "actor": actor, "target": "Bodhex", "action": action, "signatures": s.signatures}
            event["receipt"] = hashlib.sha256(json.dumps(event, sort_keys=True, default=str).encode()).hexdigest(); self._save(); return event

    def outcome(self, sid: str, actor: str, result: str, selected_option: str, contributors: list[str]) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "comment")
            c = self.consensus(sid); event = {"outcome_id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "result": result, "selected_option": selected_option, "consensus": c, "contributors": contributors, "analysis_chain": ["Medrus", "Viveda", "Learning proposal"]}
            s.outcomes.append(event); self._save(); return event

    def learning_proposal(self, sid: str, actor: str, outcome_id: str) -> dict[str, Any]:
        with self._lock:
            s = self.sessions[sid]; self._require(s, actor, "comment"); outcome = next((x for x in s.outcomes if x["outcome_id"] == outcome_id), None)
            if outcome is None: raise KeyError("outcome not found")
            proposal = {"proposal_id": uuid.uuid4().hex, "at": datetime.now(timezone.utc).isoformat(), "session_id": sid, "outcome_id": outcome_id, "status": "PENDING_HUMAN_APPROVAL", "provenance": {"analyzer": ["Medrus", "Viveda"], "source": "collaboration_outcome", "contributors": outcome["contributors"]}, "dataset_update": {"operation": "append_labeled_example", "label": outcome["selected_option"], "features": {"consensus": outcome["consensus"], "risk_level": s.risk_level}}, "model_update": {"policy": "human_approved_only", "target": "validated_training_dataset"}}
            self._write_learning(proposal); return proposal

    def approve_learning(self, proposal_id: str, actor: str) -> dict[str, Any]:
        for p in self._read_learning():
            if p["proposal_id"] == proposal_id:
                s = self.sessions[p["session_id"]]; self._require(s, actor, "approve_learning"); p["status"] = "APPROVED"; p["approved_by"] = actor; p["approved_at"] = datetime.now(timezone.utc).isoformat(); self._write_all_learning(self._read_learning()); return p
        raise KeyError("learning proposal not found")

    def _read_learning(self) -> list[dict[str, Any]]:
        if not LEARNING_STORE.exists(): return []
        try: return json.loads(LEARNING_STORE.read_text())
        except (OSError, ValueError): return []

    def _write_learning(self, p: dict[str, Any]) -> None:
        items = self._read_learning(); items.append(p); self._write_all_learning(items)

    def _write_all_learning(self, items: list[dict[str, Any]]) -> None:
        ROOT.mkdir(parents=True, exist_ok=True); tmp = LEARNING_STORE.with_suffix(".tmp"); tmp.write_text(json.dumps(items, indent=2, default=str)); tmp.replace(LEARNING_STORE)

    def snapshot(self, sid: str, actor: str) -> dict[str, Any]:
        s = self.sessions[sid]; m = self._member(s, actor); role = m.role if m else "guest"; p = PERMISSIONS.get(role, PERMISSIONS["guest"])
        return {"session": asdict(s), "role": role, "permissions": sorted(p), "consensus": self.consensus(sid), "dispatch": self.dispatch_status(sid), "authoritative_context": [x for x in s.context_diffs], "agent_chain": ["Syvax", "Dharen", "Tarkis", "Pramon", "Manis", "Bodhex", "Medrus", "Viveda"]}

collaboration_engine = CollaborationEngine()
