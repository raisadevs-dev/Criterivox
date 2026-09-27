"""Local ML-capable agents used by Criterivox."""

from .anuka import AnukaMLAgent
from criterivox.agents.dharen.ml import DharenMLAgent
from criterivox.agents.kaelen.ml import KaelenMLAgent
from criterivox.agents.sandre.ml import SandreMLAgent

__all__ = ["AnukaMLAgent", "DharenMLAgent", "KaelenMLAgent", "SandreMLAgent"]
