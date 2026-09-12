"""Ephemeral Guest Pass lifecycle.

This is intentionally local-runtime infrastructure, not a production MicroVM
implementation. The guest envelope is memory-only and is never written to the
Human Residence store. Production deployment can replace the in-process
sandbox boundary with Firecracker/gVisor while retaining this contract.
"""
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
        self.ttl_seconds = ttl_seconds
        self._sessions: dict[str, GuestSession] = {}

    def create(self) -> GuestSession:
        now = datetime.now(timezone.utc)
        session = GuestSession(token_urlsafe(18), now, now + timedelta(seconds=self.ttl_seconds))
        self._sessions[session.session_id] = session
        return session

    def get(self, session_id: str) -> GuestSession | None:
        session = self._sessions.get(session_id)
        if session is None or not session.active or session.expires_at <= datetime.now(timezone.utc):
            if session is not None: self.vaporize(session_id)
            return None
        return session

    def update(self, session_id: str, *, goal: str, data: Any, context: dict[str, Any]) -> GuestSession:
        session = self.get(session_id)
        if session is None: raise KeyError("guest session expired or does not exist")
        session.goal, session.data, session.context = goal, data, dict(context)
        return session

    def append_trace(self, session_id: str, event: dict[str, Any]) -> None:
        session = self.get(session_id)
        if session is not None: session.trace.append(dict(event))

    def vaporize(self, session_id: str) -> bool:
        session = self._sessions.pop(session_id, None)
        if session is None: return False
        session.active = False
        session.goal = ""
        session.data = None
        session.context.clear()
        session.trace.clear()
        session.decisions.clear()
        return True

    def claim(self, session_id: str) -> dict[str, Any]:
        session = self.get(session_id)
        if session is None: raise KeyError("guest session expired or does not exist")
        payload = {'goal': session.goal, 'data': session.data, 'context': dict(session.context), 'trace': list(session.trace), 'decisions': list(session.decisions), 'claimed_from_guest': session.session_id}
        self.vaporize(session_id)
        return payload

    def active_count(self) -> int:
        return sum(1 for s in self._sessions.values() if s.active and s.expires_at > datetime.now(timezone.utc))
