# CRITERIVOX — Frontend Implementation Reconciliation

**Set:** 1 of 6  
**Audit date:** 2026-09-18  
**Branch:** `frontend-completion`  
**Starting baseline:** `4fb4cd816c49ddd7f4d5e4a0259e42ec707f607b`  
**Audit mode:** repository archaeology + documentation/implementation reconciliation  
**Scope:** existing Flutter/Dart presentation, Python/domain/application support, assets, tests, UX/world architecture, S5–S8 boundaries

> This document records implementation truth discovered during Set 1. It deliberately distinguishes documented intent from code that exists and from capabilities that are only planned, simulated, static, or partially wired.

---

## A. Audit State

The six-set working branch `frontend-completion` was created from the current `main` baseline. No feature branch was created for Set 1.

The repository baseline is substantial and must not be treated as greenfield. It already contains:

- a Flutter presentation application under `presentation/`;
- a Python application/domain layer under `src/criterivox/`;
- S5 data-foundation/stewardship implementation;
- S6 context-intelligence implementation and remaining verification backlog;
- an independently callable S7 reasoning package/presentation surface;
- an independently runnable S8 evidence/XAI package/presentation surface;
- character identity/state/animation infrastructure;
- Bloom/Syvax/Home surfaces;
- browser-local persistence and WebSocket/runtime adapters;
- extensive Python and Flutter tests;
- CI workflows for S6, S7 and S8;
- canonical visual-asset directory preparation.

---

## B. Documentation Inventory

### UX / presentation architecture read

- `docs/ux/s1-information-architecture.md`
- `docs/ux/GATE1-GATE2-CIVILIZATION-UX-ARCHITECTURE.md`
- `docs/ux/CRITERIVOX-LEVEL1-WORLD-MAP-BLUEPRINT.md`
- `docs/ux/CRITERIVOX-WORLD-MAP-LEVEL2-PART1.md`
- `docs/ux/CRITERIVOX-WORLD-MAP-LEVEL2-PART2.md`
- `docs/ux/CRITERIVOX-WORLD-MAP-LEVEL2-PART3.md`
- `docs/ux/CRITERIVOX-WORLD-MAP-LEVEL2-PART4.md`
- `docs/ux/CRITERIVOX-WORLD-MAP-LEVEL2-PART5.md`
- `docs/ux/CRITERIVOX-VISUAL-APPEARANCE-ARCHITECTURE.md`
- `docs/ux/VISUAL-ASSET-STRUCTURE.md`
- `docs/ux/CRITERIVOX-CHARACTER-APPEARANCE-ASSET-SYSTEM.md`
- `docs/ux/CRITERIVOX-FRONTEND-PRESENTATION-ARCHITECTURE.md` where present/discovered through the repository UX architecture
- `docs/architecture/TWO-GATE-HUMAN-RESIDENCE-UX-v1.0.md`
- `docs/architecture/COLLABORATION-ROOM-v1.0.md`

### Sprint / implementation / closure material read or used for reconciliation

- `README.md`
- `docs/sprints/S4-CLOSURE-2026-09-08.md`
- `docs/sprints/S4-END-OF-DAY-2026-09-08.md`
- `docs/sprints/S5-BACKLOG.md`
- `docs/sprints/S6-BACKLOG.md`
- `docs/sprints/S6-CLOSURE-2026-09-12.md`
- `docs/implementation/S6-ACTION-PLAN.md`
- `docs/architecture/S6-SOLID-MODULAR-BOUNDARIES.md`
- `docs/architecture/CRITERIVOX-CIVILIZATION-HUMAN-RESIDENCE-S6.md`
- `docs/architecture/S6-KAELEN-FIRST-CLASS-RESPONSIBILITY.md`
- `docs/adr/ADR-009-s6-context-human-civilization-boundary.md`
- `docs/s7/REASONING_RESEARCH_BUREAU_COMPLETION_ROADMAP.md`
- `docs/sprints/s7/S7-ARCHITECTURE-GAP-ASSESSMENT.md`
- `docs/sprints/S8-IMPLEMENTATION-STATUS.md`
- `docs/sprints/S8-CLOSURE-STATUS.md`
- `docs/s8/CRITERIVOX_S8_Ledger_Compliance_Matrix.md`
- relevant S2/S3/S4 sprint and ADR material used to trace presentation evolution
- relevant character asset/behavior documentation
- relevant research documentation referenced by S5/S6/S7/S8

### Engineering / test evidence inspected

- `presentation/pubspec.yaml`
- `presentation/lib/main.dart`
- `presentation/lib/app_shell.dart`
- `presentation/lib/bloom_page.dart`
- `presentation/lib/world_portal_page.dart`
- `presentation/lib/interaction/bloom.dart`
- `presentation/lib/interaction/syvax.dart`
- `presentation/lib/interaction/home03_bloom.dart`
- `presentation/lib/character/character_identity.dart`
- `presentation/lib/character/session_character_animation.dart`
- S7 presentation modules under `presentation/lib/s7/`
- S8 presentation modules under `presentation/lib/`
- `src/criterivox/app.py`
- `src/criterivox/domain/characters/definitions.py`
- `src/criterivox/application/bloom.py`
- `src/criterivox/application/syvax.py`
- `pyproject.toml`
- relevant Flutter tests under `presentation/test/`
- relevant Python tests under `tests/` and S7 test package
- GitHub Actions workflows for Flutter/S6/S7/S8 validation

---

## C. Existing Frontend Architecture — Implementation Truth

### Main Flutter application

The principal Flutter application is under `presentation/`.

`presentation/lib/main.dart` boots `CriterivoxApp`, while `app_shell.dart` provides the current application shell.

The shell currently owns presentation navigation state using page identifiers and contains explicit surfaces for:

- introduction;
- Bloom;
- analysis/context workspace;
- character chat;
- Sandre stewardship;
- Home 02 context console.

The shell also owns runtime subscriptions for:

- presentation states;
- runtime errors;
- context events.

This is an existing reusable presentation shell, not a placeholder.

### Current navigation truth

The current implementation still reflects the earlier S1/S2/S3/S4 navigation model. It has a sidebar/top bar and direct workspace/chat/stewardship/Bloom access.

This is **not yet equivalent to the newer locked three-top-level-option Gate 1/Gate 2 presentation architecture**.

Therefore:

**Status: PARTIAL / EVOLVING**

Do not discard the shell. Sets 2–6 should reconcile it into the newer presentation architecture rather than rebuild the application from zero.

### Bloom

Bloom is already implemented as a functional presentation surface and has tests. It exposes capability selection and integrates with Syvax/runtime actions.

Python also contains a `BloomController` with Home mappings.

The current Bloom implementation is therefore reusable.

The newer UX contract explicitly defines Bloom as a presentation/read-model visualization hub and not an agent/orchestration authority. The existing implementation must be checked against that boundary as later sets integrate it.

**Status: FUNCTIONALLY IMPLEMENTED / PARTIAL AGAINST NEW UX**

### Syvax

Syvax has an actual Flutter interaction widget and a Python application service.

The Python implementation contains intent extraction and task-plan compilation with routes involving Dharen, Tarkis, Medrus, Vivren, Pramon, Manis and Syvax.

This means the repository already has a meaningful routing/task-planning capability.

However, newer S7/S8 architecture explicitly requires specialized bureaus to remain independently callable and not depend on Syvax as a monolithic computational center.

**Status: LIVE / FUNCTIONALLY IMPLEMENTED, WITH ARCHITECTURAL BOUNDARY CONSTRAINT**

### Character chat

A dedicated character-chat page already exists and is wired into the shell. The shell tracks a selected character and sends messages through the runtime client.

This is valuable existing work and must be retained.

The chat surface should remain distinct from the newer Gate 1 spatial civilization presentation rather than being mistaken for the complete civilization UX.

**Status: FUNCTIONALLY IMPLEMENTED**

---

## D. Gate 1 Coverage

| Requirement | Current implementation | Status |
|---|---|---|
| Introduction | `AppIntroductionPage` and shell route | FUNCTIONALLY IMPLEMENTED |
| Civilization entry | Bloom/world portal and character surfaces exist | PARTIAL |
| Living household map | Home mapping and world portal concepts exist | PARTIAL |
| Character roster | Character registry/identity exists | FUNCTIONALLY IMPLEMENTED |
| Character briefing | Identity/role/state presentation exists | PARTIAL |
| Homes | Home 01–08 concepts and several concrete pages exist | PARTIAL |
| Relationships | Character handoffs and home relationships exist in domain/docs | PARTIAL |
| Live observability | Runtime presentation state exists | PARTIAL |
| Cross-home sandbox | S6 sandbox and routing concepts exist | PARTIAL |
| Bloom | Implemented | FUNCTIONALLY IMPLEMENTED |
| Character chat | Implemented | FUNCTIONALLY IMPLEMENTED |
| Reasoning inspection | S7 surfaces exist independently | PARTIAL integration |
| Evidence/XAI inspection | S8 surfaces exist independently | PARTIAL integration |

The key gap is not absence of all functionality. It is **integration and presentation reconciliation** between mature sprint-specific surfaces and the newer civilization/Gate architecture.

---

## E. Gate 2 Coverage

| Requirement | Current implementation | Status |
|---|---|---|
| Human Residence | Existing Human Residence architecture/documentation and UI work exist | PARTIAL |
| Private Room | Human decision/context concepts exist | PARTIAL |
| Collaboration Room | `presentation/lib/collaboration_room_page.dart` exists and is wired | FUNCTIONALLY IMPLEMENTED / BOUNDED |
| Owner / Resident / Guest concepts | Documented and partially represented | PARTIAL |
| Goal / Data / Context | Existing analysis and context workspaces | FUNCTIONALLY IMPLEMENTED / PARTIAL |
| Human challenge | Existing intervention concepts; S7/S8 challenge artifacts mature | PARTIAL |
| Action recording | Architecture exists; full end-to-end Gate 2 loop not proven | MISSING/PARTIAL |
| Real-world result | Results Journal architecture documented; complete runtime loop not proven | MISSING |
| Guest Pass | Documented architecture; full production flow not proven | PLANNED/PARTIAL |
| Shared decision canvas | Collaboration page exists; full authorization-grade semantics not claimed | PARTIAL |

The existing collaboration room documentation explicitly states that server-side authorization, cryptographic signatures and real Bodhex execution are not falsely represented as complete by the UI.

---

## F. Level 1 World Map Coverage

The Level 1 blueprint defines an **Architectural World** with stable Home anchors and character placement.

Current implementation contains:

- `world_portal_page.dart`;
- `home03_bloom.dart`;
- concrete Home 01 stewardship UI;
- concrete Home 02 context UI;
- Home 03/Syvax interaction;
- Home 04/S7 reasoning surfaces;
- Home 05 planning concepts;
- Home 06 evidence/XAI surfaces;
- Home 07 human challenge concepts;
- Home 08 knowledge concepts.

Python `BloomController` currently maps:

- Home 01 → Sandre / Data Foundation
- Home 02 → Dharen / Context
- Home 03 → Syvax / Gateway
- Home 04 → Vivren + Tarkis / Intelligence
- Home 05 → Pramon + Bodhex / Planning
- Home 06 → Medrus + Epistre + Veridat / Evidence
- Home 07 → Manis / Human Challenge
- Home 08 → Viveda / Knowledge

This is valuable implementation evidence.

### Reconciliation issue

The newer S7 roadmap explicitly says there is **no S7 Home/Intelligence Home room** and defines exactly three S7 user-facing spaces:

1. Collaboration Room
2. Critical Intelligence Chamber
3. Hypothesis Exploration Chamber

Therefore, **Home 04 remains the civilization/world spatial anchor, but the internal S7 workspaces must not be conflated with a fourth/fifth S7 room**.

**Status: DOCUMENTED EVOLUTION / REQUIRES CAREFUL PRESENTATION RECONCILIATION**

---

## G. Level 2 Coverage

### Part I

Level 2 Part I is an extension of Level 1 rather than a replacement. It establishes deeper Home/room/capability semantics.

Existing Home-specific presentation and domain work provides partial coverage.

**Status: PARTIAL**

### Part II

Part II was explicitly superseded in repository history by a revised naming direction for Level 1 Home naming. The current repository should treat the later document as authoritative for current public-facing naming while preserving the historical specification for traceability.

**Status: OUTDATED/SUPERSEDED WHERE CONFLICTING**

### Part III

Part III extends knowledge/reuse and includes interactions such as Manis stress-testing generalized knowledge and Viveda refining/limiting abstractions when evidence warrants it.

Current character/domain definitions provide role and handoff foundations, but complete spatial interaction coverage is not established.

**Status: PARTIAL**

### Part IV

Part IV provides further world/household/capability architecture. Existing home and character infrastructure can support it, but complete implementation coverage is not proven merely by the existence of Home widgets.

**Status: PARTIAL**

### Part V

Part V establishes later Evidence & Experiment Quarter / human authority / collaboration-oriented world semantics. S8 and collaboration-room implementation provide significant reusable pieces, but full integrated Level 2 experience is not complete.

**Status: PARTIAL**

### Critical Level 2 rule

A Level 2 document describes a requirement/candidate unless the corresponding backend contract, runtime behavior, UI behavior and tests exist. This distinction is already present in the repository and must be preserved.

---

## H. Character Coverage — 15 Canonical Characters

The repository has a Python character registry and a Flutter `CharacterIdentity` registry. The current implementation contains explicit character definitions, behavior, triggers, communication and handoff concepts.

| Character | Current implementation truth | Home | Frontend state |
|---|---|---|---|
| Dharen | Context architecture/master; runtime and Home 02 surfaces | Home 02 | LIVE/PARTIAL |
| Vivren | Discernment / critical reasoning representation; S7 surfaces | Home 04 | LIVE/PARTIAL |
| Tarkis | Hypothesis/exploration representation; S7 surfaces | Home 04 | LIVE/PARTIAL |
| Sandre | Data stewardship; Home 01 UI | Home 01 | LIVE/PARTIAL |
| Pramon | Planning/decision role | Home 05 | PARTIAL |
| Syvax | Dialogue/gateway/interaction boundary | Home 03 | LIVE |
| Bodhex | Planning support / execution concepts | Home 05 | PARTIAL |
| Medrus | Evidence specialist / experimenter / verifier | Home 06 | LIVE/PARTIAL through S8 |
| Epistre | Knowledge/provenance/explanation support | Home 06 | LIVE/PARTIAL through S8 |
| Manis | Human challenge | Home 07 | PARTIAL |
| Anuka | Context adaptation | Home 02 | LIVE/PARTIAL |
| Veridat | Verification | Home 06 | LIVE/PARTIAL through S8 |
| Viveda | Knowledge support | Home 08 | PARTIAL |
| Kaelen | Build/experimentation in S5/S6 workflow; temporal/environmental context also exists in character definition material | Home 01 / role semantics require reconciliation | PARTIAL |
| Anukor | Adaptive transfer / roaming network resident | Cross-home | PARTIAL |

### Character-home society mapping

The established derived residence model is:

- Sandre + Kaelen → Data Foundation
- Dharen + Anuka → Context
- Syvax → Gateway
- Vivren + Tarkis → Intelligence/Reasoning
- Pramon + Bodhex → Planning/Decision
- Medrus + Epistre + Veridat → Evidence/Experimentation/Verification
- Manis → Human Challenge
- Viveda → Knowledge
- Anukor → cross-home roaming

These assignments are documented as derived design decisions rather than original immutable canon. Future implementation must not silently turn a derived design decision into computational authority.

### Character appearance

The visual architecture explicitly defers final character specifications until source materials are supplied. Therefore Set 1 must **not invent final artwork/specifications**.

---

## I. Visual Architecture Coverage

The locked visual architecture selects:

- Cinematic Intelligence Interface;
- Architectural World;
- PNG/SVG-first asset workflow;
- Flutter-native procedural animation;
- layered scene composition;
- responsive browser-first design;
- scenario-based appearance validation.

The repository already has:

- `CriterivoxTheme`;
- Flutter animation packages;
- character presentation/state infrastructure;
- local Web 2D skeletal runtime concepts;
- S8 Flutter-native ambient/environment motion;
- character identity/state adapters;
- responsive presentation tests.

### Layer architecture

The target reusable composition is:

```
Scene
 ├── Environment
 ├── Character
 ├── Lighting
 ├── Information
 ├── Artifact
 ├── Interaction
 └── Transition
```

Current implementation supports several pieces, but a fully standardized scene-layer architecture across the entire civilization is not yet established.

**Status: PARTIAL**

---

## J. Live / Simulated / Planned Classification

### LIVE / FUNCTIONALLY IMPLEMENTED

- Flutter application shell
- Bloom interaction
- Syvax interaction surface
- character chat
- S5 stewardship surfaces
- S6 context surfaces
- browser-local persistence concepts
- WebSocket runtime transport
- character identity/state infrastructure
- S7 Python package and standalone presentation surface
- S8 Python package and standalone presentation surface
- S8 artifact/event/provenance persistence contracts
- collaboration room UI

### SIMULATED / DEMONSTRATION / FIXTURE-BASED

- S8 Fixtures Lab
- synthetic research fixtures
- visual/demo states where no authoritative runtime event exists
- any Bloom/world visual telemetry without a corresponding runtime source

### STATIC PRESENTATION / PARTIAL

- several Home/World surfaces whose complete computational integration is not proven
- portions of Level 2 spatial interaction
- some character activity visualization
- parts of Gate 2 result/real-world outcome loop

### PLANNED / DEFERRED

- full unified Gate 1 civilization experience
- complete three-option top navigation reconciliation
- complete Gate 2 decision lifecycle
- final character artwork population
- complete scene-layer visual system
- Global Intelligence Home
- full cross-sprint S7/S8 integration into the main application
- remaining S6 verification gates

### BROKEN / BLOCKED

- repository baseline contains a known unresolved Git conflict in `src/criterivox/ui/routes.py`, recorded by the existing S7 gap assessment;
- final character visual assets are blocked on supplied source material;
- local execution was not possible in this audit environment because network/DNS prevented cloning the repository locally.

---

## K. Flutter / Dart / Python Boundaries

### Existing boundary

Flutter is the presentation/runtime-client side.

Python owns domain/application intelligence and runtime services.

The repository uses:

- HTTP where appropriate;
- WebSocket transport;
- IndexedDB browser persistence;
- SQLite/local persistence in S8;
- typed presentation state;
- Python application/domain services.

The S6 architecture explicitly keeps Flutter, WebSocket transport, IndexedDB and concrete ML libraries as infrastructure/adapters rather than domain authorities.

### S7 boundary

The S7 architecture assessment states that S7's new API imports only S7 modules and presentation calls the S7 boundary rather than routing S7 computation through Syvax.

This is a critical reuse/integration rule.

### S8 boundary

S8 is deliberately independently runnable through:

- `presentation/lib/s8_main.dart`
- `s8-start-evidence-research-bureau.ps1`

The S8 implementation does not boot the main Criterivox shell.

This independence must be preserved until an explicit integration contract is implemented.

---

## L. Asset Status

### Canonical structure

The repository contains the canonical preparation for:

```
assets/
├── characters/
├── worlds/
│   ├── criterivox_civilization/
│   └── human_residence/
├── ui/
└── animations/
```

The visual asset documentation defines semantic character assets such as:

- portrait;
- front/side/back;
- neutral/smiling/thinking/focused/surprised;
- idle/receive/work/communicate/handoff/complete;
- accessories/tools.

### Actual current Flutter declaration

`presentation/pubspec.yaml` currently declares:

```
assets/characters/
```

The wider world/UI/animation directories are architecturally documented but are not currently declared there as broad Flutter asset roots.

### Final character art

The canonical visual architecture explicitly says final character artwork is not yet populated and must not be invented prematurely.

**Status: SOURCE-REQUIRED / DEFERRED**

### Existing procedural assets

S8 contains Flutter-rendered character/environment presentation that does not rely on external character image assets. This is reusable as a procedural presentation technique, but it must not be mistaken for completion of the canonical final character artwork pipeline.

---

## M. Tests

### Flutter

Relevant tests include:

- `presentation/test/widget_test.dart`
- `presentation/test/s3_interaction_test.dart`
- `presentation/test/presentation_state_test.dart`
- `presentation/test/responsive_presentation_test.dart`
- S7 local NLP tests
- S8 presentation tests
- character/presentation tests

Existing test history shows the Flutter suite has had failures in earlier recorded runs. The checked-in `presentation/test.txt` contains an old recorded run with failures, so it must not be treated as current execution evidence.

### Python

The repository contains:

- domain character tests;
- runtime/app tests;
- S6 tests;
- S7 tests;
- S8 tests;
- research fixture tests.

CI workflows explicitly run Python compilation/tests and separate Flutter analysis/tests.

### Current Set 1 execution limitation

A local clone could not be established from this audit environment because DNS/network access to GitHub was unavailable. Therefore Set 1 does **not** claim that `flutter analyze`, `flutter test`, `pytest`, or a local application build was freshly executed here.

Existing repository CI/workflow definitions and recorded test artifacts were inspected instead.

This distinction is intentional.

---

## N. Duplication / Miswiring

### Identified duplication or overlapping concepts

1. Earlier S1 navigation model versus newer Gate 1/Gate 2 three-option navigation.
2. World/Home portal concepts versus newer civilization spatial roster.
3. S7 standalone presentation versus older Home 04 generic/intelligence surfaces.
4. S8 standalone four-room bureau versus generic application/Home surfaces.
5. Character identity definitions appear in both Flutter and Python. This is acceptable only if one is the authoritative domain definition and the Flutter representation is a projection/adapter.
6. Character behavior/state vocabulary appears across domain and presentation. Presentation must remain a projection of authoritative semantic state.
7. Syvax routing contains explicit character route steps while newer S7/S8 boundaries require specialized bureaus not to become Syvax-dependent.

### Do not delete yet

These overlaps require reconciliation, not mass deletion. The repository has historical sprint evolution and some concepts are intentionally retained for compatibility.

---

## O. Architecture Discrepancies

### 1. S1 navigation vs locked civilization navigation

S1 defines Home → Workspace → Settings and a workspace-area navigation model.

Newer Gate architecture defines exactly three top-level presentation destinations:

- Introduction
- Criterivox Workers / Bloom
- Human Civilians / Profile

**Classification:** intentional architectural evolution.

The older S1 model should remain historical, while the current presentation should eventually implement the newer locked model.

### 2. Home 04 / Intelligence naming vs S7 three-space model

Level 1 and civilization architecture use Home 04 as the Intelligence/Reasoning spatial anchor.

The later S7 completion roadmap explicitly prohibits an additional S7 Home/Intelligence Home room and defines exactly three S7 workspaces.

**Classification:** scope distinction, not a reason to delete Home 04.

Home 04 is the world/home anchor. S7's three workspaces are the specialized bureau presentation spaces.

### 3. S7/S8 standalone vs main-shell integration

Both S7 and S8 have deliberate standalone boundaries.

**Classification:** intentional staged architecture.

Do not collapse them into the main shell until a dedicated integration contract exists.

### 4. Character roles versus computational engines

Repository architecture correctly distinguishes characters from underlying computation.

**Classification:** preserve.

Characters are presentation manifestations of actual computational activity, not computational engines.

### 5. Documentation branch labels

Some documents record historical implementation branches such as `reasoning-research-bureau` or `s8-xai-evidence-bureau`, while the current six-set work is on `frontend-completion`.

**Classification:** historical documentation, not a reason to rewrite history.

---

## P. Critical / High / Medium / Low Gaps

### Critical

- Resolve the pre-existing `src/criterivox/ui/routes.py` merge-conflict markers before declaring the whole application runtime a clean baseline.
- Establish a single current presentation navigation contract that reconciles S1 history with the locked Gate 1/Gate 2 architecture.
- Preserve authoritative state boundaries while integrating S7/S8 surfaces.
- Do not claim live computational activity from purely visual animation.

### High

- Integrate existing Home 01/Home 02/Home 03 surfaces into the newer civilization/residence architecture.
- Integrate S7's three workspaces without inventing a fourth S7 room.
- Integrate S8's four-room bureau as a standalone subsystem/read-model surface without creating fake main-shell dependencies.
- Establish reusable scene/layer composition components.
- Complete responsive spatial composition.
- Reconcile Flutter/Python character definitions through clear projection boundaries.
- Verify Gate 2 action/result lifecycle.

### Medium

- Consolidate duplicate presentation widgets/models where authoritative ownership is established.
- Expand scenario-based appearance validation.
- Expand Level 2 room interaction coverage.
- Improve asset manifest/declaration coverage.
- Add accessibility validation across cinematic/spatial surfaces.

### Low

- Cosmetic refinements after functional state grounding.
- Historical naming cleanup where no active contract is affected.
- Additional ambient motion after semantic state coverage is reliable.

### Deferred

- final character artwork;
- Global Intelligence Home;
- speculative online/LLM dependencies;
- wholesale replacement of existing sprint-specific surfaces.

---

## Q. Reuse Plan for Sets 2–6

### Reuse unchanged where possible

- Flutter theme;
- existing application shell primitives;
- Bloom interaction model;
- Syvax dialogue surface;
- character identity registry;
- character state vocabulary;
- runtime client;
- WebSocket transport;
- IndexedDB persistence;
- existing Home 01 stewardship surface;
- existing Home 02 context console;
- collaboration room;
- S7/S8 standalone entrypoints;
- S7/S8 artifact/event/presentation contracts;
- existing tests and fixtures.

### Extend

- Bloom into the civilization spatial/read-model surface;
- character presentation into state-grounded room composition;
- shell navigation into the three top-level destinations;
- Home 01–08 presentation into Level 1/Level 2 world navigation;
- S7/S8 presentation adapters into inspectable artifact surfaces;
- responsive presentation infrastructure.

### Refactor safely

- duplicate navigation declarations;
- duplicated character presentation metadata where a domain-authoritative projection can replace repeated definitions;
- repeated scene/panel/character state UI where genuine repetition exists.

### Replace only with proof

No Set 1 replacement is justified by archaeology alone.

---

## R. Set 2 Prerequisites

Before substantial Set 2 construction:

1. Treat `frontend-completion` as the only six-set working branch.
2. Keep `4fb4cd816c49ddd7f4d5e4a0259e42ec707f607b` as the audited baseline.
3. Resolve or explicitly isolate the pre-existing `routes.py` conflict before full runtime acceptance.
4. Establish the current three-option top-level navigation contract.
5. Preserve Bloom as a capability-discovery/world surface, not an intelligence authority.
6. Preserve Syvax as interaction/gateway presentation boundary, not a monolithic S7/S8 dependency.
7. Keep S7 and S8 independent until integration contracts are defined.
8. Build on existing Home 01/Home 02/Home 03 implementations.
9. Do not invent final character artwork until supplied source material is available.
10. Make authoritative runtime state the source for semantic animation and activity indicators.
11. Use Level 1 and all later Level 2 documents as current UX requirements, while preserving superseded documents historically.
12. Add/verify regression coverage before moving substantial existing navigation.

---

## S. Set 1 Change Log

### Created

- `docs/ux/CRITERIVOX-FRONTEND-IMPLEMENTATION-RECONCILIATION.md`

### Modified

No existing implementation or unrelated architecture document was intentionally modified during archaeology.

### Removed

None.

### Replaced

None.

### Deferred

All substantial frontend construction for Sets 2–6.

---

## T. Final Set 1 Assessment

Criterivox is **not missing a frontend from scratch**.

It already contains a functioning and historically layered Flutter presentation system plus substantial Python/domain/runtime support. The main problem is **reconciliation and integration**, not absence of all building blocks.

The most valuable existing pieces are:

- Bloom;
- Syvax;
- character presentation/state infrastructure;
- Home 01 stewardship;
- Home 02 context intelligence;
- collaboration room;
- browser-local state and runtime transport;
- S7 reasoning bureau;
- S8 evidence/XAI bureau;
- character/domain registries;
- existing test infrastructure;
- canonical visual architecture and asset structure.

The next phase should therefore **compose and reconcile**, not rebuild.

Set 1 deliberately does not claim full frontend readiness. It establishes the implementation map and the constraints that Sets 2–6 must respect.
