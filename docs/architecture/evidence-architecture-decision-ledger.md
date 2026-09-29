# CRITERIVOX — S8 Architecture Decision Ledger

**Status:** AUTHORITATIVE FOR S8 IMPLEMENTATION  
**Scope:** Finalized Sets A–J  
**Basis:** S8 Architecture Discussion + consolidated ledger material supplied by project owner

## Purpose

Consolidated ledger of the finalized S8 architecture decisions from Set A through Set J. This ledger records what S8 must be, independent of implementation details.

> **Authority rule:** For S8 implementation, the S8 Architecture Discussion is authoritative for the decisions discussed there, and this file is the GitHub-resident consolidated architecture baseline. Implementation-level choices must not silently alter these decisions.

---

## Set A — Research Problem

### S8-A01 — Core research problem

Evidence/XAI Research Bureau + Evidence/XAI infrastructure + human-inspectable epistemic system framing.

S8 investigates how evidence, provenance, verification, memory, uncertainty, and explanation can be organized as inspectable computational artifacts around AI results, enabling humans to trace, evaluate, question, and challenge the basis and evolution of those results.

### S8-A02 — Primary research subject

Human-inspectable evidence/XAI architecture, with evidence, provenance, verification, memory, uncertainty and explanation organized around results.

### S8-A03 — Primary inspectable object

Result lifecycle + epistemic state:

`origin → materials → processing → evidence → verification → reasoning/result → explanation → uncertainty/limitations → evolution`

### S8-A04 — Temporal scope

Full temporal epistemic trace.

This includes what information/evidence existed, its validity, changes, invalidation, conclusion changes, system knowledge/retention and provenance/explanation evolution.

### S8-A05 — Success criterion

Human-readable explanation + evidence inspection.

### S8-A06 — Human ↔ System correction loop

The system must allow a human to:

1. inspect an abstract path,
2. identify where the system diverged,
3. indicate where it went wrong,
4. provide the intended direction,
5. allow the system to identify affected artifacts/path,
6. record the intervention and provenance,
7. re-evaluate/revise,
8. preserve original and revised histories.

This is not merely free-text disagreement.

---

## Set B — Bureau Boundary

### S8-B01

S8 is an independent Evidence/XAI Research Bureau.

### S8-B02

S8 has a peer relationship with S7, exchanging defined artifacts where needed.

### S8-B03

S8 owns the Evidence/XAI artifact lifecycle and broader epistemic support system.

### S8-B04

S8 may consume raw/source material and defined artifacts through controlled access, but does not receive arbitrary internal system state.

### S8-B05

S8 produces:

- evidence/XAI artifacts,
- machine-readable intervention artifacts,
- revision artifacts.

### S8-B06

S8 can challenge and propose. Cross-system intervention requires explicit human authorization.

### S8-B07

Characters are presentation identities over shared capabilities.

### S8-B08

S8 has four presentation/interaction boundaries:

1. Medrus
2. Epistre
3. Veridat
4. Presentation + Human Intervention/Collaboration

---

## Set C — Information / Artifact Model

### S8-C01

Use typed artifacts + temporal events.

### S8-C02

S8 uses a full epistemic artifact model.

### S8-C03

Use temporal knowledge/provenance relationships through directed artifact relationships.

### S8-C04

Use full transformation provenance and cryptographically verifiable integrity where justified.

### S8-C05

Use full temporal representation.

### S8-C06

Represent uncertainty as structured artifacts with human-readable uncertainty labels.

### S8-C07

Represent contradictions as structured artifacts with clear human-readable conflict representation.

### S8-C08

Challenges may target a specific artifact, a relationship, a path, supporting material, and may contain a proposed alternative path.

### S8-C09

Provide graph representation, evidence-to-result pathways, and an interactive inspectable epistemic map.

### S8-C10

Artifact history represents epistemic evolution, not Git-like version control. S8 is not a version-control system.

### S8-C11

A single underlying artifact remains one artifact. It must not automatically be duplicated across rooms. Each room requests the relevant information particles/components needed for its role.

- Medrus: source/extraction/history/retention particles
- Epistre: provenance/transformation/attribution/explanation particles
- Veridat: verification/contradiction/temporal/integrity/uncertainty particles
- Presentation: cross-S8 pieces needed for human inspection/intervention

---

## Set D — Computational Architecture

### S8-D01

Use a shared capability-based computational subsystem with appropriately separated components.

### S8-D02

Core hierarchy:

`Capability → Mechanism → Engine/Service → Model/Algorithm/Procedure`

Characters retrieve and visually represent dedicated capabilities/materials. Characters do not perform computation.

### S8-D03

Visually use lifecycle-oriented structure for human comprehension. Internally use a hybrid capability + lifecycle architecture.

### S8-D04

Communication uses direct interaction where appropriate and artifact/event exchange for meaningful cross-capability communication. An event bus is not mandatory everywhere.

### S8-D05

Coordination occurs at the capability, application, and domain level. No character becomes the computational boss.

### S8-D06

Model/algorithm selection is capability-driven first.

### S8-D07

Computation produces meaningful inspectable artifacts/events, but not every internal operation must be exposed.

### S8-D08

Primary human visual representation is an abstract **“What happened?” flowchart** rather than literal internal computation. Deeper inspection remains available.

### S8-D09

Human intervention becomes a structured Debate Arena. It is artifact-grounded human ↔ system challenge, not theatrical character argument.

### S8-D10

Re-evaluation is dependency-aware. Only affected relationships/downstream computation should be re-evaluated where possible rather than blindly regenerating everything.

### S8-D11

The system first represents uncertainty/unknown. When a genuine human decision is required, human confirmation is obtained.

### S8-D12

S8 must be independently runnable and integrable through defined artifact/interface contracts.

---

## Set E — Evidence / XAI Capabilities

### S8-E01

Evidence acquisition/structuring preserves raw, extracted and structured evidence, represents evidence as typed artifacts, and links it to originating material.

### S8-E02

Evidence quality/relevance is multi-dimensional and inspectable. No arbitrary unsupported numerical thresholds.

### S8-E03

Source attribution provides claim/evidence particle → source and maintains the attribution graph.

### S8-E04

Provenance provides transformation lineage and human-readable explanatory lineage.

### S8-E05

Verification uses empirical/source-based verification and explicit verification artifacts containing state, support, conflicts, and limitations.

### S8-E06

Contradiction handling preserves competing evidence and possible resolution paths. Contradictions may remain unresolved.

### S8-E07

Temporal validity includes temporal state and invalidation events with dependency-aware propagation.

### S8-E08

Memory consolidates important evidence/relationships while retaining provenance and temporal history.

### S8-E09

Uncertainty is structured and connected to affected artifacts/dependencies.

### S8-E10

Explanation is represented as structured explanation artifacts tied to evidence, provenance, uncertainty, and result paths.

### S8-E11

Evidence dossiers are dynamically assembled from linked artifacts without duplicating artifact identities.

### S8-E12

Human challenge/correction supports structured challenge, evidence/context, proposed alternatives, affected-path detection, re-evaluation, and original/revised lineage.

### S8-E13

Cryptographic integrity is selective and used where materially useful.

### S8-E14

Unknown/research gaps are explicit states containing reason, missing evidence, affected artifacts, and possible resolution paths.

### S8-E15

Capabilities compose through shared artifacts and lifecycle/dependency relationships rather than a rigid linear pipeline.

---

## Set F — Human XAI Interaction

### S8-F01

Primary interaction is an active human-system XAI loop:

`inspect → trace → question → challenge → provide evidence/context → propose correction → re-evaluate → inspect revised state`

### S8-F02

Human authority is explicit and permission-aware.

### S8-F03

Inspectable information includes result, relevant epistemic path, evidence, provenance, and uncertainty. S8 does not expose hidden chain-of-thought.

### S8-F04

Humans can select explanation elements, trace their basis and challenge a specific component.

### S8-F05

Evidence inspection supports evidence graph, pathway, source inspection, result → evidence, and evidence → result.

### S8-F06

Provenance interaction uses graph and human-readable lineage narrative.

### S8-F07

Uncertainty interaction allows identification of causes, missing evidence, weak evidence, and conflicting evidence, and allows humans to provide resolving information.

### S8-F08

Contradiction interaction allows competing evidence comparison and re-evaluation requests. Unresolved contradiction remains possible.

### S8-F09

Challenge targets can be artifact, relationship, path, or supporting material.

### S8-F10

Human correction is represented as structured reasoning + evidence/context + proposed alternative.

### S8-F11

Re-evaluation follows affected dependencies.

### S8-F12

Original and revised states are preserved together with intervention/provenance relationships.

### S8-F13

Debate Arena is artifact-grounded structured debate.

### S8-F14

The system can explicitly request additional missing information.

### S8-F15

Consequential actions require explicit authorization.

### S8-F16

Human interactions are recorded with intervention, target, evidence, authorization, resulting change, and lineage.

---

## Set G — Four-Room UI/UX Boundary

### S8-G01

Exactly four rooms.

### S8-G02 — Medrus

Primary materials: evidence, experimentation-related materials, knowledge retention, historical retrieval, temporal memory, evidence/artifact management, and memory consolidation.

### S8-G03 — Epistre

Primary materials: provenance, explanatory lineage, knowledge transformation, human-readable explanation, attribution, audit narrative, and evidence dossiers.

### S8-G04 — Veridat

Primary materials: empirical verification, fact grounding, source verification, contradiction detection, truth boundaries, temporal validity, integrity/security checks, and uncertainty relevant to verification.

### S8-G05 — Presentation + Human Intervention

Provides S8 overview, cross-S8 presentation, human-readable explanations, evidence/provenance/verification inspection, uncertainty, limitations, contradiction review, source tracing, challenge/intervention, additional evidence/context requests, and re-evaluation interaction.

### S8-G06

Rooms do not all show identical information. They use shared underlying artifacts but expose role-defined information particles.

### S8-G07

Primary visual language supports human comprehension through abstract representation.

### S8-G08

Artifact inspection is available.

### S8-G09

Cross-room navigation is contextual.

### S8-G10

Characters are presentation identities over capabilities.

### S8-G11

Character states reflect actual capability/material states.

### S8-G12

Human intervention UI uses the Debate Arena chatbot with local layered NLP.

### S8-G13

Debate Arena is artifact-grounded structured debate.

### S8-G14

Original and revised states remain inspectable.

### S8-G15

Information density is layered.

### S8-G16

Cross-room state and artifact identity remain consistent.

### S8-G17

Rooms remain independently usable presentation boundaries.

### S8-G18

Accessibility and comprehension are explicit requirements.

---

## Set H — Reliability / Security / Research Validity

### S8-H01

Reliability uses multi-factor epistemic state with explicit failure/unknown states.

### S8-H02

Failures record failure, affected artifacts, downstream impact, and recovery/re-evaluation path.

### S8-H03

Evidence integrity uses the finalized multi-factor cryptographic/integrity direction.

### S8-H04

Provenance integrity validates relationships, integrity evidence, and audit history.

### S8-H05

Access control considers identity, capability, operation, artifact, and context.

### S8-H06

Least privilege is required, with explicit authorization for consequential actions.

### S8-H07

Artifact isolation is controlled by context, capability, and authorization.

### S8-H08

Tampering is flagged, affected relationships/results identified, and trust/use restricted where appropriate.

### S8-H09

Conflicts are preserved and exposed rather than silently resolved.

### S8-H10

Temporal invalidation propagates through relevant dependencies.

### S8-H11

Memory safety retains provenance, temporal state, verification, integrity, and uncertainty.

### S8-H12

Research reproducibility records relevant inputs, artifacts, transformations, events, provenance, and evaluation state.

### S8-H13

Evaluation includes capability-specific experiments, human evaluation, and failure/edge-case evaluation.

### S8-H14

S8 is compared against appropriate existing approaches.

### S8-H15

Human explanation evaluation includes understanding, traceability, ability to detect problematic reasoning, and ability to challenge it.

### S8-H16

Security threat model includes unauthorized access, provenance manipulation, evidence tampering, contaminated knowledge, unauthorized intervention/modification, cross-context leakage, integrity failures, and misleading epistemic state.

### S8-H17

Research claims distinguish demonstrated, empirically supported, provisional, and unknown.

### S8-H18

Novelty is established only where literature/evidence supports it.

### S8-H19

Unknown/open research states explicitly include reason, affected artifacts, and possible resolution.

### S8-H20

Recovery is capability-specific, with escalation where epistemic integrity could be affected.

---

## Set I — Technology / Internal Implementation Constraints

### S8-I01

Primary application: Flutter/Dart with hybrid architecture.

### S8-I02

Computational backend: Python.

### S8-I03

Internal organization: capability + lifecycle + shared infrastructure.

### S8-I04

Use typed contracts with hybrid direct/artifact/event communication.

### S8-I05

Use hybrid typed artifact + graph relationship representation.

### S8-I06

Local persistence includes IndexedDB, internal local SQLite, and additional persistence only where justified.

### S8-I07

Use established provenance models/standards where appropriate, with hybrid implementation.

### S8-I08

Temporal representation uses event records + temporal graph relationships where appropriate.

### S8-I09

Evidence acquisition can combine deterministic extraction, NLP, and human-assisted extraction.

### S8-I10

Verification can combine rules, source comparison, statistical/ML mechanisms, and other justified mechanisms.

### S8-I11

Contradiction detection combines semantic/NLP mechanisms with human-mediated resolution where needed.

### S8-I12

Uncertainty uses structured multi-dimensional representation.

### S8-I13

Memory uses consolidation infrastructure while retaining epistemic metadata.

### S8-I14

Retrieval is hybrid.

### S8-I15

Debate Arena uses local layered NLP.

### S8-I16

LLMs may be used selectively, capability-by-capability, locally rather than as mandatory online services.

### S8-I17

Explanation uses structured artifacts with deterministic rendering and optional hybrid generation.

### S8-I18

Cryptographic integrity is selective/adaptive.

### S8-I19

Authorization combines capability/operation and attribute/context-aware controls.

### S8-I20

Interventions are dedicated artifacts/events linked to provenance.

### S8-I21

Testing uses all appropriate layers.

### S8-I22

Research instrumentation includes structured experiment records, execution receipts, artifact/provenance records, and human-evaluation records.

### S8-I23

Reuse established standards/components where adequate; customize justified gaps.

### S8-I24

Hybrid deployment within the local Criterivox context.

### S8-I25

S7/future integration through defined artifact/interface/event contracts.

### S8-I26

Characters use capability interfaces/presentation adapters rather than computational ownership.

### S8-I27

UI synchronization is reactive/event-driven.

### S8-I28

Experimental mechanisms remain separately configurable/isolated from stable application behavior.

---

## Set J — Final Architecture Validation

### S8-J01

Research and architecture are fully aligned.

### S8-J02

S8 is independently runnable and peer to S7.

### S8-J03

Characters and computation are separated.

### S8-J04

Four rooms are presentation/interaction boundaries.

### S8-J05

Shared artifact identity is preserved across views.

### S8-J06

Artifacts, events, relationships and temporal states are sufficiently defined.

### S8-J07

Provenance is linked to transformations/results.

### S8-J08

Contradiction, uncertainty, unknown and invalidation are representable without forced resolution.

### S8-J09

Human challenges target inspectable artifacts/relationships/paths.

### S8-J10

Authorized dependency-aware re-evaluation preserves original/revised lineage.

### S8-J11

Human authority is separate from computational authority.

### S8-J12

Security/integrity align with epistemic meaning.

### S8-J13

No unsupported thresholds or unjustified heuristics.

### S8-J14

Major capabilities map to mechanisms and implementation responsibilities.

### S8-J15

Empirical evaluation and reproducibility are supported.

### S8-J16

Technology remains subordinate to the research architecture.

### S8-J17

S8 operates locally without mandatory online LLM/service dependency.

### S8-J18

S7/future integration uses defined contracts without hidden coupling.

### S8-J19

Research contributions are distinguishable from reused technology.

### S8-J20

Architecture is implementation-ready with only explicitly documented implementation-level OPEN items.

---

## Architecture Invariants

1. Characters present computation; they do not perform it.
2. Rooms provide different views/materials over shared underlying artifacts.
3. S8 is a peer to S7, not a child or hidden dependency.
4. Human authority remains explicit.
5. Unknown, uncertainty, contradiction and invalidation are legitimate states.
6. No arbitrary unsupported thresholds or confidence values.
7. S8 does not expose hidden chain-of-thought as its XAI mechanism.
8. Interventions preserve original and revised lineage.
9. Technology serves the research architecture.
10. Research novelty must be demonstrated, not assumed from integration alone.
