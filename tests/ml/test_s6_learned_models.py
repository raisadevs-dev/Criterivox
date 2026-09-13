from criterivox.context.ml import S6LearnedModelRegistry
from criterivox.ml.anuka import AnukaMLAgent
from criterivox.ml.dharen import DharenMLAgent
from criterivox.ml.kaelen import KaelenMLAgent
from criterivox.ml.sandre import SandreMLAgent


def test_all_s6_learned_models_load_from_registry():
    registry = S6LearnedModelRegistry()
    status = registry.load_all()
    assert status == {"dharen": True, "anuka": True, "sandre": True, "kaelen": True}
    assert all(item["available"] for item in registry.status().values())


def test_dharen_uses_learned_context_tier_signal():
    agent = DharenMLAgent()
    assert agent.learned_model_available


def test_anuka_uses_learned_adaptation_signal():
    agent = AnukaMLAgent()
    assert agent.learned_model_available
    assert agent.should_activate({"requirements_changed": False, "evidence_changed": False, "constraint_changed": False}) is False


def test_sandre_uses_learned_quality_signal():
    agent = SandreMLAgent()
    assert agent.learned_model_available
    result = agent.predict([{"id": 1, "value": 10}, {"id": 2, "value": 11}])
    assert result.learned_state in {"ready", "review", "quarantine"}
    assert result.learned_confidence is not None


def test_kaelen_uses_learned_schema_action_signal():
    agent = KaelenMLAgent()
    assert agent.learned_model_available
    result = agent.propose({"id": "int"}, {"id": "int", "score": "float"})
    assert result.action == "schema_extension"
    assert result.learned_action is not None
    agent.validate_plan(result)
