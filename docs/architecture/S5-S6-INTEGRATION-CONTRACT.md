# Criterivox S5 → S6 Integration Contract

## Purpose

This document defines the boundary between Sprint 5 Data Foundation + Sandre Data Stewardship and Sprint 6 Context Engine work. S6 extends the foundation with context reasoning. It does not replace the S5 data contract.

## Authoritative boundary

S5 is responsible for establishing a validated, provenance-aware canonical `DataFoundation`. Its downstream handoff preserves:

- canonical data;
- raw/source relationships and provenance;
- quality metadata and readiness state;
- missingness and anomaly information;
- transformation history;
- confirmation/reconfirmation state;
- semantic metadata and relationship constraints where produced by S5;
- foundation identity and revision/synchronization context.

S6 consumes that foundation and adds context construction, semantic interpretation, and context-engine reasoning above it.

## Runtime handoff

```text
Browser / local working set
        │
        ▼
S5 Sandre stewardship
        │
        │ validated canonical DataFoundation
        │ + provenance / quality / transformations
        │ + confirmation / semantic metadata
        ▼
S6 Context Engine / Kaelen
        │
        │ context construction + reasoning
        ▼
Dharen / downstream contextual handoff
```

The handoff is an explicit application boundary. Character presentation is not the data contract: the underlying foundation and runtime events remain authoritative.

## Browser-first recovery

The browser is the local-first recovery boundary for the active working set. The presentation client may restore a complete foundation from IndexedDB and send a revisioned `foundation_sync` message to the Python runtime. The server-side `DataFoundationStore` can restore/replace the serialized foundation authoritatively when the incoming revision is valid and non-conflicting.

This permits recovery after a Python process restart without treating browser-resident user work as lost. It is not a distributed multi-device synchronization system.

## Synchronization invariants

1. A foundation has a stable `foundation_id`.
2. Foundation revisions are monotonic for a given identifier.
3. Older incoming revisions are rejected as stale.
4. Equal revisions with identical content are idempotent.
5. Equal revisions with different content are conflicts, not silent overwrites.
6. An authoritative recovery replaces the in-memory server mirror only after validation.
7. S6 must not discard provenance, confirmation, or transformation metadata while creating context.

## S6 responsibilities

S6 may add:

- context selection and structuring;
- semantic/contextual interpretation;
- context windows and relationships;
- context-engine evaluation;
- reasoning/orchestration above the foundation;
- downstream context handoffs.

S6 must not silently redefine S5's research-specific semantics or erase the evidence needed to explain how a context representation was produced.

## Character relationship

The sprint workflow is not a rigid character-to-character call chain. Domain/application events activate relevant character behaviors through the shared interaction layer. For the S5/S6 boundary, Sandre is the stewardship owner, Kaelen is the S6 builder/processing role, and Dharen organizes contextual downstream handoffs. Conditional reasoning/adaptation remains event-driven rather than being treated as a mandatory pipeline step.

## Model boundary

Character identity and model identity remain separate. A character owns a responsibility/capability; a model or procedure implements the computational requirement. S6 should therefore document model choice from the required context capability and evaluation evidence, rather than assigning a model merely because a character exists.

## Deferred scope

The S5 vector-lakehouse ingestion surface remains deferred. S6 may design context representations that can later feed an embedding/vector architecture, but deferred infrastructure must not be represented as implemented.

## Acceptance conditions for the S6 handoff

- A canonical `DataFoundation` can be identified and consumed.
- Provenance and transformation history remain inspectable.
- Confirmation state remains explicit.
- Quality/readiness metadata remains available to context processing.
- Browser recovery can restore the foundation after a Python restart.
- S6 context artifacts can reference their foundation input and revision.
- Context reasoning does not mutate the S5 source-of-truth semantics without an explicit new decision record.

## Related records

- `ADR-007-s5-data-foundation-and-provenance.md`
- `ADR-008-s5-runtime-and-presentation-boundary.md`
- `S5-BROWSER-FIRST-DATA-RESIDENCY.md`
- `S5-EVALUATION-DATASET-REGISTRY.md`
- `S5-CLOSURE-2026-09-10.md`
