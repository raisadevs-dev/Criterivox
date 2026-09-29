# CRITERIVOX — S5 RESEARCH-SPECIFIC DECISION RECORDS

This document is the research/domain decision basis supplied for Sprint 5. Engineering must preserve these decisions, distinguish researcher-defined material from engineering heuristics, and leave unresolved research semantics unresolved.

## Decision register

| ID | Decision | Status | Priority |
|---|---|---|---|
| R-01 | Controlled, provenance-preserving normalization. Deterministic format/unit/date changes may be automated; semantic mappings require evidence or researcher approval. | RESEARCHER-DEFINED | BLOCKING |
| R-02 | Layered, provenance-aware, non-destructive duplicate model. Similarity discovers candidates but does not establish scientific identity; legitimate repeated observations remain preserved. | RESEARCHER-DEFINED | BLOCKING |
| R-03 | Statistical anomaly detection plus semantic anomaly taxonomy. Flags do not imply invalidity and observations are never silently deleted/corrected. | RESEARCHER-DEFINED | BLOCKING |
| R-04 | Separate confidence dimensions. A confidence score requires an explicit meaning, scale, calculation method, and validation basis. | RESEARCHER-DEFINED | BLOCKING |
| R-05 | Initial core platforms: Instagram, YouTube, Facebook, X, LinkedIn. Reddit, Telegram, WhatsApp, ShareChat are deferred. Architecture remains platform-agnostic. | RESEARCHER-DEFINED | BLOCKING |
| R-06 | Experimental targets use ESTABLISHED / RESEARCHER-DEFINED / UNRESOLVED and concern end-user problems, questions, decisions, and needs in the marketing/content-intelligence use case. | RESEARCHER-DEFINED | BLOCKING |
| R-07 | S5 context is primarily a research/search hint, not final end-user decision context. | RESEARCHER-DEFINED | BLOCKING |
| R-08 | Explicit evidence-gated missingness taxonomy: UNKNOWN, NOT_PROVIDED, NOT_APPLICABLE, NOT_MEASURED, NOT_OBSERVED, WITHHELD, UNAVAILABLE, EXTRACTION_FAILED, plus supported domain-specific states. Missing is never silently zero/false/empty. | RESEARCHER-DEFINED | BLOCKING |
| R-09 | Mandatory core provenance plus conditional provenance. Conditional categories require explicit Yes/No end-user confirmation after extraction. | RESEARCHER-DEFINED | BLOCKING |
| R-10 | Layered evidence model: Source → Evidence → Finding → Interpretation → Research Question/Hypothesis. Layers and relationships remain distinct. | RESEARCHER-DEFINED | BLOCKING |
| R-11 | Cross-platform comparability is evidence-gated and tiered: DIRECT, CONDITIONAL, RELATED, NOT_COMPARABLE, UNRESOLVED. Native terminology remains preserved. | RESEARCHER-DEFINED | BLOCKING |
| R-12 | Structured evidence-and-validation checks followed by researcher approval where required. Distinguish extracted, validated, researcher-approved established, researcher-defined, and unresolved material. | RESEARCHER-DEFINED | BLOCKING |

## R-01 — Normalization Policy

Criterivox will use controlled, provenance-preserving normalization. Deterministic transformations such as unit, date, and format conversion may be automated. Semantic mappings, synonym merging, category conversion, and cross-platform equivalence require documented evidence or researcher approval. Original source values, terminology, precision, context, and meaning remain recoverable.

## R-02 — Duplicate Semantics

Criterivox will use a layered, provenance-aware, non-destructive duplicate model with similarity-based candidate detection. Similarity may discover or rank candidates but cannot alone establish scientific identity. Exact/high-confidence technical duplicates may be flagged, while near duplicates and semantic relationships require appropriate confirmation. Legitimate repeated observations remain preserved.

## R-03 — Anomaly Semantics

Criterivox combines statistical anomaly detection with semantic anomaly classification. Anomalies may be statistical outliers, data-entry errors, impossible/invalid values, unusual-but-valid observations, platform-specific unusual values, or missing/unknown conditions. Anomaly flags do not establish invalidity.

## R-04 — Confidence Semantics

Confidence is represented by explicit dimensions such as extraction, classification, intent prediction, research evidence, and data quality where justified. Engineering heuristic scores must not be represented as scientifically validated confidence.

## R-05 — Platform Scope

The initial core research scope is Instagram, YouTube, Facebook, X, and LinkedIn. Other previously considered platforms are deferred, not declared irrelevant. Platform-specific terminology and limitations must remain preserved.

## R-06 — Experimental Targets

Experimental targets are evidence-derived and use ESTABLISHED, RESEARCHER-DEFINED, and UNRESOLVED statuses. They concern end-user problems, questions, decisions, needs, variables, outcomes, experiments, and evaluation relevant to marketing/content intelligence, not a manufactured novelty claim about Criterivox.

## R-07 — Context Definition

S5 context functions primarily as a research/search hint. It guides material discovery, pattern searching, evidence organization, and downstream handoff. It must remain distinguishable from extracted evidence and later interpretation/inference.

## R-08 — Missingness Taxonomy

Missingness is explicit and evidence-gated. Candidate states are UNKNOWN, NOT_PROVIDED, NOT_APPLICABLE, NOT_MEASURED, NOT_OBSERVED, WITHHELD, UNAVAILABLE, and EXTRACTION_FAILED. Unsupported distinctions remain unresolved. Missing states are not interchangeable and never become substantive values silently.

## R-09 — Provenance Requirements

Mandatory provenance includes source identity/reference, collection/access time, source date/version where available, original terminology/value where applicable, citation/reference, and source-to-finding relationship. Additional conditional provenance is retained only after explicit Yes/No user choices for each applicable category.

## R-10 — Evidence and Finding Representation

The evidence model is Source → Evidence → Finding → Interpretation → Research Question/Hypothesis. Each layer remains independent and linked so a downstream finding can be traced back to its evidence and original source.

## R-11 — Cross-Platform Comparability

Cross-platform relationships are evidence-gated and classified as DIRECT, CONDITIONAL, RELATED, NOT_COMPARABLE, or UNRESOLVED. Similar naming alone never establishes equivalence, and platform-native terminology remains available.

## R-12 — Research Validation Rules

Validation checks evidence existence, source identification, claim-to-evidence traceability, separation of interpretation from evidence, required provenance, applicability/conditions, and uncertainty. Researcher approval is explicit where required. Unsupported claims remain unresolved.

## Engineering guardrails

- Never silently invent research semantics.
- Preserve raw source values, native terminology, provenance, missingness, anomalies, and transformation history.
- Engineering heuristics may assist triage but are not research validation.
- Researcher-defined decisions remain visibly researcher-defined until the research process establishes them.
- Unresolved research questions remain unresolved.
