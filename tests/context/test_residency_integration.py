from types import SimpleNamespace

from criterivox.context import ContextRuntime


def foundation():
    source = SimpleNamespace(source_id="src-1")
    quality = SimpleNamespace(validation_errors=(), validation_warnings=(), anomaly_count=0, missing_count=0)
    return SimpleNamespace(
        foundation_id="foundation-1",
        supplied_context={"request": "Compare the supplied evidence."},
        sources=(source,), candidates=(), canonical_data=({"id": 1},),
        confirmation_status=SimpleNamespace(value="confirmed"), handoff_ready=True,
        quality=quality,
    )


def test_dharen_consumes_s5_foundation_and_emits_durable_payload():
    runtime = ContextRuntime()
    state = runtime.build_from_foundation(foundation(), task_id="task-1")
    assert state.frame.frame_id.startswith("CTXF-")
    assert runtime.compact_projection("foundation-1")["context_id"] == state.frame.frame_id
    checkpoint = runtime.checkpoint("foundation-1", task_id="task-1", scratchpad={"note": "keep"})
    assert checkpoint.checkpoint_id
    durable = runtime.durable_payload("foundation-1", task_id="task-1")
    assert durable["context_frame"]["frame_id"] == state.frame.frame_id
    assert durable["context_checkpoint"]["checkpoint_id"] == checkpoint.checkpoint_id
    assert durable["provenance_reference_ids"] == ["src-1"]


def test_anuka_activation_contract_is_conditional():
    runtime = ContextRuntime()
    assert runtime.should_activate_anuka(new_context=True)
    assert runtime.should_activate_anuka(requirements_changed=True)
    assert runtime.should_activate_anuka(downstream_incompatible=True)
    assert not runtime.should_activate_anuka()
