"""S6 Context Intelligence computational agents and runtime."""

from .models import AdaptiveContextState, ContextCheckpoint, ContextDiff, ContextFork, ContextFrame, ContextInput, ContextItem, ContextTier, ContextViolation

__all__ = [
    "AdaptiveContextState", "AnukaAgent", "ContextCheckpoint", "ContextDiff", "ContextFork", "ContextFrame", "ContextInput", "ContextIntelligenceEngine", "ContextItem", "ContextRuntime", "ContextTier", "ContextViolation", "DharenAgent",
]

def __getattr__(name):
    if name == "AnukaAgent":
        from criterivox.agents.anuka.agent import AnukaAgent
        return AnukaAgent
    if name == "DharenAgent":
        from criterivox.agents.dharen.agent import DharenAgent
        return DharenAgent
    if name == "ContextIntelligenceEngine":
        from .engine import ContextIntelligenceEngine
        return ContextIntelligenceEngine
    if name == "ContextRuntime":
        from .runtime import ContextRuntime
        return ContextRuntime
    raise AttributeError(name)
