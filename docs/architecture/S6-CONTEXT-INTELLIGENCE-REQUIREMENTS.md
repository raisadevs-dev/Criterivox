# Criterivox — S6 Context Intelligence Requirements

## Status

**IMPLEMENTED:** the first inspectable runtime/UI layer for the following capabilities exists on `s6-context-engine`.

**Research status:** effectiveness and thresholds remain subject to evidence collection and validation.

## Requirements

### R-CONTEXT-001 — Context Provenance Graph

Criterivox MUST expose a visible provenance path connecting source material, Data Foundation, Context and Interpretation.

Minimum behavior:

`SOURCE → DATA FOUNDATION → CONTEXT → INTERPRETATION`

The graph MUST preserve source identifiers when available and MUST NOT claim immutable provenance unless storage supports immutability.

### R-CONTEXT-002 — Context Diff

Criterivox MUST distinguish structural context additions, removals and missing dimensions.

The UI MUST NOT describe structural difference as causal difference without evidence.

A future prior-context snapshot may provide true semantic/context comparison.

### R-CONTEXT-003 — Evidence Debt

Criterivox MUST expose evidence completeness as a percentage plus one of:

- HIGH
- MEDIUM
- LOW
- UNKNOWN

The percentage is a **HEURISTIC** until research establishes a validated measurement method. It MUST NOT be presented as a probability or model confidence.

### R-CONTEXT-004 — Context Memory Expiration

Criterivox MUST represent the possibility that contextual knowledge becomes stale and MUST support explicit expiration/recheck policy.

A universal TTL is **UNKNOWN** and MUST NOT be silently assumed. The current UI therefore exposes the policy as RESEARCH-GATED.

### R-CONTEXT-005 — Agent Observability Timeline

Criterivox MUST preserve an inspectable sequence of agent activity events associated with a task.

Minimum event information:

- actor
- activity
- task/context association
- temporal ordering
- failure/recovery signal when applicable

### R-CONTEXT-006 — Controlled Multi-Agent Handoff

Criterivox MUST represent handoff as an explicit boundary rather than implicit character switching.

Minimum fields:

`from → to → reason/request → context/evidence → delivery/status`

### R-CONTEXT-007 — MCP-Ready Capability Boundary

Criterivox MUST keep future external tool protocols outside the domain model.

An internal capability request/response boundary is implemented. MCP itself remains a future adapter decision.

### R-CONTEXT-008 — Failure Telemetry

Criterivox MUST record recoverable failure events separately from research knowledge.

Supported categories:

- REQUIREMENT_CHANGED
- HYPOTHESIS_FAILED
- CONTEXT_MISMATCH
- BUILD_FAILED
- EXECUTION_FAILED

### R-CONTEXT-009 — Language Mode

Criterivox SHOULD support English/Hindi language mode without duplicating every application string.

The intended localization boundary is:

- localize navigation, interaction labels, onboarding and guidance
- preserve canonical character names, IDs, research labels, evidence-status tags and precise technical identifiers where translation would reduce clarity
- allow mixed-language explanations when technical terminology is clearer in English

Full surface localization remains a later implementation increment after the research package establishes terminology criteria.
