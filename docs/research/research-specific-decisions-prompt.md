# Criterivox S5 Research-Specific Decisions Prompt

## Purpose

Use this prompt with the Criterivox research/mentor process to resolve the domain decisions that Sprint 5 must not invent. This document is a decision-collection instrument, not an implementation specification.

## Instructions

Answer every decision below using the project's actual research material and cite the source material used. If the evidence is insufficient, mark the decision **UNRESOLVED** rather than guessing. Distinguish:

- **RESEARCH-SUPPORTED**: directly supported by a cited source.
- **RESEARCHER-PROVIDED**: supplied by the project researcher/mentor but not independently established by the collected literature.
- **ENGINEERING POLICY**: a software/design choice that does not claim research authority.
- **UNRESOLVED**: evidence is insufficient and implementation must remain generic.

For each decision provide: **Decision**, **Rationale**, **Evidence/source**, **Implementation consequence**, **Test/verification consequence**, and **Status**.

---

## 1. Final Platform Scope

Which platforms are in scope for the current research/data model?

Current candidate scope to confirm or reject:
- Instagram
- YouTube
- Facebook
- X
- LinkedIn
- Reddit
- Telegram
- WhatsApp
- ShareChat

Decide whether each is **in scope**, **out of scope**, or **deferred** and explain why.

**Do not assume that the historical project platform list is automatically the final research scope.**

---

## 2. Exact Definition of Context

Define what counts as **context** in Criterivox.

Specify:
- what belongs in supplied context;
- what belongs in system-derived context;
- what is an interpretation rather than context;
- whether task/prompt history is context, evidence for inference, or both;
- what must never be silently promoted into context.

Provide inclusion/exclusion examples.

---

## 3. Normalization Policy

Define what normalization is allowed to change while preserving source meaning.

Decide:
- spelling/format normalization;
- date/time normalization;
- numeric formatting;
- units;
- platform terminology;
- category labels;
- identifiers;
- case sensitivity;
- locale-sensitive values;
- whether platform-specific distinctions must remain explicit.

For every transformation that is allowed, state what provenance must be retained.

---

## 4. Duplicate Semantics

Define when two observations/material records should be treated as:
- exact duplicates;
- probable duplicates;
- distinct observations;
- unresolved duplicate candidates.

Specify which fields are sufficient to establish identity and whether platform/source identity is part of that identity.

**No duplicate rule should silently delete data.**

---

## 5. Anomaly Semantics

Define what constitutes a research/domain anomaly rather than merely a statistical outlier.

Separate:
- statistical outlier;
- invalid value;
- impossible value;
- suspicious but possible value;
- extraction artifact;
- platform-specific irregularity;
- genuine unusual observation.

Specify what Sandre should flag, what it should merely warn about, and what it must never remove automatically.

---

## 6. Missingness Taxonomy

Confirm or revise the generic S5 categories:

- UNKNOWN
- NOT_PROVIDED
- NOT_APPLICABLE
- NOT_MEASURED
- NOT_OBSERVED
- WITHHELD
- UNAVAILABLE
- EXTRACTION_FAILED

For each category state its research meaning, examples, whether it can be converted to another category, and whether numeric zero is ever a valid substitute.

Also specify how missingness should appear in canonical data and analysis handoff.

---

## 7. Confidence Semantics

Define exactly what a confidence value means in Criterivox.

Separate confidence for:
- extraction;
- classification/type detection;
- intent prediction;
- field matching/schema pre-flight;
- anomaly detection, if applicable.

State:
- valid range;
- interpretation of the score;
- whether scores are calibrated;
- what evidence contributes to the score;
- thresholds, if any;
- whether a score may be shown to users.

**Do not describe the current deterministic S5 heuristic as scientifically validated unless the research explicitly supports that claim.**

---

## 8. Intent Prediction Target

Define the intended meaning of **What is this material?** and **Why are you providing it?**.

Specify the final label vocabulary, whether labels are hierarchical, whether multiple labels may coexist, and what constitutes sufficient evidence for a prediction.

Confirm whether the current engineering top-3 heuristic is acceptable as a temporary mechanism until a validated approach exists.

---

## 9. Experimental Targets / Downstream Preparation

What future experiments or analyses must S5 data preparation support?

Specify:
- target variables;
- predictor/feature families;
- required context;
- expected grouping dimensions;
- temporal considerations;
- leakage risks;
- evaluation requirements;
- fields that must remain untouched from source.

S5 should prepare data without pretending to perform the future model/experiment work.

---

## 10. Source and Provenance Requirements

Confirm the minimum provenance required to preserve research traceability.

Decide whether provenance must include:
- source identifier;
- source type;
- original name/location;
- parent folder/collection;
- extraction timestamp;
- transformation history;
- user confirmation/correction;
- external citation/reference;
- version/revision information.

Identify any research-specific provenance requirements missing from the generic S5 model.

---

## 11. Canonical Representation Rules

Define what the canonical representation means from the research perspective.

Specify:
- which concepts must have canonical fields;
- which source-specific fields must remain source-specific;
- whether platform-specific namespaces are required;
- which values may be normalized;
- how supplied context and derived information must remain distinguishable.

---

## 12. Decision Priority and Blocking Status

For every decision above classify it as:

- **S5 BLOCKER**: implementation cannot responsibly finalize the relevant research-specific behavior without this decision.
- **S5 DEFERRED**: generic engineering can continue and the research decision can be added later without redesigning the foundation.
- **S5 CONFIRMED**: evidence is sufficient for implementation.

Do not turn a deferred research question into an invented engineering assumption.

---

# Final Research Decision Record

| Decision | Status | Classification | Evidence | Implementation consequence | Verification |
|---|---|---|---|---|---|
| Platform scope | | | | | |
| Context definition | | | | | |
| Normalization | | | | | |
| Duplicate semantics | | | | | |
| Anomaly semantics | | | | | |
| Missingness taxonomy | | | | | |
| Confidence semantics | | | | | |
| Intent vocabulary | | | | | |
| Experimental targets | | | | | |
| Provenance requirements | | | | | |
| Canonical representation | | | | | |

## Acceptance Rule

A research-specific behavior may be promoted from generic engineering policy into a Criterivox research rule only when its decision record contains:

1. a clear decision;
2. supporting evidence or explicit researcher authority;
3. a stated implementation consequence;
4. a verification/test consequence;
5. a status showing that it is not merely an unresolved assumption.

Until then, preserve the raw material and provenance, keep the behavior generic, and label the decision **UNRESOLVED** or **DEFERRED**.
