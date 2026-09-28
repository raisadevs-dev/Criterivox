"""Anuka: adaptive context, drift, sandbox and handoff responsibility."""
from .agent import AnukaAgent

def __getattr__(name):
    if name == "AnukaMLAgent":
        from .ml import AnukaMLAgent
        return AnukaMLAgent
    raise AttributeError(name)

__all__ = ["AnukaAgent", "AnukaMLAgent"]
