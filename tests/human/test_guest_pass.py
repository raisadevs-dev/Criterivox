from datetime import datetime, timezone

import pytest

from criterivox.human.guest_pass import GuestPassManager


def test_guest_session_is_memory_only_and_vaporizes() -> None:
    manager = GuestPassManager(ttl_seconds=60)
    session = manager.create()
    manager.update(session.session_id, goal="choose", data={"rows": 2}, context={"risk": "medium"})
    manager.append_trace(session.session_id, {"character": "Dharen"})
    assert manager.active_count() == 1
    assert manager.vaporize(session.session_id) is True
    assert manager.get(session.session_id) is None
    assert manager.active_count() == 0


def test_guest_claim_returns_state_then_vaporizes() -> None:
    manager = GuestPassManager(ttl_seconds=60)
    session = manager.create()
    manager.update(session.session_id, goal="compare", data="trial", context={"budget": 50})
    manager.append_trace(session.session_id, {"character": "Anukor", "reason": "route"})
    migrated = manager.claim(session.session_id)
    assert migrated["goal"] == "compare"
    assert migrated["data"] == "trial"
    assert migrated["context"]["budget"] == 50
    assert migrated["claimed_from_guest"] == session.session_id
    assert manager.get(session.session_id) is None


def test_expired_guest_session_is_rejected() -> None:
    manager = GuestPassManager(ttl_seconds=-1)
    session = manager.create()
    assert manager.get(session.session_id) is None
    with pytest.raises(KeyError):
        manager.claim(session.session_id)
