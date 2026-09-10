# Criterivox S5 Research-Specific Decisions Prompt

Use this prompt with the researcher/domain expert to resolve only research semantics that engineering must not invent.

For every decision return:

```text
Decision ID:
Decision:
Status: ESTABLISHED / RESEARCHER-DEFINED / UNRESOLVED
Priority: BLOCKING / IMPORTANT / DEFERRED
Scope:
Evidence / Source:
Reasoning:
Examples:
Implementation consequence:
What remains unknown:
```

If evidence is insufficient, write **UNRESOLVED**. Do not turn engineering assumptions into research findings.

## R-01 Normalization policy

Define acceptable normalization for units, measurements, precision/rounding, dates/time, text/case, terminology, synonyms, categories, and platform-native labels. State what source meaning must never be changed and which transformations require researcher approval.

## R-02 Duplicate semantics

Define exact duplicates, near duplicates, the same observation from multiple sources, repeated publication/reference, repeated measurements, and legitimate repeated observations. State what may be auto-flagged versus requiring human confirmation.

## R-03 Anomaly semantics

Define statistical outlier, data-entry error, impossible/invalid value, unusual-but-valid observation, platform-specific unusual value, and missing/unknown value. State what S5 may flag and what it must never silently remove.

## R-04 Confidence semantics

Define, where applicable, extraction confidence, classification confidence, intent-prediction confidence, research-evidence confidence, and data-quality confidence. Specify meaning, scale, interpretation, and validated method. If none exists, mark UNRESOLVED. An engineering heuristic score is not automatically research-valid confidence.

## R-05 Final platform scope

For every included platform provide why it is included, relevant metrics/data, platform-native terminology to preserve, limitations, and whether comparison semantics are shared or platform-specific. List excluded/deferred platforms and reasons.

## R-06 Experimental targets

Define established downstream research questions, hypotheses, target variables, predictor/context variables, comparison dimensions, outcome measures, evaluation criteria, and evidence requirements. Do not invent targets for engineering convenience.

## R-07 Exact context definition

Define context and distinguish user-supplied, creator-provided, platform, temporal, audience/contextual, research/task, system-derived context, and interpretation/inference. State what belongs in context and what must remain separate.

## R-08 Missingness taxonomy

Define meaningful research missingness states, only where supported, such as UNKNOWN, NOT_PROVIDED, NOT_APPLICABLE, NOT_MEASURED, NOT_OBSERVED, WITHHELD, UNAVAILABLE, EXTRACTION_FAILED, and domain-specific states. State when each is appropriate and whether missingness has analytical meaning. Missing/unavailable must not automatically become zero.

## R-09 Provenance requirements

Define research-required provenance for reproducibility: source identity/reference, collection time, version/date, original terminology, transformations, citations, and source-to-finding relationships. Identify mandatory fields.

## R-10 Evidence and finding representation

Define the boundary and required traceability between:

```text
SOURCE → FINDING / DEFINITION → RESEARCHER INTERPRETATION → ENGINEERING REPRESENTATION
```

## R-11 Cross-platform comparability

Identify concepts legitimately comparable across platforms and concepts that must remain platform-native. For comparable concepts define basis, normalization, units, exceptions, and caveats.

## R-12 Research validation rules

Separate research-derived validity rules from generic engineering validation. Example: engineering says a field must be numeric; research may define which numeric range is scientifically valid. List research-derived rules only when supported.

## Final decision register

| ID | Decision | Status | Priority | Source | Affects |
|---|---|---|---|---|---|
| R-01 | Normalization policy | | | | |
| R-02 | Duplicate semantics | | | | |
| R-03 | Anomaly semantics | | | | |
| R-04 | Confidence semantics | | | | |
| R-05 | Platform scope | | | | |
| R-06 | Experimental targets | | | | |
| R-07 | Context definition | | | | |
| R-08 | Missingness taxonomy | | | | |
| R-09 | Provenance requirements | | | | |
| R-10 | Evidence/finding representation | | | | |
| R-11 | Cross-platform comparability | | | | |
| R-12 | Research validation rules | | | | |

## Final rule

If a research-specific answer cannot be supported, record **UNRESOLVED**. Engineering may use a generic, reversible, provenance-preserving mechanism temporarily, but must not claim an invented assumption came from research.
