# Criterivox World Map — Level 2, Part V
## Evidence & Experiment Quarter, Private Room & Collaboration Room
### Internal Functional-Spatial Specification

> Status: Internal UX / spatial architecture specification  
> Scope: Evidence & Experiment Quarter + Gate 2 human decision spaces  
> Naming rule: Level-1 world-map names are canonical. Legacy numeric Home labels are intentionally excluded.  
> Core principle: Every visible spatial element must correspond to a real responsibility, interaction boundary, runtime event, evidence state, human intervention point, or explicitly labelled simulation.

## 1. Purpose

Level 2 Part V defines the internal spatial and functional behavior of the Evidence & Experiment Quarter and the Gate 2 Private Room and Collaboration Room. It translates research architecture into inspectable spatial structures without redefining the computational architecture.

## 2. Level-1 Naming Alignment

| Level-1 element | Level-2 internal specification |
|---|---|
| Evidence & Experiment Quarter | Evidence & Experiment Home |
| Medrus | Knowledge Retention / Historical Memory |
| Epistre | Epistemological Transfer / Explanatory Provenance |
| Veridat | Empirical Truth Verification / Contextual Truth |
| Private Room | Personal Human Decision Lab |
| Collaboration Room | Multi-Human / Multi-Agent Decision Room |
| Gate 2 | Human Territory |

Legacy labels Home 06, Home 07, and Home 08 are not used as spatial names.

## 3. Shared Spatial Grammar

- Home = living functional responsibility.
- Hall = shared inspection and coordination.
- Workshop = transformation or construction.
- Chamber = deep inspection, verification, or intervention.
- Vault / Archive = retained historical material.
- Desk = focused operation.
- Observatory = continuous monitoring.
- Gate = controlled transition.
- Garden = reflective exploration.
- Street / Junction = system connection.

These are spatial representations of responsibilities, not decorative rooms or independent character intelligence.

# PART I — EVIDENCE & EXPERIMENT QUARTER

## 4. Evidence & Experiment Home

### Role

The Evidence & Experiment Home is Criterivox's evidence-grounding, empirical verification, provenance, and historical-retrieval environment.

It addresses:

- fact grounding and source verification;
- evidence-to-knowledge lineage;
- historical retrieval;
- contradiction and truth-boundary resolution;
- temporal invalidation;
- deterministic versus probabilistic retrieval;
- cryptographic integrity where implemented;
- workspace and role isolation;
- memory poisoning resistance;
- semantic uncertainty and drift;
- granular source attribution.

### Character responsibilities

**Medrus**
- historical memory
- temporal retrieval
- knowledge retention
- memory consolidation
- scoped retrieval

**Epistre**
- explanatory provenance
- evidence-to-knowledge narrative
- citation mapping
- audit dossier construction

**Veridat**
- empirical verification
- contradiction detection
- grounding assessment
- temporal truth checks
- evidence integrity

The three responsibilities remain distinct while sharing one home.

## 5. Evidence Hall

Shared entry and inspection space.

Functional surfaces:
- Claim Status Wall
- Evidence Flow Table
- Verification Queue
- Knowledge Transfer Lane
- Contradiction Beacon

Claim states may include GROUNDED, WEAK, UNSUPPORTED, and VERIFICATION_REQUIRED.

The Hall gives evidence status without exposing private model chain-of-thought.

## 6. Grounding Matrix Chamber

**Owner:** Veridat

Functions:
1. Claim-to-source matching.
2. Evidence sufficiency inspection.
3. Grounding classification.
4. Execution-artifact verification.
5. Unsupported-claim quarantine.
6. Downstream blocking when required evidence is absent.

A selected claim becomes the central node. Supporting evidence surrounds it. Missing support is displayed as an explicit gap rather than an invented relationship.

Outputs:
- GROUNDED
- WEAK
- UNSUPPORTED
- VERIFICATION_REQUIRED

## 7. Provenance Workshop

**Owner:** Epistre

Transforms verified evidence into an inspectable provenance narrative.

Functions:
- prompt/context lineage inspection;
- hypothesis-to-evidence linkage;
- verification receipt attachment;
- source-to-claim mapping;
- provenance graph inspection;
- audit narrative assembly.

Primary object: Knowledge Provenance Tree.

Selecting a final claim reveals available source artifacts, verification records, context references, and transformation stages. The interface exposes auditable provenance, not hidden chain-of-thought.

## 8. Temporal Memory Vault

**Owner:** Medrus

Historical knowledge retention and retrieval.

Functions:
- verified historical search;
- event-time filtering;
- system-time filtering;
- superseded-fact inspection;
- historical/current comparison;
- memory-node provenance;
- prior verified outcome retrieval.

Where implemented:
- Event Time = when the underlying event or fact occurred.
- System Time = when Criterivox recorded or learned it.

History is retained rather than silently overwritten.

## 9. Contradiction Reconciliation Chamber

**Shared:** Veridat ↔ Medrus

Workflow:

NEW CLAIM → CONFLICT DETECTED → EVIDENCE COMPARISON → TEMPORAL CHECK → RECONCILIATION → ACCEPT / SUPERSEDE / QUARANTINE

Inspection panel:
- retained record;
- incoming claim;
- source provenance;
- temporal metadata;
- verification state;
- reconciliation result.

A newer record is not automatically treated as more truthful.

## 10. Receipt & Artifact Vault

Stores verifiable records associated with data transformations and external execution artifacts.

Inspectable metadata:
- artifact identifier;
- source;
- timestamp;
- content hash where implemented;
- transformation stage;
- execution receipt;
- integrity state.

Receipt Inspector states:
- RECEIPT_VALID
- RECEIPT_MISSING
- INTEGRITY_CHECK_REQUIRED
- INTEGRITY_MISMATCH

Cryptographic indicators must represent actual implementation state.

## 11. Bi-Temporal Truth Observatory

**Owner:** Veridat

Primary control: Temporal Truth Slider.

Allows inspection of:
- historical state;
- superseded state;
- current state;
- invalidation event;
- evidence responsible for the transition.

Invalidation records historical change. It does not erase the historical record.

## 12. Retrieval Mode Chamber

Makes retrieval strategy inspectable.

Where implemented, the system may distinguish:

**Probabilistic retrieval**
- vector retrieval;
- graph retrieval;
- similarity evidence.

**Deterministic semantic execution**
- typed query;
- compiled semantic operation;
- reproducible result.

A Retrieval Mode Badge identifies the actual path used. The interface must never present probabilistic retrieval as deterministic compilation.

## 13. Provenance Dossier Desk

**Owner:** Epistre

Packages evidence into an audit-ready artifact.

Contents:
- claim list;
- source references;
- verification status;
- provenance graph;
- temporal status;
- execution receipts where available;
- integrity metadata where implemented;
- unresolved limitations.

Output: PROVENANCE_DOSSIER.

## 14. Memory Consolidation Observatory

**Owner:** Medrus

Makes background memory maintenance observable.

Operations:
- duplicate detection;
- node consolidation;
- relevance assessment;
- graph compaction;
- stale-fragment review;
- memory utility evaluation.

State presentation:
- IDLE
- CONSOLIDATING
- REVIEW_REQUIRED
- COMPLETED
- BLOCKED

Core verified facts must not be removed merely to improve a cosmetic graph metric.

## 15. Memory Integrity & Isolation Chamber

**Shared:** Medrus + Veridat

Protects persistent memory from untrusted or unauthorized writes.

Inspection surfaces:
- incoming memory write;
- source trust state;
- authorization context;
- contradiction state;
- suspected injection state;
- quarantine state;
- workspace / role scope.

Possible outputs:
- WRITE_APPROVED
- WRITE_REJECTED
- QUARANTINED_INPUT
- UNVERIFIED_SOURCE
- ACCESS_DENIED

## 16. Tenant Security Observatory

**Owner:** Medrus

Makes workspace and role boundaries visible.

Scope metadata:
- workspace;
- user role;
- confidentiality tier;
- retrieval scope;
- denied records;
- filtering policy.

Authorization is part of retrieval, not a cosmetic layer added afterward.

## 17. Semantic Entropy & Drift Observatory

**Owner:** Veridat

Provides an uncertainty-monitoring surface for supported evaluation methods.

Functions:
- compare alternative output interpretations;
- identify high uncertainty;
- trigger retrieval review;
- identify semantic drift;
- record retry or escalation state.

A displayed metric must correspond to a defined implementation or research prototype. A decorative percentage is not evidence.

## 18. Line-Level Attribution Studio

**Owner:** Epistre

Links generated claims to the finest available source unit.

Split view:

**Claim View**
- generated claim;
- citation marker;
- verification state.

**Source View**
- source document;
- chunk;
- line/range where available;
- ingestion metadata.

Selecting a claim highlights its available evidence path.

## 19. Evidence-to-Knowledge Transfer Gate

**Connection:** Evidence & Experiment Quarter → Knowledge Quarter

Separates verified evidence from generalized reusable knowledge.

A transfer package may contain:
- validated finding;
- evidence references;
- provenance;
- temporal state;
- verification status;
- known limitations;
- reuse conditions.

An uncertain observation must not silently become a universal rule.

# PART II — CROSS-QUARTER EVIDENCE NETWORK

## 20. Intelligence → Evidence

**Vivren / Tarkis → Veridat**

Purpose:
- hypothesis verification;
- empirical challenge;
- unsupported-claim detection.

## 21. Decision & Action → Evidence

**Pramon / Bodhex → Evidence & Experiment Home**

Purpose:
- empirical assumption checking;
- historical execution comparison;
- evidence-readiness inspection.

## 22. Evidence → Knowledge

**Medrus / Epistre / Veridat → Viveda**

Purpose:
- transfer validated findings for generalization;
- preserve provenance;
- preserve limitations and reuse conditions.

## 23. Evidence → Human Territory

Evidence can surface to the human as:
- source-backed claim;
- verification state;
- provenance path;
- contradiction notice;
- temporal change;
- action receipt;
- uncertainty indicator.

The human receives inspectable evidence, not hidden model reasoning.

# PART III — GATE 2: PRIVATE ROOM

## 24. Private Room — Personal Decision Lab

The Private Room is the human's controlled decision environment.

It is not another AI home. The human remains the decision authority.

Primary lifecycle:

GOAL → DATA + CONTEXT → OPTIONS → HUMAN CHALLENGE → DECISION → APPROVAL → ACTION → REAL RESULT → JOURNAL → FUTURE CONTEXT

## 25. Goal & Context Decomposition Desk

Turns an incomplete human goal into explicit decision inputs.

Visible fields:
- Goal
- Static Data
- Dynamic Context
- Missing Variables
- Ambiguous Bounds
- Constraints

States:
- DATA_COMPLETE
- CONTEXT_SLOT_MISSING
- AMBIGUOUS_BOUNDS
- READY_FOR_ANALYSIS

Dharen may identify missing context, but the system must not silently invent it.

## 26. Decision Options Observatory

Presents alternatives as trade-offs rather than one supposedly perfect answer.

Possible dimensions:
- speed;
- reliability;
- resource cost;
- complexity;
- evidence strength;
- reversibility.

The human can inspect how changing priorities changes available options.

## 27. Human Challenge Bench

**Connection:** Private Room ↔ Manis's Challenge & Review Quarter

Allows the human to challenge assumptions before commitment.

Controls:
- challenge premise;
- modify variable;
- reject option;
- request evidence;
- request counterfactual;
- send to stress test.

Disagreement is an explicit interaction, not an error condition.

## 28. Action Safety Gate

**Connection:** Private Room → Pramon / Bodhex

Creates a deliberate checkpoint before consequential execution.

Approval briefing:
- action scope;
- blast radius;
- required permissions;
- expected resource use;
- rollback/recovery information where available;
- evidence status;
- unresolved uncertainty.

The interface requires explicit human authorization before consequential dispatch. The exact approval mechanism must match the implemented security policy.

## 29. Results Journal

Records what actually happened after a decision.

Record:
- original goal;
- selected option;
- predicted outcome;
- actual result;
- deviation / variance;
- human notes;
- evidence of outcome;
- subsequent learning status.

The journal records outcomes. It must not manufacture success.

## 30. Decision Timeline

Chronological decision lineage:

INPUT → OPTIONS → CHALLENGES → DECISION → ACTION → RESULT → LEARNING

Users can inspect what changed between stages.

# PART IV — GATE 2: COLLABORATION ROOM

## 31. Collaboration Room — Shared Decision Space

Extends Human Territory from one decision-maker to multiple human participants.

It preserves:
- privacy;
- role boundaries;
- disagreement;
- accountability;
- evidence visibility;
- explicit authorization.

## 32. Human Role Model

| Role | Core Access |
|---|---|
| **House Owner** | Workspace administration, privacy policy, authorization |
| **Resident** | Scoped collaborative work and decision participation |
| **Guest** | Restricted, temporary, explicitly scoped access |

The current role and scope must remain visible.

## 33. Context Masking Wall

Shows which information is visible to each participant.

Example states:
- PUBLIC_TO_ROOM
- RESIDENT_ONLY
- OWNER_CONFIDENTIAL
- GUEST_MASKED

Sensitive context must be filtered by actual authorization, not merely hidden visually.

## 34. Consensus & Disagreement Observatory

Makes human disagreement explicit.

Functions:
- structured option comparison;
- individual positions;
- supporting reasons;
- unresolved disagreements;
- challenge requests;
- decision status.

The system records disagreement instead of manufacturing consensus.

## 35. Team Context Stream

**Connection:** Syvax ↔ Dharen

Separates useful decision information from ordinary conversation.

Structured categories:
- goal update;
- data input;
- decision constraint;
- evidence;
- action request;
- clarification;
- non-decision conversation.

Only information accepted into working context should affect downstream computation.

## 36. Multi-Signatory Action Gate

Provides an explicit human authorization boundary for high-impact shared actions.

Multi-Key Dispatch Bar displays:
- required approvals;
- collected approvals;
- missing approvals;
- authorization scope;
- action status.

Execution remains locked until actual policy requirements are satisfied.

## 37. Shared Results Journal

Records collaborative outcomes and human contribution.

Record:
- shared goal;
- selected decision;
- approval participants;
- execution record;
- real-world result;
- contributor attribution;
- follow-up learning.

Medrus may retain appropriately scoped historical outcomes for future retrieval.

# PART V — SHARED HUMAN–AI NETWORK

## 38. Human Territory ↔ Criterivox Civilization

Gate 2 connects to Gate 1 through controlled interfaces.

Primary links:
- Human → Syvax: goal and interaction
- Human → Dharen: context clarification
- Human → Manis: challenge
- Human → Pramon: planning/decision inspection
- Human → Bodhex: authorized execution
- Evidence & Experiment Home → Human: evidence/provenance
- Human → Results Journal: real-world outcome
- Results Journal → Medrus/Viveda: appropriately scoped learning

## 39. Bloom Relationship

Bloom remains the **global spatial nexus**. Part V does not redefine Bloom.

From the Evidence & Experiment Quarter, Bloom may expose:
- evidence-flow status;
- verification checkpoints;
- knowledge-transfer routes;
- contradiction alerts;
- provenance paths;
- human intervention checkpoints.

From Gate 2, Bloom may expose:
- active human decision;
- pending approval;
- collaboration state;
- evidence request;
- outcome-return path.

These are navigation/inspection relationships, not duplicate Bloom implementations.

# PART VI — HUMAN INTERVENTION MODEL

## 40. Intervention Boundaries

Human intervention may be required at:

1. ambiguous goal framing;
2. missing critical context;
3. unresolved evidence contradiction;
4. insufficient evidence;
5. high-impact action approval;
6. unauthorized data access;
7. unresolved multi-human disagreement;
8. irreversible or high-blast-radius execution;
9. significant outcome deviation;
10. knowledge promotion where evidence is insufficient.

Exact thresholds are implementation-dependent and must be documented by policy.

# PART VII — CHARACTER STATE PRESENTATION

## 41. Shared Semantic States

Characters use the established semantic state model:
- IDLE
- RECEIVE
- WORK
- COMMUNICATE
- HANDOFF
- COMPLETE
- WARNING

Attention states:
- QUIET
- ATTENTIVE
- FOCUSED
- BUSY
- WAITING
- NEEDS_USER
- COMPLETING
- RECOVERING

Characters visually represent system responsibility and state. They do not become independent decorative intelligence.

# PART VIII — ACCESSIBILITY & AGE-PROGRESSIVE HCI

## 42. Accessibility

Every evidence or decision state must provide:
- text status;
- accessible labels;
- keyboard/controller navigation where supported;
- non-motion alternatives;
- reduced-motion mode;
- color-independent status communication;
- readable evidence/source references;
- clear error and recovery states.

## 43. Progressive Depth

**Entry**
- who verifies;
- who remembers;
- who explains;
- who challenges;
- where decisions happen.

**Intermediate**
- evidence links;
- provenance;
- contradictions;
- historical changes;
- human approvals;
- collaboration roles.

**Advanced**
- temporal models;
- retrieval modes;
- integrity receipts;
- authorization scope;
- evidence lineage;
- uncertainty evaluation;
- outcome variance;
- research-prototype internals.

One world remains intact. Depth changes with interaction.

# PART IX — RUNTIME TRUTH CONTRACT

## 44. Capability Labels

Every advanced capability must be explicitly classified as:

- **LIVE** — implemented and connected to runtime.
- **SIMULATED** — demonstrative behavior.
- **PLANNED** — specified but not implemented.
- **RESEARCH PROTOTYPE** — experimental implementation under evaluation.
- **HISTORICAL** — retained record from an earlier state.

This applies especially to:
- cryptographic receipts;
- deterministic semantic compilation;
- semantic entropy;
- tenant isolation;
- temporal invalidation;
- memory consolidation;
- attribution mapping;
- multi-signatory approval;
- prediction variance;
- automated memory sanitation.

A visual effect cannot be presented as security, verification, cryptography, or evidence.

# PART X — RESEARCH & HCI GAIN

## 45. Research Value

Part V provides a spatial model for evaluating:

1. **Evidence traceability** — Can users locate why a claim is considered supported?
2. **Provenance comprehension** — Can users follow a finding from source to verified knowledge?
3. **Temporal understanding** — Can users distinguish current truth from historically valid but superseded information?
4. **Contradiction handling** — Can users understand unresolved conflicts without being forced into false certainty?
5. **Human authority** — Can users identify where their approval is required?
6. **Decision accountability** — Can users reconstruct what was decided, why, and what happened afterward?
7. **Collaborative transparency** — Can multiple humans understand access boundaries and disagreement?
8. **Trust calibration** — Does evidence visibility help users distinguish verified information from uncertain or unsupported output?
9. **Progressive disclosure** — Can the same environment support novice exploration and advanced system inspection?
10. **Research-loop closure** — Can real-world outcomes return to evidence, memory, and future decision context?

# PART XI — ACCEPTANCE CRITERIA

## 46. Evidence & Experiment Home

Complete when:
- Medrus, Epistre, and Veridat have distinct responsibilities;
- claims can be represented independently from evidence;
- provenance can be inspected;
- historical states can be represented;
- contradictions have an explicit reconciliation state;
- evidence-to-knowledge transfer has a defined boundary;
- security/integrity capabilities are not falsely presented as live.

## 47. Private Room

Complete when:
- goal/context inputs are separated;
- missing variables can be surfaced;
- alternatives are inspectable;
- human challenge is explicit;
- consequential action has an approval boundary;
- actual outcomes can be recorded.

## 48. Collaboration Room

Complete when:
- Owner/Resident/Guest roles are visible;
- context scope is enforced;
- disagreement can be recorded;
- high-impact actions have explicit authorization;
- team outcomes preserve contributor attribution.

# PART XII — BOUNDARY WITH LEVEL 2 PART VI

Part V ends at:

**Evidence & Experiment Quarter + Gate 2 Private Room + Gate 2 Collaboration Room.**

It does not redefine:
- Intelligence Quarter;
- Decision & Action Quarter;
- Knowledge Quarter;
- Challenge & Review Quarter;
- Gateway Quarter;
- Data Stewardship Quarter;
- Context Quarter;
- Anukor's network layer;
- global Bloom architecture.

Part VI should continue only with the next Level-1 world areas and their internal spatial specifications, without duplicating responsibilities already defined here.

## 49. Canonical Level-2 Part V Model

~~~text
GATE 1 — CRITERIVOX CIVILIZATION
│
├── Evidence & Experiment Quarter
│   └── Evidence & Experiment Home
│       ├── Evidence Hall
│       ├── Grounding Matrix Chamber
│       ├── Provenance Workshop
│       ├── Temporal Memory Vault
│       ├── Contradiction Reconciliation Chamber
│       ├── Receipt & Artifact Vault
│       ├── Bi-Temporal Truth Observatory
│       ├── Retrieval Mode Chamber
│       ├── Provenance Dossier Desk
│       ├── Memory Consolidation Observatory
│       ├── Memory Integrity & Isolation Chamber
│       ├── Tenant Security Observatory
│       ├── Semantic Entropy & Drift Observatory
│       ├── Line-Level Attribution Studio
│       └── Evidence-to-Knowledge Transfer Gate
│
└── BLOOM
    └── global nexus / navigation / system-state relationship

GATE 2 — HUMAN TERRITORY
│
├── Human Residence
│   ├── Private Room
│   │   ├── Goal & Context Decomposition Desk
│   │   ├── Decision Options Observatory
│   │   ├── Human Challenge Bench
│   │   ├── Action Safety Gate
│   │   ├── Results Journal
│   │   └── Decision Timeline
│   │
│   └── Collaboration Room
│       ├── Context Masking Wall
│       ├── Consensus & Disagreement Observatory
│       ├── Team Context Stream
│       ├── Multi-Signatory Action Gate
│       └── Shared Results Journal
│
└── CONTROLLED LINKS
    ├── Syvax
    ├── Dharen
    ├── Manis
    ├── Pramon
    ├── Bodhex
    ├── Medrus
    └── Viveda
~~~

## 50. Canonical Design Statement

**Level 2 Part V turns evidence, memory, provenance, human authority, and collaborative decision-making into spatially inspectable structures. The Evidence & Experiment Quarter makes the truth lifecycle visible; the Private Room preserves individual human authority; and the Collaboration Room makes shared authority, disagreement, privacy, and accountability explicit.**


## Pass 1 implementation status — Evidence & Experiment Quarter

The canonical runtime remains `src/criterivox/s8/`. Pass 1 adds `src/criterivox/s8/part5.py` as an integration adapter rather than a second Evidence engine.

Implemented through the existing S8 artifacts/events/policy:
- Grounding Matrix data via claim verification;
- Provenance Dossier assembly;
- contradiction reconciliation state;
- Receipt/Artifact inspection with integrity verification;
- bi-temporal inspection;
- explicit deterministic/probabilistic retrieval-mode reporting;
- memory consolidation state inspection;
- tenant/context security inspection;
- semantic entropy as an explicitly labelled RESEARCH PROTOTYPE;
- line/chunk attribution when source metadata is available;
- Evidence → Knowledge transfer package.

Browser API surface: `/api/world/level2/part5/evidence/*`.

The Evidence Home presentation now reads the canonical runtime overview. It does not create a parallel evidence store or verification engine.


## Pass 2 implementation status — Cross-Quarter Evidence Network

Pass 2 makes the four Part V cross-quarter relationships use one canonical evidence handoff contract rather than separate ad-hoc payloads.

### Canonical contract

`EvidenceHandoff` in `src/criterivox/s8/part5.py` carries:
- source evidence references;
- request/claim/purpose context;
- validation and verification references;
- provenance and limitations;
- assumptions and uncertainty;
- destination;
- update reason;
- timestamp.

### Connected flows

- **20 Intelligence → Evidence:** Part IV now has evidence-request and evidence-handoff routes backed by the S8 surface.
- **21 Decision & Action → Evidence:** the canonical handoff accepts decision/evidence handoff types, so decision flows can consume the same contract rather than a second evidence object.
- **22 Evidence → Knowledge:** Part III exposes an evidence-handoff route backed by the same S8 contract; existing bounded knowledge transfer remains available for knowledge proposals.
- **23 Evidence → Human Territory:** the same handoff contract is destination-neutral, allowing Private Room / human-territory consumers to receive the same evidence package without a new evidence engine.

### Stale-test/documentation rule

Pass 2 tests assert the canonical handoff contract and rejection of unknown evidence. Older Part III/IV handoff behavior remains documented as compatibility behavior where present; no legacy engine is deleted merely because the canonical adapter now exists.


## Pass 3 implementation status — Gate 2 Private Room

Pass 3 completes the Private Room integration around the existing Human Residence and decision pipeline. No second decision engine or authorization engine is introduced.

### Canonical lifecycle

`GOAL → DATA + CONTEXT → OPTIONS → CHALLENGE → DECISION → APPROVAL → ACTION → RESULT → JOURNAL`

Implemented/refined:
- explicit context readiness state: `CONTEXT_SLOT_MISSING`, `DATA_COMPLETE`, `AMBIGUOUS_BOUNDS`, `READY_FOR_ANALYSIS`;
- explicit decision stage tracking;
- Decision Options Observatory presentation over existing strategy vectors;
- Human Challenge Bench backed by the existing challenge endpoint;
- Action Safety Gate briefing with evidence/uncertainty/challenge state and existing authorization controls;
- persisted Decision Timeline using the existing Human Residence metadata boundary;
- Results Journal remains outcome-based and does not manufacture success;
- Evidence → Private Room uses the canonical Part V `EvidenceHandoff` destination `private_room`.

### Acceptance reconciliation

The Private Room acceptance criteria in §47 are now represented by the existing runtime: separated goal/context inputs, surfaced missing variables, inspectable alternatives, explicit challenge, approval boundary, and actual outcome recording. Richer timeline/event inspection is now exposed directly in the Private Room rather than requiring a separate decision backend.
