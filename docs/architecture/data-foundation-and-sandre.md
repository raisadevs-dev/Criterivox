# S5 — Data Foundation and Sandre Stewardship Boundary

**Branch:** `s5-data-foundation`  
**Baseline:** `main` after S4 closure  
**Status:** CLOSED — 2026-09-10

## Architectural decision

S5 introduces a provenance-aware data-foundation boundary without replacing the existing S2/S3/S4 application/runtime architecture.

```text
USER MATERIAL
   ↓
SOURCE / COLLECTION INTAKE
   ↓
EXTRACTION
   ↓
CANDIDATE INFORMATION
   ↓
USER CONFIRMATION
   ↓
PROFILE / QUALITY
   ↓
NORMALIZE / PREPARE
   ↓
CANONICAL DATA
   ↓
SANDRE
   ↓
DHAREN HANDOFF
```

The implementation is input-neutral. Source adapters converge on the common `DataFoundation` representation. Raw source content is retained separately from normalized and canonical representations.

## Runtime and presentation boundary

S5 extends the existing Python → WebSocket → Dart presentation contract rather than replacing it. Python remains authoritative for semantic character state. Flutter renders the received state and does not invent application lifecycle state.

Character identifiers crossing the presentation boundary use the canonical registry representation. Sandre is a semantic runtime participant and owns Data Stewardship; Dharen owns the Analysis Workspace; Syvax remains the dialogue host.

Bloom remains capability discovery and does not duplicate Sandre's working controls.

## Provenance

Every source receives a stable source identity and provenance record. Candidate information retains its originating source. Transformations record an original value, transformation name, result, reason, and provenance.

The following layers are deliberately distinct:

- `raw_data`: source representation retained for recovery/audit.
- `supplied_context`: information explicitly supplied by the user.
- `derived_information`: system-derived information.
- `normalized_data`: deterministic representation after safe normalization.
- `canonical_data`: downstream representation.

## Confirmation boundary

System extraction is not treated as user truth. Candidate information carries an explicit confirmation status. Handoff is rejected until the foundation has been confirmed or corrected by the user.

Supported review concepts include confirmation, correction, exclusion, irrelevance, clarification, and addition at the application boundary.

## Missingness and anomalies

Missingness is represented explicitly rather than collapsing every case to `null` or zero. S5 uses generic engineering categories only; research-specific semantics remain deferred until supplied research material defines them.

The deterministic anomaly foundation flags numeric observations using a transparent threshold and preserves the original observation. It does not delete or reinterpret an outlier.

## Sandre boundary

Sandre owns S5 stewardship communication:

```text
MATERIAL_RECEIVED
      ↓
EXTRACTION_COMPLETED
      ↓
USER_CONFIRMATION_REQUIRED
      ↓
SANDRE_HANDOFF_READY
      ↓
DHAREN_HANDOFF_READY
```

Sandre can receive stewardship chat independently of Dharen analysis chat. Chat material is synchronized through the shared foundation boundary.

## Integration completed during S5

- Sandre Data Stewardship workspace integrated with the runtime.
- Sandre Home ↔ Chat foundation synchronization closed at the application runtime boundary.
- Chat material enters the shared data-foundation path before downstream use.
- Schema pre-flight and low-confidence clarification are supported.
- Top-3 intent prediction requires explicit user approval.
- Stewardship routing supports Syvax, Dharen, and Kaelen within the defined boundary.
- Searchable stewardship logs expose source/material/task context.
- Conditional provenance requires explicit choices.
- Home ↔ Chat conflicts require explicit field-level winners before non-destructive merge.
- Contextual internal workspace door addresses are carried through the presentation contract.
- Past-analysis queries use the stored analysis-task boundary.
- Dharen remains the Analysis Workspace owner and Sandre remains the Data Stewardship owner.
- Redundant Dharen Home navigation was removed.
- Sandre quick actions were removed from Bloom to avoid duplicating the stewardship workspace.

## Research-material checkpoint

Research-specific normalization, missingness semantics, domain validation, and semantic extraction rules remain evidence-gated. Engineering does not invent domain-specific units, categories, missing-value meanings, or research interpretations.

## Verification

The developer verified the application locally during S5 closure after resolving Flutter/Dart syntax and runtime integration issues. Repository documentation records the resulting implementation boundary and known limitations.

## Non-scope

S5 does not implement the S6 Context Engine, S7 intelligence models, S8 XAI, social APIs, a production database/authentication layer, or the full character ecosystem.

## S6 handoff

S5 hands S6 a validated, provenance-aware canonical data foundation with provenance, quality metadata, confirmation state, transformation history, and source relationships. S6 must preserve these guarantees while adding context reasoning above the foundation.
