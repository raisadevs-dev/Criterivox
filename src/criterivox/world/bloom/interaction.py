"""Bloom interaction state model."""

from enum import Enum


class BloomState(str, Enum):
    """States of the Bloom interaction."""

    CLOSED = "closed"
    OPEN = "open"
    PRIMARY_SELECTED = "primary_selected"
    CONTEXT_EXPANDED = "context_expanded"
    ACTION_SELECTED = "action_selected"
    ERROR = "error"


class BloomInteraction:
    """Manage Bloom interaction state.

    This class contains interaction state only.
    It does not contain UI rendering or business logic.
    """

    def __init__(self) -> None:
        self.state = BloomState.CLOSED
        self.selected_capability: str | None = None

    def open(self) -> None:
        self.state = BloomState.OPEN

    def close(self) -> None:
        self.state = BloomState.CLOSED
        self.selected_capability = None

    def select_primary(self, capability: str) -> None:
        self.selected_capability = capability
        self.state = BloomState.PRIMARY_SELECTED

    def expand_context(self) -> None:
        if self.state != BloomState.PRIMARY_SELECTED:
            self.state = BloomState.ERROR
            return

        self.state = BloomState.CONTEXT_EXPANDED

    def select_action(self) -> None:
        if self.state != BloomState.CONTEXT_EXPANDED:
            self.state = BloomState.ERROR
            return