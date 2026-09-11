"""Browser-local persistence contract for Criterivox.

The Flutter web client is the owner of browser persistence. This module defines
what may be persisted and deliberately contains no server-side user-data store.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class BrowserLocalPolicy:
    storage: str = "browser-local"
    server_persistence: bool = False
    training_consent_default: bool = False
    user_can_clear: bool = True
    sensitive_payload_upload: str = "explicit-user-action"

    def as_dict(self) -> dict[str, Any]:
        return {
            "storage": self.storage,
            "server_persistence": self.server_persistence,
            "training_consent_default": self.training_consent_default,
            "user_can_clear": self.user_can_clear,
            "sensitive_payload_upload": self.sensitive_payload_upload,
        }


BROWSER_LOCAL_POLICY = BrowserLocalPolicy()
