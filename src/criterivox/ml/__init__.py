"""Local ML-capable agents used by Criterivox."""

from .anuka import AnukaMLAgent
from .dharen import DharenMLAgent
from criterivox.Kaelen.ml import KaelenMLAgent
from criterivox.Sandre.ml import SandreMLAgent

__all__ = ["AnukaMLAgent", "DharenMLAgent", "KaelenMLAgent", "SandreMLAgent"]
