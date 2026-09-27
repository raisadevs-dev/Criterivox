# Criterivox S6 — Context Decisions

## Status

This record is an engineering decision log grounded in the S6 research gate. It does not turn engineering choices into research findings.

## Decision 01 — Extensible context domain

**Evidence:** S6 research material records that context modeling is foundational in context-aware systems and that multiple representation families exist; no single representation is universally correct.

**Decision:** Use typed, modular Python context objects with explicit dimensions and metadata.

**Implementation:** `criterivox.domain.context` and `criterivox.application.context_engine`.

**Boundary:** This is an engineering foundation, not a claim that it is the optimal research representation.

## Decision 02 — Structural normalization only

**Evidence:** The reviewed material does not establish universal semantic equivalence across platform metrics or source fields.

**Decision:** S6 performs representation-preserving structural cleanup and records normalization decisions. It does not silently merge or equate platform semantics.

## Decision 03 — Baseline representation, not validated baseline selection

**Evidence:** The S6 package marks universal baseline selection as UNKNOWN / REQUIRES RESEARCH.

**Decision:** Implement a baseline representation and comparison boundary with explicit status and limitations. Baseline status remains `UNKNOWN` until empirical methodology is established.

## Decision 04 — Provenance is traceable, not immutable

**Evidence:** S6 research uses W3C PROV concepts and explicitly states that the current storage model does not provide cryptographically immutable lineage.

**Decision:** Context outputs preserve material/source identifiers and context-generation metadata while declaring `immutable=false`.

## Decision 05 — Uncertainty is explicit

**Evidence:** S6 research identifies context quality and uncertainty as relevant concerns and requires missingness distinctions from S5 to remain intact.

**Decision:** Context records preserve uncertainty and limitations instead of collapsing unknown, unavailable, not-observed, and other states.

## Decision 06 — Kaelen scratchpad is temporary state

**Evidence:** Sprint requirement defines a configurable 24-hour default TTL and cleanup on Viveda sign-off or TTL expiry.

**Decision:** S6 implements a configurable TTL scratchpad primitive. It is explicitly not research knowledge.

## Deferred / unresolved

- Universal cross-platform normalization: UNKNOWN.
- Empirically optimal baseline selection: UNKNOWN.
- Validated anomaly forecasting: NOT ESTABLISHED.
- Full model-level XAI: FUTURE.
- Immutable provenance storage: FUTURE / NOT SUPPORTED BY CURRENT STORAGE.
- Safe isolated hypothesis execution: REQUIRES FURTHER ARCHITECTURAL VALIDATION before introducing a process/browser sandbox.
