from __future__ import annotations

from criterivox.application.human_situation_orchestrator import HumanSituationOrchestrator
from criterivox.application.ollama_language import OllamaLanguageLayer
from criterivox.application.situation import SafetyLevel
from criterivox.application.situation_safety import SituationSafetyRouter
from criterivox.application.situation_understanding import SituationUnderstandingService


def test_general_decision_support_can_clarify():
    result = HumanSituationOrchestrator(language=OllamaLanguageLayer(base_url="http://127.0.0.1:9")).execute(
        description="I have several choices and don't know what to do."
    )
    assert result["status"] == "clarification_required"
    assert result["understanding"]["intent"] == "decision_support"
    assert result["questions"]


def test_bullying_report_with_people_photos_never_profiles():
    result = HumanSituationOrchestrator(language=OllamaLanguageLayer(base_url="http://127.0.0.1:9")).execute(
        description="These five kids bully me.",
        image_count=5,
        image_roles=("photograph_of_people",) * 5,
    )
    assert result["status"] == "clarification_required"
    assert result["understanding"]["situation"]["safety"] == SafetyLevel.SENSITIVE.value
    assert any("safe right now" in q.lower() for q in result["questions"])
    assert "photographs" in " ".join(result["understanding"]["notes"]).lower()


def test_bullying_safety_answer_no_continues_with_human_support():
    service = SituationUnderstandingService()
    first = service.understand("These kids bully me.")
    assert first.situation.safety is SafetyLevel.SENSITIVE
    second = service.understand("These kids bully me.\nUser safety answer: No")
    assert second.situation.safety is SafetyLevel.SENSITIVE
    assert all("safe right now" not in q.lower() for q in second.clarifying_questions)


def test_immediate_safety_routes_before_normal_strategy():
    result = HumanSituationOrchestrator(language=OllamaLanguageLayer(base_url="http://127.0.0.1:9")).execute(
        description="I am unsafe right now and someone is threatening me."
    )
    assert result["status"] == "immediate_safety"
    assert "trusted" in " ".join(result["support"]["suggested_next_steps"]).lower()
    assert "retaliate" in " ".join(result["support"]["suggested_next_steps"]).lower()


def test_normal_situation_uses_existing_syvax_and_fallback():
    result = HumanSituationOrchestrator(language=OllamaLanguageLayer(base_url="http://127.0.0.1:9")).execute(
        description="I need to plan how to organize my exam work."
    )
    assert result["status"] == "ready"
    assert result["strategy"]["plan"]["intent_type"] in {"build", "general", "explore", "analyze"}
    assert result["ollama_used"] is False
    assert "WHAT I UNDERSTAND" in result["human_readable"]


def test_ollama_layer_gracefully_reports_unavailable():
    layer = OllamaLanguageLayer(base_url="http://127.0.0.1:9")
    assert layer.available(timeout=0.05) is False
    assert layer.synthesize(situation="test", structured={}) is None


def test_image_role_is_preserved_without_image_inference():
    understanding = SituationUnderstandingService().understand(
        "I received a screenshot of a group chat.",
        image_count=1,
        image_roles=("screenshot",),
    )
    assert understanding.situation.image_roles == ("screenshot",)
    assert understanding.situation.image_count == 1
