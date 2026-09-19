from pathlib import Path
from tempfile import TemporaryDirectory

from criterivox.character_backbone.operations import (
    Auth, CapabilityRegistry, CapabilitySpec, ExecStatus, Lifecycle, Op,
    OperationEngine, OperationStore, Verification,
)

def make_engine(tmp):
    store = OperationStore(Path(tmp) / "s3.sqlite3")
    registry = CapabilityRegistry()
    registry.register(CapabilitySpec(
        "artifact.move", "Move local artifact", "bodhex", "CURRENT", True,
        (Op.MOVE.value,), ("artifact.write",), "filesystem inspection", "filesystem.local"
    ))
    return OperationEngine(store=store, registry=registry)

def test_command_is_not_execution():
    with TemporaryDirectory() as d:
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact","conversation_id":"c1",
            "context":{"artifact_id":"a1","destination":"/tmp/x","source":"/tmp/missing"}})
        assert result["classification"] == "AUTH_REQUIRED"
        assert not engine.executions

def test_capability_unavailable_is_honest():
    with TemporaryDirectory() as d:
        engine = OperationEngine(store=OperationStore(Path(d)/"s3.sqlite3"), registry=CapabilityRegistry())
        result = engine.handle({"message":"Move this artifact"})
        assert result["classification"] == "NOT_IMPLEMENTED"

def test_change_requires_reevaluation():
    with TemporaryDirectory() as d:
        engine = make_engine(d)
        result = engine.handle({"message":"Change the requirement","conversation_id":"c"})
        assert result["classification"] == "REEVALUATION_REQUIRED"

def test_real_adapter_verifies():
    with TemporaryDirectory() as d:
        source = Path(d) / "a.txt"
        destination = Path(d) / "out" / "a.txt"
        source.write_text("x")
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact",
            "context":{"artifact_id":"a","destination":str(destination),"source":str(source)}})
        out = engine.approve(result["command"]["command_id"])
        assert out["execution"]["status"] == ExecStatus.SUCCEEDED.value
        assert out["verification"]["status"] == Verification.VERIFIED.value
        assert destination.exists() and not source.exists()

def test_provenance_lineage_exists():
    with TemporaryDirectory() as d:
        source = Path(d) / "a"
        destination = Path(d) / "b"
        source.write_text("x")
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact",
            "context":{"artifact_id":"a","destination":str(destination),"source":str(source)}})
        out = engine.approve(result["command"]["command_id"])
        event_types = [e["event_type"] for e in out["events"]]
        assert "COMMAND_CREATED" in event_types
        assert "ACTION_COMPLETED" in event_types
        assert "VERIFICATION_COMPLETED" in event_types

def test_denied_never_executes():
    with TemporaryDirectory() as d:
        source = Path(d) / "a"
        destination = Path(d) / "b"
        source.write_text("x")
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact",
            "context":{"artifact_id":"a","destination":str(destination),"source":str(source)}})
        engine.reject(result["command"]["command_id"])
        assert not engine.executions

def test_persistence_survives_store_reopen():
    with TemporaryDirectory() as d:
        path = Path(d) / "s3.sqlite3"
        source = Path(d) / "a"
        destination = Path(d) / "b"
        source.write_text("x")
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact",
            "context":{"artifact_id":"a","destination":str(destination),"source":str(source)}})
        out = engine.approve(result["command"]["command_id"])
        assert out["verification"]["status"] == Verification.VERIFIED.value
        reopened = OperationStore(path)
        assert reopened.events_for(result["command"]["command_id"])

def test_no_approval_means_no_execution():
    with TemporaryDirectory() as d:
        engine = make_engine(d)
        result = engine.handle({"message":"Move this artifact",
            "context":{"artifact_id":"a","destination":"/tmp/x","source":"/tmp/missing"}})
        assert result["command"]["status"] == Lifecycle.AUTHORIZATION_REQUIRED.value
        assert result["command"]["authorization_state"] == Auth.AUTH_PENDING.value

def test_prepare_moving_is_classified_as_move():
    intent, operation, _ = OperationEngine.classify("Prepare moving this artifact to Research.")
    assert intent == "MOVE_ARTIFACT"
    assert operation == Op.MOVE

def test_change_request_is_not_misread_as_move():
    intent, operation, _ = OperationEngine.classify("Actually, move it somewhere else.")
    assert intent == "CHANGE_REQUESTED"
    assert operation == Op.MODIFY

def test_verification_without_resolved_action_is_unknown():
    with TemporaryDirectory() as d:
        engine = make_engine(d)
        result = engine.handle({"message":"Did it actually happen?"})
        assert result["classification"] == "UNKNOWN"
