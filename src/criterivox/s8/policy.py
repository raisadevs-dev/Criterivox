"""Explicit S8 authorization/isolation boundary.

Characters never grant authority. Callers supply an actor identity and operation;
the policy decides whether the requested operation may inspect or mutate a
particular artifact/context.
"""
from __future__ import annotations

from dataclasses import dataclass


class AuthorizationError(PermissionError):
    """Raised when an S8 operation is not explicitly authorized."""


@dataclass(frozen=True)
class AccessRequest:
    actor_id: str
    operation: str
    tenant_id: str | None = None
    context_id: str | None = None
    artifact_tenant_id: str | None = None
    artifact_context_id: str | None = None
    authorized: bool = False


class S8Policy:
    """Least-privilege policy with tenant/context isolation."""

    CONSEQUENT_OPERATIONS = frozenset({"challenge", "intervene", "reevaluate", "revise"})

    def check(self, request: AccessRequest) -> None:
        if not request.actor_id.strip():
            raise AuthorizationError("An actor identity is required.")
        if request.tenant_id != request.artifact_tenant_id:
            raise AuthorizationError("Tenant isolation denied this operation.")
        if request.context_id != request.artifact_context_id:
            raise AuthorizationError("Context isolation denied this operation.")
        if request.operation in self.CONSEQUENT_OPERATIONS and not request.authorized:
            raise AuthorizationError("Explicit human authorization is required for this consequential operation.")

    def can_inspect(self, *, actor_id: str, tenant_id: str | None, context_id: str | None, artifact_tenant_id: str | None, artifact_context_id: str | None) -> bool:
        try:
            self.check(AccessRequest(actor_id, "inspect", tenant_id, context_id, artifact_tenant_id, artifact_context_id))
        except AuthorizationError:
            return False
        return True
