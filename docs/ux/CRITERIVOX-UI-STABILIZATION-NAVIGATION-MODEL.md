# Criterivox UI/UX Integration Model — Current Branch

**Branch:** `ui-stabilization-system-behavior`  
**Status:** Current implementation contract

## Product boundary

Criterivox has two complementary experiential domains:

- **Criterivox Civilization:** the observable system world. It explains responsibilities, homes, characters and system activity.
- **Human Territory:** the human-owned workspace where context, decisions, outcomes and collaboration happen.

Characters are presentation representations of actual system activity. They are not the computational engine.

## Canonical navigation

The application shell uses contextual children rather than a flat list of aliases:

```
Introduction
├── Criterivox Civilization / Bloom
└── Human Territory
    ├── Authentication
    │   ├── Sign Up / Login
    │   └── Guest
    └── Private Workspace
        ├── Private Room
        ├── Decision Desk
        ├── Results Journal
        └── Collaboration Commons
            ├── Meeting Hall
            ├── Project Rooms
            └── Shared Workspaces
```

Historical routes such as `workspace`, `home02`, `human-residence-entry`, `decision-history` and `collaboration-room` remain compatibility/runtime routes where existing code still references them, but they are not presented as competing destinations.

## Human Territory semantics

### Private Room

Personal history, private context, supplied material and user-owned records. Existing local-first persistence remains authoritative.

### Decision Desk

The canonical decision-support destination. It connects to the existing Human Residence decision endpoint rather than inventing a second decision engine. The UI translates the returned strategy, challenges and trace into human-readable sections.

### Results Journal

A distinct destination for reviewing saved decision outcomes. It reads the existing `results_journal` persistence rather than duplicating decision generation.

### Collaboration Commons

Meeting Hall, Project Rooms and Shared Workspaces have distinct presentation destinations and semantics. They share the existing collaboration boundary underneath instead of pretending that three labels are three different engines.

## Progressive disclosure

- **Level 1:** explain the world and where responsibilities live.
- **Level 2:** explain useful operational meaning without exposing implementation identifiers by default.
- **Deep inspection:** expose evidence, reasoning, provenance and technical detail when the human asks for it.

Visual representation should follow semantic type: timelines for temporal history, tables for structured records, relationship views for dependencies, status/progress for state, evidence chains for evidence, and decision structures for choices and trade-offs.

## Introduction

The Introduction now explains:

1. what Criterivox is,
2. supported user-facing capabilities,
3. the practical workflow,
4. why the Civilization world exists,
5. who the characters are,
6. Bloom's purpose,
7. the distinction between Civilization and Human Territory.

It is no longer a character roster masquerading as product orientation.

## Character navigation

Character identity remains sourced from the canonical `CharacterIdentities` registry. Character taps can resolve to a dedicated Character Focus surface. Character Focus explicitly states that the character represents a responsibility while computation remains in runtime/domain services.

## Bloom / World Portal

Bloom remains the existing interaction surface and activation boundary. World Portal/Human Residence continues to host the human-facing entry and residence behavior. No replacement Bloom orchestration was introduced.

## Truth boundary

The UI must not imply that an animation is computation. Runtime-backed activity is authoritative. Static/read-model relationships are presented as such. Missing production infrastructure remains a boundary rather than a fabricated success state.


## Civilization / Bloom Integration Update

The current stabilization branch treats **Criterivox Workers / Bloom** as the civilization-facing middle door of the application.

### Canonical flow

```
Workers / Bloom
  → World Portal
  → Bloom orientation
  → Civilization overview
  → District / Home
  → Character Focus
  → Responsibility / Level 2 inspection
```

Bloom remains an orientation and visualization surface. It does not own orchestration or computation.

### Persistent Bloom Companion

The branch now provides a shell-level `BloomCompanion` presentation layer for the civilization experience. It remains visible across supported Bloom, Civilization, Home, Level 2, reasoning-room and Character Focus navigation. Its context changes with the current destination, but it owns no computational state and does not become a dependency of runtime/domain services.

The companion deliberately presents contextual orientation rather than invented agent intelligence. Character identity is read from the existing `CharacterIdentities` registry.

### Character navigation

Character selection continues to use the canonical identity registry. Character Focus now exposes a route into the mapped Home for all conventional residents. The mapping is kept in the shell as presentation navigation only and does not duplicate the domain character registry.

Anukor is intentionally excluded from the conventional character-to-home mapping because the current civilization model defines Anukor as a network/cross-home presence.

### Current home mapping

| Home | Residents |
|---|---|
| Gateway | Syvax |
| Data Stewardship | Sandre, Kaelen |
| Context | Dharen, Anuka |
| Intelligence / Reasoning | Vivren, Tarkis |
| Decision | Pramon, Bodhex, Manis |
| Evidence | Medrus, Epistre, Veridat |
| Knowledge | Viveda |
| Network territory | Anukor |

These assignments follow the current presentation civilization model and existing character-society documentation. They are not a new computational registry.

### Progressive disclosure

Civilization Level 1 establishes world/home/resident meaning. Level 2 exposes operational meaning through the existing `Level2OperationalPage` catalog. Deeper evidence/reasoning/technical information remains behind explicit inspection surfaces.

### Truth boundary

The UI does not manufacture system activity, evidence, relationships or computational results to make the world appear alive. Runtime/domain work remains authoritative; the civilization and companion are presentation/inspection surfaces.


## Semantic visualization implementation

The semantic visual contract is now implemented as reusable presentation components in `presentation/lib/semantic_visualizations.dart` and is wired into Civilization and Level 2:

| Information type | Rendered form | Source boundary |
|---|---|---|
| Current civilization/read-model state | Status indicator | Presentation/runtime availability |
| Home resident quantities | Horizontal bar comparison | Canonical home resident lists |
| Home/room records | Structured table | Canonical home and Level 2 catalogs |
| Civilization relationships | Relationship network | `CivilizationPage.relationships` |
| Inspection progression | Timeline | Canonical World → Home → Character → Responsibility path |
| Evidence progression | Evidence chain | Evidence Home inspection surface |
| Decision framing | Decision structure | Decision Home inspection surface |
| Responsibility summary | Cards | Selected Level 2 room |
| Documented responsibility coverage | Progress visualization | Level 2 room catalog |

Bars are only used for a real quantitative value already present in the read-model, rather than fabricated telemetry. Relationship labels are the documented semantic relationships and do not imply social affinity. Evidence and decision surfaces expose structure, not private chain-of-thought.

The Civilization navigation test suite now asserts the semantic network/registry surfaces and Level 2 tests assert the evidence, decision and contextual visual forms.
