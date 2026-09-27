from criterivox.Anuka.agent import AnukaAgent
from criterivox.context.models import ContextFrame, ContextInput, ContextItem, ContextTier


def frame(request, value):
    return ContextFrame(
        frame_id="frame",
        request=request,
        items=(ContextItem(key="value", value=value, tier=ContextTier.HIGH),),
        hard_constraints=(),
        soft_guidelines=(),
        environment={},
        violations=(),
        compression_ratio=1.0,
        original_item_count=1,
        tier_budget={},
    )


def test_activation_is_conditional():
    agent = AnukaAgent()
    assert agent.should_activate({"drift_detected": True})
    assert not agent.should_activate({})


def test_adaptation_tracks_changes():
    agent = AnukaAgent()
    state = agent.adapt(frame("old", 1), frame("new", 2))
    assert state.diff.changed == ("value",)
    assert state.diff.goal_shift is True


def test_checkpoint_and_fork():
    agent = AnukaAgent()
    state = agent.adapt(frame("same", 1), frame("same", 1))
    checkpoint = agent.checkpoint(state, {"note": "test"})
    fork = agent.fork(state, "fork-1", {"value": 2})
    assert checkpoint.state_version == state.state_version
    assert fork.state["value"] == 2
