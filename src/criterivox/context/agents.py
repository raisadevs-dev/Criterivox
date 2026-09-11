from __future__ import annotations

from hashlib import sha256
from typing import Any, Mapping

from .models import AdaptiveContextState, ContextCheckpoint, ContextDiff, ContextFork, ContextFrame, ContextInput, ContextItem, ContextTier, ContextViolation


class DharenAgent:
    """Context Master: baseline framing, scope, hierarchy, compression and firewall."""
    agent_id = "dharen"
    role = "Context Master / Scope Boundary Control"

    def frame(self, context: ContextInput, *, max_items: int = 64) -> ContextFrame:
        request = context.request.strip()
        if not request:
            raise ValueError("Context request cannot be empty.")
        violations = self._firewall(context)
        rejected = {key for violation in violations if violation.blocked for key in violation.keys}
        accepted = tuple(item for item in context.items if item.key not in rejected)
        ranked = sorted(accepted, key=lambda item: (item.critical, -int(item.tier), bool(item.source_ids)), reverse=True)
        kept = tuple(ranked[:max_items])
        if not kept:
            kept = (ContextItem("request", request, ContextTier.CRITICAL, True),)
        original = max(1, len(context.items))
        return ContextFrame(
            frame_id=self._id(request, [item.key for item in kept]),
            request=request,
            items=kept,
            hard_constraints=tuple(dict.fromkeys(context.hard_constraints)),
            soft_guidelines=tuple(dict.fromkeys(context.soft_guidelines)),
            environment=dict(context.environment),
            violations=tuple(violations),
            compression_ratio=len(kept) / original,
            original_item_count=len(context.items),
            tier_budget={"critical": .40, "high": .30, "medium": .20, "low": .10},
        )

    def _firewall(self, context: ContextInput) -> tuple[ContextViolation, ...]:
        violations: list[ContextViolation] = []
        seen: dict[str, Any] = {}
        for item in context.items:
            if item.key in seen and seen[item.key] != item.value:
                violations.append(ContextViolation("CONTEXT_CLASH", f"Conflicting values for {item.key}.", (item.key,)))
            seen[item.key] = item.value
        injection_markers = ("ignore previous instructions", "override system", "disregard prior instructions", "bypass safety")
        for item in context.items:
            text = str(item.value).lower()
            if any(marker in text for marker in injection_markers):
                violations.append(ContextViolation("CONTEXT_POISONING", f"Prompt-injection pattern detected in {item.key}.", (item.key,)))
        return tuple(violations)

    @staticmethod
    def _id(request: str, keys: list[str]) -> str:
        return "CTXF-" + sha256((request + "|" + "|".join(keys)).encode()).hexdigest()[:16]


class AnukaAgent:
    """Context Adaptor: drift, state transitions, sandbox forks, checkpoints and handoff."""
    agent_id = "anuka"
    role = "Context Adaptor / Situational Management"
    TRIGGERS = ("new_context", "requirements_changed", "evidence_changed", "hypothesis_changed", "constraint_changed", "drift_detected", "counterfactual_requested", "downstream_incompatible")

    def should_activate(self, triggers: Mapping[str, bool], *, manual_activation: bool = False) -> bool:
        return manual_activation or any(bool(triggers.get(name, False)) for name in self.TRIGGERS)

    def adapt(self, previous: ContextFrame | None, current: ContextFrame, *, previous_state: AdaptiveContextState | None = None) -> AdaptiveContextState:
        old = {item.key: item.value for item in previous.items} if previous else {}
        new = {item.key: item.value for item in current.items}
        diff = self.diff(old, new, previous_request=previous.request if previous else "", current_request=current.request, previous_constraints=previous.hard_constraints if previous else (), current_constraints=current.hard_constraints)
        active = dict(old); active.update(new)
        for key in set(old) - set(new): active.pop(key, None)
        version = (previous_state.state_version + 1) if previous_state else (2 if previous else 1)
        return AdaptiveContextState(frame=current, diff=diff, active_context=active, sandbox_states=previous_state.sandbox_states if previous_state else {}, checkpoint_id=previous_state.checkpoint_id if previous_state else None, state_version=version)

    def diff(self, old: Mapping[str, Any], new: Mapping[str, Any], *, previous_request: str = "", current_request: str = "", previous_constraints: tuple[str, ...] = (), current_constraints: tuple[str, ...] = ()) -> ContextDiff:
        old_keys, new_keys = set(old), set(new)
        return ContextDiff(
            added=tuple(sorted(new_keys - old_keys)), removed=tuple(sorted(old_keys - new_keys)),
            changed=tuple(sorted(k for k in old_keys & new_keys if old[k] != new[k])),
            unchanged=tuple(sorted(k for k in old_keys & new_keys if old[k] == new[k])),
            goal_shift=bool(previous_request) and previous_request.strip() != current_request.strip(),
            constraint_shift=tuple(previous_constraints) != tuple(current_constraints),
        )

    def checkpoint(self, state: AdaptiveContextState, scratchpad: Mapping[str, Any]) -> ContextCheckpoint:
        return ContextCheckpoint(checkpoint_id=f"CKPT-{state.frame.frame_id}-{state.state_version}", frame_id=state.frame.frame_id, state_version=state.state_version, active_context=dict(state.active_context), scratchpad=dict(scratchpad))

    def fork(self, state: AdaptiveContextState, fork_id: str, overrides: Mapping[str, Any]) -> ContextFork:
        fork_state = dict(state.active_context); fork_state.update(overrides)
        return ContextFork(fork_id=fork_id, base_checkpoint_id=state.checkpoint_id, state=fork_state)

    def handoff_payload(self, state: AdaptiveContextState, *, recipient: str) -> dict[str, Any]:
        return {"schema_version": "s6.context-handoff.v1", "sender": self.agent_id, "recipient": recipient, "frame_id": state.frame.frame_id, "state_version": state.state_version, "request": state.frame.request, "active_context": dict(state.active_context), "added": state.diff.added, "removed": state.diff.removed, "changed": state.diff.changed, "goal_shift": state.diff.goal_shift, "constraint_shift": state.diff.constraint_shift, "violations": tuple({"code": v.code, "message": v.message, "keys": v.keys} for v in state.frame.violations)}
