from criterivox.application.scenarios import (
    DemonstrationTrace,
    all_demonstration_flows,
    analysis_flow,
    completion_quiet_flow,
    explanation_flow,
    handoff_flow,
    humor_flow,
    waiting_flow,
    warning_recovery_flow,
)


EXPECTED_STANDARD_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "state",
    "communication",
    "result",
    "quiet",
)


def test_analysis_flow_is_traceable() -> None:
    trace = analysis_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "analysis"
    assert trace.steps == EXPECTED_STANDARD_FLOW


def test_explanation_flow_is_traceable() -> None:
    trace = explanation_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "explanation"
    assert trace.steps == EXPECTED_STANDARD_FLOW


def test_handoff_flow_is_traceable() -> None:
    trace = handoff_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "agent_handoff"
    assert trace.contains("sender")
    assert trace.contains("handoff")
    assert trace.contains("receiver")


def test_handoff_flow_preserves_order() -> None:
    trace = handoff_flow()

    assert trace.index("sender") < trace.index("handoff")
    assert trace.index("handoff") < trace.index("receiver")
    assert trace.index("receiver") < trace.index("attention")
    assert trace.index("attention") < trace.index("state")
    assert trace.index("state") < trace.index("communication")
    assert trace.index("communication") < trace.index("result")
    assert trace.index("result") < trace.index("quiet")


def test_waiting_flow_is_traceable() -> None:
    trace = waiting_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "waiting"
    assert trace.contains("waiting")


def test_waiting_flow_preserves_order() -> None:
    trace = waiting_flow()

    assert trace.index("attention") < trace.index("waiting")
    assert trace.index("waiting") < trace.index("communication")
    assert trace.index("communication") < trace.index("quiet")


def test_humor_flow_is_traceable() -> None:
    trace = humor_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "contextual_humor"
    assert trace.contains("humor")


def test_humor_occurs_after_communication() -> None:
    trace = humor_flow()

    assert trace.index("communication") < trace.index("humor")
    assert trace.index("humor") < trace.index("result")
    assert trace.index("result") < trace.index("quiet")


def test_warning_recovery_flow_is_traceable() -> None:
    trace = warning_recovery_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "warning_recovery"
    assert trace.contains("warning")
    assert trace.contains("recovery")


def test_warning_precedes_recovery() -> None:
    trace = warning_recovery_flow()

    assert trace.index("warning") < trace.index("recovery")
    assert trace.index("recovery") < trace.index("communication")
    assert trace.index("communication") < trace.index("result")
    assert trace.index("result") < trace.index("quiet")


def test_completion_quiet_flow_is_traceable() -> None:
    trace = completion_quiet_flow()

    assert isinstance(trace, DemonstrationTrace)
    assert trace.scenario == "completion_quiet"
    assert trace.contains("complete")
    assert trace.contains("quiet")


def test_completion_directly_precedes_quiet() -> None:
    trace = completion_quiet_flow()

    assert trace.index("complete") + 1 == trace.index("quiet")


def test_completion_quiet_flow_has_no_post_completion_activity() -> None:
    trace = completion_quiet_flow()

    completion_index = trace.index("complete")

    assert trace.steps[completion_index + 1 :] == ("quiet",)


def test_all_demonstration_flows_are_available() -> None:
    flows = all_demonstration_flows()

    assert len(flows) == 7
    assert [flow.scenario for flow in flows] == [
        "analysis",
        "explanation",
        "agent_handoff",
        "waiting",
        "contextual_humor",
        "warning_recovery",
        "completion_quiet",
    ]