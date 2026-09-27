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
from .token_budget import DynamicTokenAllocator


class AnukaAgent:
    """Context Adaptor: drift, state transitions, sandbox forks, checkpoints and handoff."""

    agent_id = "anuka"
    role = "Context Adaptor / Situational Management"

    TRIGGERS = (
        "new_context",
        "requirements_changed",
        "evidence_changed",
        "hypothesis_changed",
        "constraint_changed",
        "drift_detected",
        "counterfactual_requested",
        "downstream_incompatible",
    )

    def should_activate(
        self,
        triggers: Mapping[str, bool],
        *,
        manual_activation: bool = False,
    ) -> bool:
        return manual_activation or any(
            bool(triggers.get(name, False))
            for name in self.TRIGGERS
        )

    def adapt(
        self,
        previous: ContextFrame | None,
        current: ContextFrame,
        *,
        previous_state: AdaptiveContextState | None = None,
    ) -> AdaptiveContextState:
        old = (
            {
                item.key: item.value
                for item in previous.items
            }
            if previous
            else {}
        )

        new = {
            item.key: item.value
            for item in current.items
        }

        diff = self.diff(
            old,
            new,
            previous_request=(
                previous.request
                if previous
                else ""
            ),
            current_request=current.request,
            previous_constraints=(
                previous.hard_constraints
                if previous
                else ()
            ),
            current_constraints=current.hard_constraints,
        )

        active = dict(old)
        active.update(new)

        for key in set(old) - set(new):
            active.pop(key, None)

        version = (
            previous_state.state_version + 1
            if previous_state
            else (2 if previous else 1)
        )

        return AdaptiveContextState(
            frame=current,
            diff=diff,
            active_context=active,
            sandbox_states=(
                previous_state.sandbox_states
                if previous_state
                else {}
            ),
            checkpoint_id=(
                previous_state.checkpoint_id
                if previous_state
                else None
            ),
            state_version=version,
        )

    def diff(
        self,
        old: Mapping[str, Any],
        new: Mapping[str, Any],
        *,
        previous_request: str = "",
        current_request: str = "",
        previous_constraints: tuple[str, ...] = (),
        current_constraints: tuple[str, ...] = (),
    ) -> ContextDiff:
        old_keys = set(old)
        new_keys = set(new)

        return ContextDiff(
            added=tuple(
                sorted(new_keys - old_keys)
            ),
            removed=tuple(
                sorted(old_keys - new_keys)
            ),
            changed=tuple(
                sorted(
                    key
                    for key in old_keys & new_keys
                    if old[key] != new[key]
                )
            ),
            unchanged=tuple(
                sorted(
                    key
                    for key in old_keys & new_keys
                    if old[key] == new[key]
                )
            ),
            goal_shift=(
                bool(previous_request)
                and previous_request.strip()
                != current_request.strip()
            ),
            constraint_shift=(
                tuple(previous_constraints)
                != tuple(current_constraints)
            ),
        )

    def checkpoint(
        self,
        state: AdaptiveContextState,
        scratchpad: Mapping[str, Any],
    ) -> ContextCheckpoint:
        return ContextCheckpoint(
            checkpoint_id=(
                f"CKPT-{state.frame.frame_id}-"
                f"{state.state_version}"
            ),
            frame_id=state.frame.frame_id,
            state_version=state.state_version,
            active_context=dict(state.active_context),
            scratchpad=dict(scratchpad),
        )

    def fork(
        self,
        state: AdaptiveContextState,
        fork_id: str,
        overrides: Mapping[str, Any],
    ) -> ContextFork:
        fork_state = dict(state.active_context)
        fork_state.update(overrides)

        return ContextFork(
            fork_id=fork_id,
            base_checkpoint_id=state.checkpoint_id,
            state=fork_state,
        )

    def handoff_payload(
        self,
        state: AdaptiveContextState,
        *,
        recipient: str,
    ) -> dict[str, Any]:
        return {
            "schema_version": "s6.context-handoff.v1",
            "sender": self.agent_id,
            "recipient": recipient,
            "frame_id": state.frame.frame_id,
            "state_version": state.state_version,
            "request": state.frame.request,
            "active_context": dict(state.active_context),
            "added": state.diff.added,
            "removed": state.diff.removed,
            "changed": state.diff.changed,
            "goal_shift": state.diff.goal_shift,
            "constraint_shift": state.diff.constraint_shift,
            "violations": tuple(
                {
                    "code": violation.code,
                    "message": violation.message,
                    "keys": violation.keys,
                }
                for violation in state.frame.violations
            ),
        }