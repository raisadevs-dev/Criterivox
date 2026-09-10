# ADR-007: S5 Data Foundation and Provenance Boundary

- **Status:** Accepted
- **Date:** 2026-09-10
- **Sprint:** S5
- **Scope:** Data Foundation, provenance, confirmation, normalization, and downstream handoff

## Context

Criterivox needs a durable data boundary between supplied material and later intelligence/context work. S5 must preserve source meaning and traceability without allowing presentation code or later intelligence services to redefine the data foundation.

The supplied S5 research decision records require provenance-aware normalization, layered duplicate/anomaly handling, explicit confidence dimensions, explicit missingness, source-to-evidence traceability, and evidence-gated semantic interpretation.

## Decision

S5 establishes `DataFoundation` as the common input-neutral representation. The foundation preserves distinct layers for raw source data, user-supplied context, derived information, normalized representation, and canonical downstream data.

Every source receives stable identity and provenance. Candidate information retains source relationships. Transformations record original value, transformation, result, reason, and provenance. System-extracted information is not treated as user truth until the explicit confirmation boundary is satisfied.

Handoff to downstream analysis is confirmation-gated. Generic deterministic normalization is permitted where meaning is preserved. Semantic mappings, synonym merging, category conversion, and cross-platform equivalence remain evidence-gated and researcher-controlled.

## Consequences

- Raw material remains recoverable and auditable.
- User-provided information is distinguishable from system-derived information.
- Downstream analysis receives a stable canonical representation.
- S5 can support multiple source types without coupling the domain to one platform.
- Research-specific semantics remain outside engineering assumptions.
- S6 can consume the canonical foundation without replacing the S5 boundary.

## Rejected Alternatives

- Treating extracted information as automatically confirmed user truth.
- Silently converting missing values to null or zero.
- Performing unsupported semantic normalization in the engineering layer.
- Coupling the foundation directly to a social-platform schema.

## Traceability

The decision is governed by the supplied S5 research-specific decision records R-01 through R-12 and the S5 data-foundation architecture documentation.
