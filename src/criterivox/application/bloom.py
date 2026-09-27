"""Backward-compatible import surface for Bloom."""

from criterivox.world.bloom.controller import BloomController, BloomPetal, bloom_controller
from criterivox.world.bloom.integration import (
    ApplicationAction,
    ApplicationEvent,
    BloomActionMapping,
    BloomCapability,
    BloomIntegration,
    EventAgentMapping,
)

__all__ = [
    "ApplicationAction",
    "ApplicationEvent",
    "BloomActionMapping",
    "BloomCapability",
    "BloomController",
    "BloomIntegration",
    "BloomPetal",
    "EventAgentMapping",
    "bloom_controller",
]
