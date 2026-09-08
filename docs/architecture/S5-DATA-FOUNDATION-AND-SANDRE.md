# S5 — Data Foundation and Sandre Stewardship Boundary

**Branch:** `s5-data-foundation`  
**Baseline:** `main` after S4 closure  
**Status:** implementation in progress

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

## Current repository integration

S4 already has a durable `AnalysisTask` aggregate and a Python → WebSocket → Dart presentation contract. S5 does not replace either. The new foundation is an additional domain/application capability that can later be attached to the analysis-task boundary.

The existing character registry remains technology-independent, while semantic character state is still rendered by the presentation layer. Sandre is therefore emitted as a semantic runtime participant, not as a Flutter-only animation.

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

Syvax remains the dialogue host. Dharen remains the structural-context/downstream handoff participant. Kaelen's S6 page-building responsibility is not implemented here.

## Research-material checkpoint

### RESEARCH MATERIAL REQUIRED

**Stage:** research-specific normalization, missingness semantics, domain validation, and semantic extraction rules.

**Why:** generic engineering can preserve and transform material safely, but Criterivox must not invent domain-specific units, categories, missing-value meanings, or research interpretations.

**What must be provided:** the relevant research definitions, source material, schema/field meanings, and any domain-specific rules required for those decisions.

**How it affects implementation:** it determines semantic validation rules, normalization mappings, missingness categories, and research traceability records.

**What can continue without it:** generic source intake, preservation, provenance, deterministic profiling, structural validation, confirmation workflow, generic normalization, runtime events, UI integration, and automated engineering tests using synthetic fixtures.

## Non-scope

S5 does not implement the S6 Context Engine, S7 intelligence models, S8 XAI, social APIs, a production database/authentication layer, or the full character ecosystem.
