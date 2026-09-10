# CRITERIVOX — S5 RESEARCH-SPECIFIC DECISION RECORDS

This document records the researcher-defined decisions supplied for S5. These decisions are authoritative for research-specific semantics. Engineering must preserve provenance, avoid unsupported equivalence, and keep unresolved research questions explicit.

## Decision register

| ID | Status | Priority | Decision | Primary engineering effect |
|---|---|---|---|---|
| R-01 | RESEARCHER-DEFINED | BLOCKING | Controlled, provenance-preserving normalization | Automate deterministic representation changes; semantic mappings require evidence/approval; originals remain recoverable. |
| R-02 | RESEARCHER-DEFINED | BLOCKING | Layered, provenance-aware, non-destructive duplicate model | Detect candidates; never silently merge/delete based only on similarity. |
| R-03 | RESEARCHER-DEFINED | BLOCKING | Statistical + semantic anomaly taxonomy | Flag/classify anomalies; preserve observations; distinguish unusual from invalid. |
| R-04 | RESEARCHER-DEFINED | BLOCKING | Separate confidence dimensions | Never present an undefined engineering score as scientifically validated confidence. |
| R-05 | RESEARCHER-DEFINED | BLOCKING | Initial core: Instagram, YouTube, Facebook, X, LinkedIn | Keep platform adapters extensible; preserve platform-native terminology; defer Reddit, Telegram, WhatsApp, ShareChat. |
| R-06 | RESEARCHER-DEFINED | BLOCKING | Evidence-derived experimental targets with ESTABLISHED / RESEARCHER-DEFINED / UNRESOLVED | Research targets require explicit status and evidence traceability. |
| R-07 | RESEARCHER-DEFINED | BLOCKING | S5 context is primarily a research/search hint | Keep research-task context distinct from evidence, interpretation, and final decision context. |
| R-08 | RESEARCHER-DEFINED | BLOCKING | Explicit evidence-gated missingness taxonomy | Preserve missing-state meaning; never coerce missing to zero/false/empty. |
| R-09 | RESEARCHER-DEFINED | BLOCKING | Mandatory core provenance + conditional provenance with explicit Yes/No user confirmation | Preserve source identity/time/version/value/terminology/citation/source-to-finding links; conditional items require user choice. |
| R-10 | RESEARCHER-DEFINED | BLOCKING | Source → Evidence → Finding → Interpretation → Research Question/Hypothesis | Keep layers separate and traceable. |
| R-11 | RESEARCHER-DEFINED | BLOCKING | Evidence-gated tiered comparability | Use DIRECT / CONDITIONAL / RELATED / NOT_COMPARABLE / UNRESOLVED; preserve native terms. |
| R-12 | RESEARCHER-DEFINED | BLOCKING | Structured evidence-and-validation process + researcher approval where required | Distinguish extracted, validated, pending approval, established, researcher-defined, and unresolved material. |

## R-01 — Normalization Policy

Criterivox will use **controlled, provenance-preserving normalization**. Deterministic transformations such as unit, date, and format conversion may be automated. Semantic mappings, synonym merging, category conversion, and cross-platform equivalence require documented evidence or researcher approval. Original source values, terminology, precision, context, and meaning must remain recoverable.

**Implementation consequence:** deterministic normalization may proceed; semantic transformations require traceability and applicable approval.

## R-02 — Duplicate Semantics

Criterivox will use a **layered, provenance-aware, non-destructive duplicate model combined with similarity-based candidate detection**. Similarity can discover/rank candidates but cannot establish scientific identity. Exact/high-confidence technical duplicates may be flagged automatically. Near duplicates and semantic relationships require confirmation. Legitimate repeated observations remain preserved.

**Implementation consequence:** candidate detection is non-destructive; merging/deletion cannot rely solely on similarity.

## R-03 — Anomaly Semantics

Criterivox will combine **statistical anomaly detection with a semantic anomaly taxonomy** covering statistical outlier, data-entry error, impossible/invalid value, unusual-but-valid observation, platform-specific unusual value, and missing/unknown condition.

**Implementation consequence:** anomaly flags never automatically imply invalidity; detection and semantic classification remain distinguishable.

## R-04 — Confidence Semantics

Criterivox will use separate confidence dimensions where established: extraction, classification, intent prediction, research evidence, and data quality. A score requires an explicit meaning, scale, calculation method, and validation basis.

**Implementation consequence:** engineering heuristics remain engineering heuristics and must not be represented as research-validated confidence.

## R-05 — Platform Scope

Initial core research platforms are **Instagram, YouTube, Facebook, X, and LinkedIn**. Inclusion is evidence-gated and the architecture remains platform-agnostic. Reddit, Telegram, WhatsApp, and ShareChat are deferred, not declared irrelevant.

**Implementation consequence:** platform-specific terminology and limitations are preserved; adapters remain extensible.

## R-06 — Experimental Targets

Experimental targets are **evidence-derived** and use **ESTABLISHED, RESEARCHER-DEFINED, and UNRESOLVED** status. They concern end-user problems, questions, decisions, and needs served by the marketing/content-intelligence use case, not a claim of Criterivox novelty.

**Implementation consequence:** unsupported targets cannot be presented as established findings and must retain evidence links where applicable.

## R-07 — Context Definition

S5 context functions primarily as a **research/search hint**. It guides research-material searching, intended pattern discovery, organization, and downstream handoff. It is not itself the final context for end-user decision-making.

**Implementation consequence:** structured research-task context remains distinct from extracted evidence, interpretation, and inference.

## R-08 — Missingness Taxonomy

Use an **explicit, evidence-gated** taxonomy. Candidate states are UNKNOWN, NOT_PROVIDED, NOT_APPLICABLE, NOT_MEASURED, NOT_OBSERVED, WITHHELD, UNAVAILABLE, and EXTRACTION_FAILED. Domain-specific states require support.

**Implementation consequence:** states are not interchangeable and are never silently converted to zero, false, empty, or another substantive value.

## R-09 — Provenance Requirements

Mandatory core provenance includes source identity/reference, collection/access time, source date/version where available, original terminology/value where applicable, citation/reference, and source-to-finding relationship. Conditional provenance categories require explicit **Yes/No end-user confirmation** after extraction before retention.

**Implementation consequence:** provenance is structured and linked across sources, extracted information, transformations, and findings. Conditional retention decisions are user-controlled and auditable.

## R-10 — Evidence and Finding Representation

Criterivox uses the layered model:

```text
Source → Evidence → Finding → Interpretation → Research Question/Hypothesis
```

**Implementation consequence:** each layer remains independently representable and relationships are preserved so a finding can be traced to evidence and its original source.

## R-11 — Cross-Platform Comparability

Comparability is evidence-gated and classified as **DIRECT, CONDITIONAL, RELATED, NOT_COMPARABLE, or UNRESOLVED**. Platform-native terminology and definitions are always preserved.

**Implementation consequence:** comparison requires an established relationship; naming similarity alone cannot establish equivalence.

## R-12 — Research Validation Rules

Research validation uses evidence existence, source identification, claim-to-evidence traceability, separation of interpretation from source evidence, required provenance, applicability/conditions, and explicit uncertainty. Appropriate research-derived items may require researcher approval before becoming established.

**Implementation consequence:** distinguish extracted material, validated evidence-supported findings, researcher-approved established findings, researcher-defined material, and unresolved material. Researcher approval is explicit.

## Engineering guardrails derived from the decisions

1. Preserve raw/source material and lineage.
2. Keep deterministic engineering transformations reversible and recorded.
3. Never infer scientific equivalence from field names alone.
4. Never silently delete anomalies or duplicate candidates.
5. Never turn missingness into a substantive value.
6. Never expose an undefined heuristic score as validated research confidence.
7. Never mark evidence-derived material as established without the required validation/approval state.
8. Keep platform-native definitions available even after canonical preparation.
9. Preserve the distinction between research/search context and final end-user decision context.
10. Treat unresolved research semantics as unresolved rather than inventing values.
