from __future__ import annotations

from hashlib import sha256
from typing import Any, Mapping

from .models import (
    AdaptiveContextState,
    ContextCheckpoint,
    ContextDiff,
    ContextFork,
    ContextFrame,
    ContextInput,
    ContextItem,
    ContextTier,
    ContextViolation,
)


class DharenAgent:
    """Context Master: framing, scope, compression, hierarchy and firewall."""

    agent_id = "dharen"
    role = "Context Master / Scope Boundary Control"

    def frame(self, context: ContextInput, *, max_items: int = 64) -> ContextFrame:
        if not context.request.strip():
            raise ValueError("Context request cannot be empty.")
        violations = self._firewall(context)
        accepted = tuple(item for item in context.items if not any(item.key in v.keys for v in violations))
        ranked = sorted(accepted, key=lambda i: (i.critical, -int(i.tier)), reverse=True)
        kept = tuple(ranked[:max_items])
        if not kept and context.request:
            kept = (ContextItem("request", context.request, ContextTier.CRITICAL, True),)
        original = max(1, len(context.items))
        return ContextFrame(
            frame_id=self._id(context.request, [i.key for i in kept]),
            request=context.request.strip(),
            items=kept,
            hard_constraints=tuple(dict.fromkeys(context.hard_constraints)),
            soft_guidelines=tuple(dict.fromkeys(context.soft_guidelines)),
            environment=dict(context.environment),
            violations=tuple(violations),
            compression_ratio=len(kept) / original,
            original_item_count=len(context.items),
            tier_budget={"critical": 0.40, "high": 0.30, "medium": 0.20, "low": 0.10},
        )

    def _firewall(self, context: ContextInput) -> tuple[ContextViolation, ...]:
        violations: list[ContextViolation] = []
        seen: dict[str, Any] = {}
        for item in context.items:
            if item.key in seen and seen[item.key] != item.value:
                violations.append(ContextViolation("CONTEXT_CLASH", f"Conflicting values for {item.key}.", (item.key,)))
            seen[item.key] = item.value
        for item in context.items:
            text = str(item.value).lower()
            if "ignore previous instructions" in text or "override system" in text:
                violations.append(ContextViolation("CONTEXT_POISONING", f"Prompt-injection pattern detected in {item.key}.", (item.key,)))
        return tuple(violations)

    @staticmethod
    def _id(request: str, keys: list[str]) -> str:
        return "CTXF-" + sha256((request + "|" + "|".join(keys)).encode()).hexdigest()[:16]


class AnukaAgent:
    """Context Adaptor: drift, state transitions, forks, checkpoints and handoff."""

    agent_id = "anuka"
    role = "Context Adaptor / Situational Management"

    def adapt(self, previous: ContextFrame | None, current: ContextFrame) -> AdaptiveContextState:
        old = {item.key: item.value for item in previous.items} if previous else {}
        new = {item.key: item.value for item in current.items}
        diff = self.diff(old, new, previous_request=previous.request if previous else "", current_request=current.request)
        active = dict(old)
        active.update(new)
        for key in set(old) - set(new):
            active.pop(key, None)
        return AdaptiveContextState(frame=current, diff=diff, active_context=active, state_version=(1 if previous is None else 2))

    def diff(self, old: Mapping[str, Any], new: Mapping[str, Any], *, previous_request: str = "", current_request: str = "") -> ContextDiff:
        old_keys, new_keys = set(old), set(new)
        changed = tuple(sorted(k for k in old_keys & new_keys if old[k] != new[k]))
        return ContextDiff(
            added=tuple(sorted(new_keys - old_keys)),
            removed=tuple(sorted(old_keys - new_keys)),
            changed=changed,
            unchanged=tuple(sorted(k for k in old_keys & new_keys if old[k] == new[k])),
            goal_shift=previous_request.strip() != current_request.strip() if previous_request else False,
            constraint_shift=False,
        )

    def checkpoint(self, state: AdaptiveContextState, scratchpad: Mapping[str, Any]) -> ContextCheckpoint:
        return ContextCheckpoint(
            checkpoint_id=f"CKPT-{state.frame.frame_id}-{state.state_version}",
            frame_id=state.frame.frame_id,
            state_version=state.state_version,
            active_context=dict(state.active_context),
            scratchpad=dict(scratchpad),
        )

    def fork(self, state: AdaptiveContextState, fork_id: str, overrides: Mapping[str, Any]) -> ContextFork:
        fork_state = dict(state.active_context)
        fork_state.update(overrides)
        return ContextFork(fork_id=fork_id, base_checkpoint_id=state.checkpoint_id, state=fork_state)
