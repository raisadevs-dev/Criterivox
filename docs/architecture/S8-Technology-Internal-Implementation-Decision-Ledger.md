# CRITERIVOX — S8 Technology Stack / Internal Implementation Decision Ledger

**Status:** AUTHORITATIVE FOR S8 INTERNAL IMPLEMENTATION  
**Scope:** Finalized Set I baseline + local-first implementation boundary  
**Basis:** S8 Architecture Discussion + consolidated ledger material supplied by project owner

## 1. Purpose

Concrete technology/internal implementation decision baseline derived from locked Set I, while preserving the architecture and keeping remaining implementation-level choices explicit.

## 2. Application and Runtime

- Primary presentation technology: Flutter/Dart.
- Computational subsystem: Python.
- Architecture is hybrid, with presentation separated from computational capabilities.
- S8 remains independently runnable and locally operable.
- An online LLM/service dependency is not mandatory.

## 3. Internal Component Organization

Organize computation by capability, lifecycle and shared infrastructure, rather than by character.

Use typed interfaces/contracts.

Use direct calls where appropriate and artifact/event exchange for meaningful cross-capability communication.

Coordination occurs at capability/application/domain level.

> Character → presentation identity  
> Capability → computational responsibility

## 4. Artifact and Persistence

Represent epistemic artifacts as strongly typed domain structures with graph relationships where appropriate.

Underlying artifact identity is unique and shared across presentation views.

Use IndexedDB and internal local SQLite as the core local persistence choices, with additional storage only when justified.

Do not duplicate artifacts merely because multiple rooms display different information particles.

```text
One underlying artifact
        │
        ├── Medrus view
        ├── Epistre view
        ├── Veridat view
        └── Presentation view

Different views, same underlying artifact identity.
```

## 5. Provenance and Temporal Infrastructure

Use established provenance models/standards where they adequately satisfy requirements.

Represent transformation lineage as directed relationships/events.

Use temporal event records and temporal graph relationships as appropriate.

Cryptographic integrity is selective, applied where materially useful.

The ledger deliberately does not prescribe a proprietary provenance system merely for uniqueness.

## 6. Evidence / Verification / Contradiction

### Evidence

Evidence acquisition may combine:

- deterministic parsers/extractors,
- NLP,
- human-assisted extraction.

### Verification

Verification may combine:

- rule-based mechanisms,
- source comparison,
- statistical/ML mechanisms,
- other justified mechanisms.

### Contradiction

Contradiction detection may use:

- semantic mechanisms,
- NLP mechanisms,
- human-mediated resolution.

An unresolved contradiction remains a valid state. The system must not manufacture certainty merely because a UI component is waiting for something to display.

## 7. Memory / Retrieval / Uncertainty

### Memory

Memory uses consolidation mechanisms while retaining:

- provenance,
- temporal state,
- verification,
- integrity,
- uncertainty.

### Retrieval

Retrieval is hybrid, potentially combining:

- deterministic queries,
- full-text/semantic retrieval,
- graph traversal,

according to the actual retrieval requirement.

### Uncertainty

Uncertainty is represented through structured, multi-dimensional artifacts, rather than one universal confidence score.

## 8. Debate Arena NLP / LLM Boundary

Debate Arena uses local layered NLP.

LLMs may be used selectively where capability requirements and empirical evidence justify them.

LLM execution is local rather than a mandatory online service.

LLMs are mechanisms, not:

- characters,
- computational authorities,
- hidden orchestration agents.

Conceptual interaction:

```text
Human input
    ↓
Language/NLP interpretation
    ↓
Artifact/path identification
    ↓
Evidence/context extraction
    ↓
Intervention structuring
    ↓
Authorization
    ↓
Re-evaluation
    ↓
Human-readable response
```

The exact NLP models/frameworks were not locked in this document.

## 9. Explanation / Human Interaction

Explanation begins from structured explanation artifacts tied to:

- evidence,
- provenance,
- uncertainty,
- result paths.

Rendering should preserve traceability.

Language generation may be hybrid where justified.

Intervention is persisted as dedicated artifacts/events and linked to provenance.

Authorization is enforced below the UI through capability/operation and context-aware policy.

> A generated explanation must not sever the connection to the underlying evidence and provenance.

## 10. Testing and Research Instrumentation

S8 should use appropriate combinations of:

- unit testing,
- integration testing,
- artifact/provenance invariant testing,
- end-to-end testing,
- research evaluation.

Research instrumentation should produce:

- structured experiment records,
- reproducible execution receipts,
- artifact/provenance records,
- human-evaluation records.

Experimental mechanisms should be sufficiently isolated/configurable to support research without destabilizing the usable system.

## 11. Deployment and Integration

Use a hybrid local deployment model within the Criterivox context.

Integrate with S7 and future bureaus through defined artifact/interface/event contracts.

Avoid hidden cross-bureau dependencies.

Characters connect through capability interfaces/presentation adapters, not computational ownership.

Conceptually:

```text
S7
 │
 │ defined artifacts/contracts
 ▼
S8
 │
 │ defined artifacts/contracts
 ▼
Future Criterivox systems
```

Not direct access into each other's internal implementation.

## 12. Technology Selection Rule

The fundamental implementation sequence is:

```text
Research requirement
        ↓
Capability
        ↓
Mechanism
        ↓
Technology
        ↓
Implementation
```

Not:

```text
Favorite technology
        ↓
Force architecture to fit it
```

Therefore:

- Reuse established standards/components where adequate.
- Integrate existing partial solutions where appropriate.
- Develop Criterivox-specific mechanisms only where a justified research gap remains.
- No technology choice may silently change a locked A–H architectural requirement.

## 13. Implementation-Level OPEN Items

The following remain open because they were not architecture decisions:

- exact Flutter packages,
- exact Python frameworks/libraries,
- concrete database schema,
- exact graph technology,
- exact local NLP models,
- exact local LLM models,
- cryptographic primitives,
- detailed API/interface schemas,
- experimental parameterization.

Also still open:

> Unsupported empirical thresholds, confidence cutoffs and arbitrary constants remain UNKNOWN/OPEN until justified by evidence or experimentation.

## Core technology boundary

```text
CRITERIVOX S8
                      │
          ┌───────────┴───────────┐
          │                       │
       Flutter                  Python
     Presentation            Computation
          │                       │
          │              ┌────────┴────────┐
          │              │                 │
          │         Capabilities       Lifecycle
          │              │                 │
          │              └────────┬────────┘
          │                       │
          │              Typed Epistemic
          │                 Artifacts
          │                       │
          │            ┌──────────┴──────────┐
          │            │                     │
          │        IndexedDB              SQLite
          │            │                     │
          └────────────┴──────────┬──────────┘
                                  │
                       Provenance + Temporal
                         + Relationships
                                  │
                         Human Inspection
                                  │
                       Challenge / Intervention
```

## Most important constraint

This document does not prescribe exact packages or models yet. It establishes the technology architecture and boundaries. Exact implementation choices belong to the subsequent implementation/research phase and must satisfy the already-locked architecture.
