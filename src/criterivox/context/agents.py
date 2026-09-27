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


