from __future__ import annotations

from criterivox.context.agents import DharenAgent


class DharenMLAgent(DharenAgent):
    """S6 local ML-capable context agent.

    The initial implementation is deterministic and interpretable. The public
    agent contract is intentionally model-ready so learned ranking/compression
    components can be introduced only when evaluation evidence justifies them.
    """

    model_version = "dharen-context-baseline-1"

    @property
    def is_ready(self) -> bool:
        return True
