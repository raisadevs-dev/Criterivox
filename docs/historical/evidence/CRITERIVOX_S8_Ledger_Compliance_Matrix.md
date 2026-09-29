# CRITERIVOX — S8 LEDGER COMPLIANCE MATRIX & IMPLEMENTATION BACKLOG

**Sprint:** S8 — XAI / Evidence Research Bureau  
**Purpose:** Convert the three S8 decision ledgers into one implementation-control backlog without collapsing the ledgers into one decision source.  
**Baseline:** 17 September 2026  
**Status vocabulary:** `DONE` = evidenced as implemented; `PARTIAL` = some implementation exists but acceptance criteria are incomplete; `OPEN` = required work is not yet implemented/evidenced; `BLOCKED` = cannot be completed until a dependency/decision is resolved; `N/A` = not applicable to this implementation slice.

---

## 1. Governing rule

The three ledgers remain authoritative and separate:

1. **Architecture Decision Ledger** — architecture, boundaries, artifacts, computational architecture, XAI, human authority, reliability, security, validation.
2. **UI/UX + Functional Specification Ledger** — four rooms, Medrus/Epistre/Veridat responsibilities, Presentation/Human Intervention, character behavior, artifacts, navigation, information density, Debate Arena, intervention flow.
3. **Technology & Internal Implementation Decision Ledger** — Flutter + Python, IndexedDB + local SQLite, artifact/persistence, provenance, temporal infrastructure, local NLP/LLM boundary, verification, contradiction, memory, authorization, cryptographic integrity, testing, instrumentation, deployment, S7 integration.

The matrix **does not create new architecture**. It translates ledger requirements into implementation work and evidence.

---

# 2. Compliance Matrix

| ID | Ledger source | Compliance area | Required implementation outcome | Current evidence/state | Status | Backlog action | Priority |
|---|---|---|---|---|---|---|---|
| ARC-01 | Architecture | S8 boundary | S8 must have a clear architectural boundary from surrounding Criterivox components. | S8 branch exists and the Evidence/XAI Bureau is being implemented as its own slice. Full boundary acceptance evidence is not yet established here. | PARTIAL | Document and test inbound/outbound S8 interfaces. | P0 |
| ARC-02 | Architecture | Four-room architecture | Medrus, Epistre, Veridat and Presentation must exist as the four-room S8 environment. | S8 environment/entities exist; current UI work is being expanded around these rooms. | PARTIAL | Verify all four rooms, navigation, room identity and room-specific responsibilities end-to-end. | P0 |
| ARC-03 | Architecture | Character ≠ computation | Characters must represent/communicate system activity, not become computational engines. | Existing project direction explicitly preserves this separation. | PARTIAL | Trace every character action to authoritative state/event/artifact and remove UI-owned intelligence decisions. | P0 |
| ARC-04 | Architecture | Authoritative state | Meaningful visual/system state must originate from authoritative S8 artifacts, events, states or results. | Ambient animation layer exists, but full state-to-visual wiring is not yet evidenced. | PARTIAL | Build state/event → presentation-state mapping and tests. | P0 |
| ARC-05 | Architecture | Artifact model | Evidence/XAI artifacts must have stable structured representations rather than only transient widgets. | Technology ledger requires artifact/persistence architecture; full implementation completeness not yet evidenced. | OPEN | Audit/create canonical S8 artifact models and serializers. | P0 |
| ARC-06 | Architecture | Provenance | Meaningful evidence/explanation artifacts must retain traceable provenance. | Provenance is a ledger requirement; implementation completeness not yet evidenced. | OPEN | Implement provenance links and inspection UI; add round-trip tests. | P0 |
| ARC-07 | Architecture | XAI explanation path | Explanations must expose what happened, why, context, factors, evidence, reasoning path, uncertainty, limitations and provenance where applicable. | UI concept contains explanation/provenance surfaces, but full functional implementation is not evidenced. | OPEN | Define explanation artifact contract and render each field from authoritative data. | P0 |
| ARC-08 | Architecture | Human authority | Human inspection/challenge/intervention must remain explicit and must not be silently converted into autonomous system decisions. | Presentation/Human Intervention is part of the S8 specification. | PARTIAL | Implement intervention events, authorization boundaries and audit trail. | P0 |
| ARC-09 | Architecture | Reliability/uncertainty | S8 must represent uncertainty, limitations, insufficient evidence/context and unresolved conflicts honestly. | Hub concept exposes unresolved uncertainties and conflicting evidence; backend semantics are not fully evidenced. | PARTIAL | Implement canonical uncertainty/limitation/contradiction states and UI rendering. | P0 |
| ARC-10 | Architecture | Security/integrity | Integrity, authorization and cryptographic provenance requirements must be implemented where specified. | Technology ledger explicitly includes authorization and cryptographic integrity; full implementation not evidenced. | OPEN | Audit existing security primitives, implement missing pieces, add tamper tests. | P0 |

| ID | Ledger source | Compliance area | Required implementation outcome | Current evidence/state | Status | Backlog action | Priority |
|---|---|---|---|---|---|---|---|
| UI-01 | UI/UX | S8 Home visual composition | Opening surface should be a cinematic intelligence environment, not a flat generic dashboard. | S8 environment composition exists; visual reference requires a richer staged environment. | PARTIAL | Complete environment composition and visual hierarchy. | P0 |
| UI-02 | UI/UX | Central intelligence core | Home should visibly communicate a shared intelligence core connecting the four rooms. | Environment architecture includes a shared central intelligence/environment concept; full functional linkage not evidenced. | PARTIAL | Make core activity reflect authoritative S8 activity rather than static decoration. | P1 |
| UI-03 | UI/UX | Room cards | Each room needs identity, role, state/status, character presence and entry interaction. | Reference specification establishes these elements; implementation completeness not evidenced. | PARTIAL | Finish four room cards and acceptance tests. | P0 |
| UI-04 | UI/UX | Medrus room | Evidence & Memory presentation must support evidence collection, comparison, memory and experimental/evidence activity. | Room identity exists conceptually and in environment entities. | PARTIAL | Audit actual Medrus interactions and evidence surfaces. | P0 |
| UI-05 | UI/UX | Epistre room | Provenance & Explanation presentation must expose lineage and human-readable explanation. | Room identity exists conceptually; complete functional surface not evidenced. | PARTIAL | Implement provenance tree/explanation inspection flow. | P0 |
| UI-06 | UI/UX | Veridat room | Verification & Truth presentation must expose verification activity, contradictions and integrity-related information. | Room identity exists conceptually; full functional surface not evidenced. | PARTIAL | Implement verification views and contradiction/integrity states. | P0 |
| UI-07 | UI/UX | Presentation room | Flow & Collaboration must provide human-facing coordination, intervention and decision flow. | Presentation is represented in the hub concept. | PARTIAL | Implement functional collaboration/intervention surface. | P0 |
| UI-08 | UI/UX | Recent Activity | Home should expose recent meaningful system activity. | Reference requires activity list; no complete authoritative event feed is evidenced. | OPEN | Build event-backed Recent Activity projection. | P1 |
| UI-09 | UI/UX | Key Insights | Home should expose unresolved uncertainties, conflicts, pending human decisions and improvement paths. | Reference specifies these categories; implementation is not evidenced as authoritative. | OPEN | Build insight aggregation from S8 state/artifacts. | P1 |
| UI-10 | UI/UX | System State | Processing/state display must be truthful and state-driven. | Animation exists, but the screen entry point/state wiring remains incomplete. | OPEN | Connect system state UI to real S8 state. | P0 |
| UI-11 | UI/UX | Information Flow | Evidence → Analysis → Verification → Explanation → Action should be inspectable as an information flow. | Reference specifies the flow; implementation completeness not evidenced. | OPEN | Build functional flow nodes linked to artifacts/events. | P1 |
| UI-12 | UI/UX | Quick Access | Debate Arena, Submit Evidence/Context and Propose Alternative need real interaction paths. | Reference specifies these actions; full functional implementation not evidenced. | OPEN | Implement actions and route them through application services. | P0 |
| UI-13 | UI/UX | How to Interact | Inspect, Trace, Question, Challenge, Provide Context, Authorize, Explore and Decide must map to actual actions. | Reference defines the vocabulary; implementation completeness not evidenced. | OPEN | Create action registry and acceptance tests for each interaction. | P0 |
| UI-14 | UI/UX | Character profile | Tapping a character should open a persistent profile card that can be grabbed/dragged and travel with the character context. | Draggable profile-card component was added, but character tap mounting was not yet evidenced. | PARTIAL | Wire all character taps to the card and preserve position/context. | P0 |
| UI-15 | UI/UX | Character visual completeness | Character presentation must preserve canonical identity, clothing, accessories, tools and state representations. | Character profile/card infrastructure exists; full visual completeness not evidenced. | OPEN | Audit character specifications against rendered Flutter characters. | P1 |
| UI-16 | UI/UX | Animation semantics | Semantic animations must represent actual activity; ambient animation must remain decorative. | Ambient motion component exists. | PARTIAL | Separate semantic vs ambient animation APIs and test state grounding. | P0 |
| UI-17 | UI/UX | Environment scenery | Shared/world scenery must be used appropriately: sky, mountain, skyline, bridge and night-sky vocabulary should not be blindly duplicated across every room. | Existing environment entities contain these concepts; visual assignment needs audit. | OPEN | Re-map scenery by environment layer and room identity. | P1 |
| UI-18 | UI/UX | No fifth room | Shared environment/home-cluster vocabulary must not accidentally become a fifth S8 room. | Architecture is four-room; environment vocabulary includes shared concepts. | PARTIAL | Treat shared environment as ambient/world layer only. | P1 |
| UI-19 | UI/UX | Responsive spatial hierarchy | Panels, room cards, central stage and activity surfaces must remain usable across target Flutter sizes. | Not evidenced. | OPEN | Add responsive layout tests and representative device-size checks. | P1 |

| ID | Ledger source | Compliance area | Required implementation outcome | Current evidence/state | Status | Backlog action | Priority |
|---|---|---|---|---|---|---|---|
| TECH-01 | Technology | Flutter presentation | S8 presentation must remain Flutter-native within the agreed stack. | Flutter presentation package exists. | DONE/PARTIAL | Verify no prohibited external visual runtime dependency has entered S8. | P0 |
| TECH-02 | Technology | Python boundary | Python-backed intelligence/computation must have a clear service/interface boundary from Flutter. | Technology ledger specifies Flutter + Python; full boundary evidence not yet available. | OPEN | Audit service contracts and integration tests. | P0 |
| TECH-03 | Technology | IndexedDB | IndexedDB must support the agreed web persistence role. | `idb_shim` is present in presentation dependencies. | PARTIAL | Verify actual persistence paths, schema and recovery behavior. | P0 |
| TECH-04 | Technology | Local SQLite | Local SQLite must support the agreed local persistence role where specified. | Technology ledger requires IndexedDB + local SQLite; complete SQLite implementation not evidenced. | OPEN | Audit/create SQLite repository layer and migration tests. | P0 |
| TECH-05 | Technology | Artifact persistence | Artifacts must survive application lifecycle according to the ledger. | Persistence architecture is specified but compliance not evidenced. | OPEN | Implement/reconcile artifact repositories and lifecycle tests. | P0 |
| TECH-06 | Technology | Temporal infrastructure | Event/artifact history must preserve temporal ordering and relevant timestamps. | Temporal infrastructure is a ledger requirement; implementation not evidenced. | OPEN | Implement timestamp/event ordering contract. | P1 |
| TECH-07 | Technology | Local NLP/LLM boundary | Any NLP/LLM use must be explicit, bounded and justified by capability requirements. | Ledger requires a local NLP/LLM boundary; no complete implementation evidence. | OPEN | Document current model/procedure for each capability; keep character separate from model. | P0 |
| TECH-08 | Technology | Verification | Verification mechanisms must produce inspectable outputs/artifacts. | Veridat is defined for verification; full mechanism evidence not available. | OPEN | Implement verification service contracts and result artifacts. | P0 |
| TECH-09 | Technology | Contradiction handling | Conflicting evidence/outputs must be represented rather than silently collapsed. | UI reference includes conflicting evidence; implementation not evidenced. | OPEN | Implement contradiction objects/state and inspection flow. | P0 |
| TECH-10 | Technology | Memory | Evidence/knowledge memory must use the agreed persistence and retrieval architecture. | Ledger specifies memory; complete implementation not evidenced. | OPEN | Audit memory schema, retrieval, retention and provenance links. | P0 |
| TECH-11 | Technology | Authorization | Human approvals/interventions must be authorized and auditable. | Authorization is explicitly listed in the technology ledger. | OPEN | Implement authorization service/events and tests. | P0 |
| TECH-12 | Technology | Cryptographic integrity | Provenance/integrity mechanisms must make tampering detectable where required. | Cryptographic integrity is a ledger requirement; implementation not evidenced. | OPEN | Implement integrity receipts/checks and tamper tests. | P0 |
| TECH-13 | Technology | Testing | Unit, widget, integration and relevant acceptance tests must cover ledger requirements. | Some Flutter test infrastructure exists from earlier work; complete S8 compliance suite not evidenced. | OPEN | Create a ledger-ID-tagged acceptance test suite. | P0 |
| TECH-14 | Technology | Instrumentation | Meaningful S8 activity should be observable for debugging/research evaluation. | Instrumentation is a ledger requirement; implementation not evidenced. | OPEN | Add event/telemetry hooks without making telemetry the source of truth. | P1 |
| TECH-15 | Technology | Deployment | S8 standalone/runtime deployment must follow the ledger's dependency and packaging constraints. | Not fully evidenced. | OPEN | Produce deployment checklist and clean-room build test. | P1 |
| TECH-16 | Technology | S7 integration | S8 must consume S7 through an explicit integration boundary without making S7's internal presentation layer the hidden dependency. | S7 is a preceding specialized bureau and integration is part of the technology ledger. | OPEN | Define S7→S8 artifact/event adapter and integration contract. | P0 |

---

# 3. Immediate implementation backlog

The matrix becomes the backlog in this order. `P0` items are acceptance-critical; `P1` items are important but should follow the functional spine.

## EPIC A — Authoritative S8 foundation

- [ ] **ARC-01** Establish and document S8 inbound/outbound boundary.
- [ ] **ARC-03** Audit character-to-computation separation.
- [ ] **ARC-04** Implement authoritative state → presentation state mapping.
- [ ] **ARC-05** Finalize canonical S8 artifact contracts.
- [ ] **ARC-06** Implement artifact provenance.
- [ ] **ARC-07** Implement explanation artifact contract.
- [ ] **ARC-08** Implement human intervention events and authorization boundary.
- [ ] **ARC-09** Implement uncertainty, limitation and contradiction state model.
- [ ] **ARC-10** Complete integrity/authorization audit.

## EPIC B — Four-room functional spine

- [ ] **ARC-02** Verify four-room architecture.
- [ ] **UI-03** Complete four room cards and navigation.
- [ ] **UI-04** Complete Medrus evidence/memory surface.
- [ ] **UI-05** Complete Epistre provenance/explanation surface.
- [ ] **UI-06** Complete Veridat verification/truth surface.
- [ ] **UI-07** Complete Presentation flow/collaboration/intervention surface.

## EPIC C — Human-facing XAI

- [ ] **UI-08** Event-backed Recent Activity.
- [ ] **UI-09** Authoritative Key Insights.
- [ ] **UI-10** Truthful System State.
- [ ] **UI-11** Functional Information Flow.
- [ ] **UI-12** Debate Arena / Submit Evidence / Propose Alternative.
- [ ] **UI-13** Inspect / Trace / Question / Challenge / Context / Authorize / Explore / Decide.

## EPIC D — Character and environment presentation

- [ ] **UI-14** Mount draggable profile card from every character interaction.
- [ ] **UI-15** Audit canonical character appearance/accessories/state representation.
- [ ] **UI-16** Separate semantic and ambient animation.
- [ ] **UI-17** Correct shared scenery vocabulary by layer/room.
- [ ] **UI-18** Ensure no accidental fifth room.
- [ ] **UI-01** Finish cinematic environment composition.
- [ ] **UI-02** Make central intelligence core state-aware.
- [ ] **UI-19** Responsive spatial hierarchy.

## EPIC E — Persistence and intelligence services

- [ ] **TECH-02** Python service boundary.
- [ ] **TECH-03** IndexedDB compliance.
- [ ] **TECH-04** SQLite compliance.
- [ ] **TECH-05** Artifact persistence.
- [ ] **TECH-06** Temporal infrastructure.
- [ ] **TECH-07** Capability → model/procedure mapping.
- [ ] **TECH-08** Verification.
- [ ] **TECH-09** Contradiction handling.
- [ ] **TECH-10** Memory.
- [ ] **TECH-11** Authorization.
- [ ] **TECH-12** Cryptographic integrity.

## EPIC F — Verification and research evidence

- [ ] **TECH-13** Ledger-tagged test suite.
- [ ] **TECH-14** Instrumentation.
- [ ] **TECH-15** Standalone deployment validation.
- [ ] **TECH-16** S7 integration adapter/contract.

---

# 4. Definition of done

A row is **not DONE because the widget exists**.

A compliance item reaches `DONE` only when all applicable conditions are true:

1. **Implementation exists.**
2. **It is connected to the authoritative S8 architecture.**
3. **Its behavior matches the relevant ledger requirement.**
4. **The behavior is testable.**
5. **The test passes.**
6. **The implementation does not introduce an architectural exception.**
7. **The relevant evidence is recorded against this matrix.**

For visual items, add:

8. The visual behavior is demonstrable in the intended Flutter environment.
9. Any semantic animation is grounded in actual S8 state/event/artifact data.
10. Ambient animation cannot be mistaken for computational truth.

---

# 5. Compliance evidence register

Each completed item should eventually have evidence of the form:

| Matrix ID | Evidence required |
|---|---|
| `ARC-*` | Source/module + architecture test + integration evidence |
| `UI-*` | Widget/source + interaction test + visual demonstration |
| `TECH-*` | Service/repository/module + unit/integration test + persistence/security evidence |

Recommended implementation annotation:

```text
// S8-COMPLIANCE: UI-14
// Requirement: Character profile card is persistent, draggable and character-context aware.
// Evidence: <test/file/reference>
```

Do not use these comments as a substitute for tests.

---

# 6. Current S8 state summary

### Already evidenced in the current implementation work

- S8 branch exists: `s8-xai-evidence-bureau`.
- Flutter presentation layer contains S8 environment work.
- `flutter_animate` was added for bundled, asset-free animation.
- An ambient motion layer was added.
- An animated S8 environment wrapper was added.
- A draggable character profile card was added.

### Known integration gaps from the current implementation work

- The existing screen entry point had not yet been switched to the animated S8 environment.
- Character tap handlers had not yet been wired to mount the draggable profile card.
- Full authoritative state/event/artifact wiring has not yet been demonstrated.
- The three-ledger technology requirements are substantially broader than the current visual implementation.

Therefore the S8 sprint is **not ledger-complete** merely because the cinematic layer or animation exists.

---

# 7. Backlog operating rule

From this point forward:

> **Every S8 implementation task must reference one or more matrix IDs.**

No new S8 feature should be accepted merely because it looks useful.

Before implementation:

```text
Feature
  ↓
Ledger requirement
  ↓
Matrix ID
  ↓
Implementation
  ↓
Test
  ↓
Evidence
  ↓
Compliance status
```

If a requested feature cannot be mapped to the ledgers, classify it as:

- `NEW REQUIREMENT — DISCUSSION REQUIRED`

Do **not** silently add it to implementation.

If implementation conflicts with a locked ledger decision, stop the implementation change and record:

- `LEDGER CONFLICT — ARCHITECTURE REVIEW REQUIRED`

---

# 8. Sprint completion gate

S8 should not be marked complete until:

- all `P0` items are `DONE`;
- every `P1` item is either `DONE` or explicitly documented as deferred;
- no ledger requirement is left without a status;
- all `OPEN` items have either implementation evidence or an explicit documented reason for deferral;
- the four-room flow works end-to-end;
- at least one complete evidence → provenance → verification → explanation → human intervention flow is demonstrable;
- character presentation is demonstrably downstream of system state;
- persistence and integrity behavior pass their relevant tests;
- S7 integration is verified at the declared boundary;
- the final compliance matrix is updated from `backlog` to `release evidence`.

---

## Final control statement

**The three S8 ledgers remain the source of truth.  
This matrix is the execution/control layer.  
The implementation backlog is the matrix's OPEN/PARTIAL work.  
Tests and evidence are required to move items to DONE.**
