from __future__ import annotations
from dataclasses import dataclass
from .models import CharacterRegistry, CapabilityRegistry, ImplementationStatus

KNOWN_STATUSES={x.value for x in ImplementationStatus}

@dataclass(frozen=True)
class ValidationIssue:
    code:str
    message:str

def validate_registries(characters:CharacterRegistry, capabilities:CapabilityRegistry):
    issues=[]; ids=[c.id for c in characters.characters]
    if len(ids)!=15:issues.append(ValidationIssue("CHARACTER_COUNT",f"Expected 15 characters, found {len(ids)}"))
    if len(ids)!=len(set(ids)):issues.append(ValidationIssue("DUPLICATE_CHARACTER_ID","Character IDs must be unique"))
    for c in characters.characters:
        for field in ("id","role","home","capabilities"):
            if not getattr(c,field,None):issues.append(ValidationIssue("MISSING_CHARACTER_FIELD",f"{c.id}: missing {field}"))
        for target in c.handoff_targets:
            if target not in ids:issues.append(ValidationIssue("UNKNOWN_HANDOFF_TARGET",f"{c.id}: {target}"))
        if c.implementation_status.value not in KNOWN_STATUSES:issues.append(ValidationIssue("INVALID_STATUS",f"{c.id}: {c.implementation_status.value}"))
    for cap in capabilities.capabilities:
        if cap.owner_character not in ids:issues.append(ValidationIssue("UNKNOWN_CAPABILITY_OWNER",f"{cap.capability_id}: {cap.owner_character}"))
        if cap.implementation_status.value not in KNOWN_STATUSES:issues.append(ValidationIssue("INVALID_STATUS",f"{cap.capability_id}: {cap.implementation_status.value}"))
        for target in cap.handoff_targets:
            if target not in ids:issues.append(ValidationIssue("UNKNOWN_HANDOFF_TARGET",f"{cap.capability_id}: {target}"))
    return tuple(issues)

def validate_or_raise(characters,capabilities):
    issues=validate_registries(characters,capabilities)
    if issues:raise ValueError("\n".join(f"{i.code}: {i.message}" for i in issues))
