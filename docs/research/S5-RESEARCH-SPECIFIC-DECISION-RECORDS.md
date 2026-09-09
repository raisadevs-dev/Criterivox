# CRITERIVOX — S5 RESEARCH-SPECIFIC DECISION RECORDS

> Status: supplied research decision basis for Sprint 5 implementation.
>
> Engineering rule: these decisions are binding research/domain constraints. Unresolved research semantics must remain unresolved. Engineering must not silently replace them with assumptions.

## R-01 — Normalization Policy

**Decision ID:** R-01

**Decision:** Criterivox will use **controlled, provenance-preserving normalization**. Deterministic transformations such as unit, date, and format conversion may be automated. Semantic mappings, synonym merging, category conversion, and cross-platform equivalence must require documented evidence or researcher approval. Original source values, terminology, precision, context, and meaning must remain recoverable.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** S5 research-material collection, extraction, normalization, terminology handling, numeric values, dates, units, categories, and downstream research use.

**Reasoning:** Normalization is necessary to make research material usable, but changing the meaning of source material without evidence can introduce unsupported assumptions. The original representation must therefore remain recoverable.

**Examples:**
- Converting a date into a standard machine-readable format.
- Converting a documented measurement into an agreed unit.
- Preserving an original platform-specific metric name rather than silently replacing it with a supposedly equivalent term.
- Recording a semantic category conversion only when its basis is documented.

**Implementation consequence:** Normalization must be deterministic where possible and must preserve the original value and terminology. Semantic transformations require traceability and, where applicable, researcher approval.

---

## R-02 — Duplicate Semantics

**Decision ID:** R-02

**Decision:** Criterivox will use a **layered, provenance-aware, non-destructive duplicate model combined with similarity-based candidate detection**. Similarity may discover or rank potential duplicates, but similarity alone cannot establish scientific identity. Exact or sufficiently high-confidence duplicates may be automatically flagged, while near duplicates and semantic relationships require appropriate confirmation. Legitimate repeated observations or measurements must remain preserved.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Duplicate detection, repeated observations, source records, similarity analysis, merging, record identity, and data preservation.

**Reasoning:** Two records may look similar without representing the same observation. Conversely, repeated observations may be intentionally valuable. Therefore, duplicate detection must distinguish technical duplication from legitimate repetition.

**Examples:**
- The same research source appearing twice because it was collected through two references.
- Two records containing almost identical text but originating from different sources.
- Repeated measurements that should remain separate observations.
- Similar records being flagged as candidates rather than silently merged.

**Implementation consequence:** The system may use exact matching and similarity methods to identify candidate duplicates, but merging or deletion must be non-destructive and must not rely solely on similarity. Duplicate relationships should remain traceable to their original records.

---

## R-03 — Anomaly Semantics

**Decision ID:** R-03

**Decision:** Criterivox will combine **statistical anomaly detection with a semantic anomaly taxonomy**. An anomaly may represent a statistical outlier, data-entry error, impossible or invalid value, unusual-but-valid observation, platform-specific unusual value, or missing/unknown condition. An anomaly flag must not automatically imply that the underlying observation is invalid.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Data-quality analysis, statistical checks, semantic classification, unusual observations, invalid values, and research-material preservation.

**Reasoning:** An unusual value is not necessarily an erroneous value. Statistical detection can identify unusual observations, but interpretation requires additional context.

**Examples:**
- A numerical value far outside the distribution of other observations.
- A value that violates a known valid range.
- An unusual but legitimate observation.
- A platform-specific value that appears unusual compared with another platform.
- A missing value incorrectly treated as an anomaly.

**Implementation consequence:** Anomaly detection must flag and classify rather than silently delete or correct data. Statistical detection and semantic classification should remain distinguishable.

---

## R-04 — Confidence Semantics

**Decision ID:** R-04

**Decision:** Criterivox will use **separate confidence dimensions** rather than treating confidence as one universal score. Applicable dimensions may include extraction confidence, classification confidence, intent-prediction confidence, research-evidence confidence, and data-quality confidence. A confidence score may only be assigned when its meaning, scale, calculation method, and validation basis are established.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Extraction, classification, research findings, evidence quality, uncertainty, data quality, and downstream interpretation.

**Reasoning:** Confidence in extracting information is different from confidence that a research claim is supported. Combining unrelated meanings into one number can create false precision.

**Examples:**
- High confidence that a value was correctly extracted from a table.
- Lower confidence that a text passage belongs to a particular classification.
- Separate confidence regarding the strength of research evidence.
- No confidence score where an appropriate validated scale has not been established.

**Implementation consequence:** Confidence must be represented with an explicit dimension and defined meaning. Engineering-generated heuristic scores must not be presented as scientifically validated confidence.

---

## R-05 — Platform Scope

**Decision ID:** R-05

**Decision:** The initial core platform scope for Criterivox research will be **Instagram, YouTube, Facebook, X, and LinkedIn**. Inclusion is evidence-gated, and the architecture remains platform-agnostic and extensible. Other previously considered platforms are deferred rather than declared irrelevant.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Platform research, research-material collection, platform terminology, platform-specific data, and cross-platform analysis.

**Reasoning:** A fixed initial core provides a manageable research boundary while avoiding the assumption that the selected platforms represent every possible social platform or that their data are automatically comparable.

**Examples:** Instagram, YouTube, Facebook, X, LinkedIn; Reddit, Telegram, WhatsApp, and ShareChat remain deferred.

**Implementation consequence:** S5 should support the five selected platforms without permanently coupling the research model to them. Platform-specific terminology and limitations must be preserved.

---

## R-06 — Experimental Targets

**Decision ID:** R-06

**Decision:** Experimental targets will be **evidence-derived and represented using a hybrid status model: ESTABLISHED, RESEARCHER-DEFINED, and UNRESOLVED**. The targets concern the **end-user problems, questions, decisions, and needs served by the marketing/content-intelligence use case**, rather than attempting to establish novelty of Criterivox itself.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** End-user problems, research questions, hypotheses, variables, outcomes, experiments, and evaluation criteria relevant to marketing/content intelligence.

**Reasoning:** S5 should identify what the research material actually supports instead of inventing experimental targets merely to populate a software schema. Research targets must remain connected to the end-user problems the application is intended to address.

**Implementation consequence:** Research-target records must carry an explicit status and traceability to supporting evidence where applicable. Unsupported targets must not be presented as established findings.

---

## R-07 — Context Definition

**Decision ID:** R-07

**Decision:** S5 context will function primarily as a **research/search hint**. It guides what should be searched for in provided research material, helps identify intended patterns, structures relevant findings, and supports handoff to the next workflow stage. It is not itself the final context used for end-user decision-making.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Research searching, material interpretation, pattern discovery, extraction, organization, and downstream handoff.

**Reasoning:** The purpose of context at this stage is to constrain and guide research-material discovery rather than prematurely turn extracted information into a final decision-making context.

**Implementation consequence:** Context should be represented as structured research-task information. The system must distinguish context from extracted evidence and from later interpretation or inference.

---

## R-08 — Missingness Taxonomy

**Decision ID:** R-08

**Decision:** Criterivox will use an **explicit, evidence-gated missingness taxonomy**. Candidate states include UNKNOWN, NOT_PROVIDED, NOT_APPLICABLE, NOT_MEASURED, NOT_OBSERVED, WITHHELD, UNAVAILABLE, and EXTRACTION_FAILED, with domain-specific states added only when supported. Missing states must not be treated as interchangeable.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Research-material extraction, incomplete data, unavailable information, data-quality interpretation, and downstream analysis.

**Reasoning:** The reason information is absent can materially affect how it should be interpreted. Treating every missing value as the same condition can create misleading results.

**Implementation consequence:** Missingness must be represented explicitly and must never be silently converted into zero, false, empty, or another substantive value. Unsupported missingness distinctions remain unresolved rather than being invented.

---

## R-09 — Provenance Requirements

**Decision ID:** R-09

**Decision:** Criterivox will use **mandatory core provenance with conditional additional provenance**. The mandatory core includes source identity/reference, collection or access time, source date/version where available, original terminology or value where applicable, citation/reference, and source-to-finding relationship. Conditional provenance must only be retained after explicit **Yes/No confirmation from the end user** for each applicable conditional category.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Research-material collection, extraction, transformation, findings, traceability, reproducibility, user-controlled provenance, and downstream handoff.

**Reasoning:** Research-derived material must remain traceable to its source. Mandatory provenance establishes the minimum traceability requirement, while conditional provenance gives the end user control over additional information retained after extraction.

**Implementation consequence:** Provenance must be represented as structured metadata and linked across source material, extracted information, transformations, and findings. After extraction, applicable conditional provenance categories must be presented as explicit **Yes/No choices**, and the user's decision determines whether they are retained.

---

## R-10 — Evidence and Finding Representation

**Decision ID:** R-10

**Decision:** Criterivox will use a **layered evidence model**:

**Source → Evidence → Finding → Interpretation → Research Question/Hypothesis**

Each layer must remain distinguishable and relationships between layers must be preserved.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Research sources, extracted evidence, findings, interpretation, research questions, hypotheses, traceability, and downstream research workflows.

**Reasoning:** What a source states, what the system extracts, what is derived from that evidence, and what a researcher interprets from it are not necessarily the same thing. Separating these layers prevents interpretation from being presented as source evidence.

**Implementation consequence:** The data model must represent the layers independently and maintain explicit relationships between them. Downstream components must be able to trace a finding back through its evidence to the original source.

---

## R-11 — Cross-Platform Comparability

**Decision ID:** R-11

**Decision:** Cross-platform comparability will be **evidence-gated and tiered**. Relationships between platform variables may be classified as:

- DIRECT
- CONDITIONAL
- RELATED
- NOT_COMPARABLE
- UNRESOLVED

Platform-native terminology and definitions must always be preserved.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Platform metrics, terminology, semantic equivalence, cross-platform research, comparison, and downstream analysis.

**Reasoning:** Similar names or apparently similar measurements do not automatically establish semantic equivalence. Evidence must determine whether comparison is justified and under what conditions.

**Implementation consequence:** Cross-platform comparison must check the established comparability relationship before combining or comparing variables. Unsupported equivalence must not be inferred from naming similarity alone.

---

## R-12 — Research Validation Rules

**Decision ID:** R-12

**Decision:** Criterivox will use a **structured evidence-and-validation process followed by researcher approval where required**. Validation checks include evidence existence, source identification, claim-to-evidence traceability, separation of interpretation from source evidence, required provenance, applicability or conditions, and explicit uncertainty. Appropriate research-derived items may then undergo researcher approval before being treated as established.

**Status:** RESEARCHER-DEFINED

**Priority:** BLOCKING

**Scope:** Research-material validation, evidence assessment, claims, findings, provenance, researcher review, and downstream use.

**Reasoning:** A system extracting information does not automatically establish that the resulting claim is scientifically supported. Validation should therefore examine the relationship between evidence and claim, while researcher review provides an explicit human control point.

**Implementation consequence:** The research workflow must distinguish extracted material, validated evidence-supported findings, researcher-approved established findings, researcher-defined material, and unresolved material. Researcher approval must be an explicit state or action rather than an implicit assumption.

---

## Engineering Guardrails

1. These twelve records are the S5 research/domain basis.
2. Researcher-defined decisions must remain explicitly labelled as such until the project's research process establishes them.
3. Engineering heuristics may assist discovery or triage but must not be presented as research validation or scientifically validated confidence.
4. Source values, native terminology, provenance, missingness, anomalies, and transformation history remain recoverable.
5. No semantic cross-platform equivalence, duplicate identity, anomaly invalidity, experimental target, or confidence meaning may be invented by the implementation.
6. Unresolved research questions remain unresolved and visible to the workflow.
