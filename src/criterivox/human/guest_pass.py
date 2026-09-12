"""Ephemeral Guest Pass lifecycle with browser-first claim semantics."""
from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from secrets import token_urlsafe
from typing import Any

@dataclass
class GuestSession:
    session_id: str
    created_at: datetime
    expires_at: datetime
    goal: str = ""
    data: Any = None
    context: dict[str, Any] = field(default_factory=dict)
    trace: list[dict[str, Any]] = field(default_factory=list)
    decisions: list[dict[str, Any]] = field(default_factory=list)
    active: bool = True

class GuestPassManager:
    def __init__(self, ttl_seconds: int = 15 * 60) -> None:
        self.ttl_seconds = ttl_seconds; self._sessions: dict[str, GuestSession] = {}
    def create(self) -> GuestSession:
        now=datetime.now(timezone.utc); s=GuestSession(token_urlsafe(18),now,now+timedelta(seconds=self.ttl_seconds)); self._sessions[s.session_id]=s; return s
    def get(self, session_id: str) -> GuestSession | None:
        s=self._sessions.get(session_id)
        if s is None or not s.active or s.expires_at <= datetime.now(timezone.utc):
            if s is not None:self.vaporize(session_id)
            return None
        return s
    def update(self, session_id: str, *, goal: str, data: Any, context: dict[str, Any]) -> GuestSession:
        s=self.get(session_id)
        if s is None:raise KeyError("guest session expired or does not exist")
        s.goal,s.data,s.context=goal,data,dict(context);return s
    def append_trace(self, session_id: str, event: dict[str, Any]) -> None:
        s=self.get(session_id)
        if s is not None:s.trace.append(dict(event))
    def migratable(self, session_id: str) -> dict[str, Any]:
        s=self.get(session_id)
        if s is None:raise KeyError("guest session expired or does not exist")
        return {'goal':s.goal,'data':s.data,'context':dict(s.context),'trace':list(s.trace),'decisions':list(s.decisions),'claimed_from_guest':s.session_id}
    def commit_claim(self, session_id: str) -> dict[str, Any]:
        payload=self.migratable(session_id);self.vaporize(session_id);return payload
    def vaporize(self, session_id: str) -> bool:
        s=self._sessions.pop(session_id,None)
        if s is None:return False
        s.active=False;s.goal="";s.data=None;s.context.clear();s.trace.clear();s.decisions.clear();return True
    def claim(self, session_id: str) -> dict[str, Any]:return self.commit_claim(session_id)
    def active_count(self) -> int:return sum(1 for s in self._sessions.values() if s.active and s.expires_at>datetime.now(timezone.utc))
