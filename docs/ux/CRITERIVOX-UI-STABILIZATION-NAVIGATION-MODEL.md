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
