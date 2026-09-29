# S4 Character Runtime and Introduction Architecture

**Date:** 2026-09-08  
**Branch:** `s4-domain-analysis-workspace`

## Runtime Architecture

```text
USER
  ↓
BLOOM / CHARACTER CHAT / WORKSPACE
  ↓
APPLICATION INTENT
  ↓
PYTHON APPLICATION + DOMAIN
  ↓
APPLICATION EVENT / TASK STATE
  ↓
DHAREN / SYVAX SEMANTIC CHARACTER STATE
  ↓
WEBSOCKET RUNTIME
  ↓
DART PRESENTATION STATE
  ↓
CHARACTER RENDERER
  ↓
SUPPLIED SVG-BACKED VISUAL STATE
  ↓
VISIBLE CHARACTER RESPONSE
```

## State Authority

The Python application/runtime owns semantic task and character state. Dart receives that state and maps it to presentation. The renderer must not create a contradictory semantic lifecycle.

## Character Presentation Mapping

```text
IDLE         → available/waiting visual
RECEIVE      → receiving task/input visual
WORK         → active processing visual
COMMUNICATE  → explanation/communication visual
HANDOFF      → responsibility transfer visual
COMPLETE     → completion/result visual
```

## App Introduction Architecture

The App Introduction is a presentation surface, not a replacement for the core workflow.

```text
                 CRITERIVOX
                     │
          ┌──────────┴──────────┐
          │                     │
       BLOOM              APP INTRODUCTION
          │                     │
     start work          understand system
          │                     │
    ┌─────┴─────┐        ┌──────┴──────┐
    │           │        │             │
Workspace     Chat     Syvax         Dharen
    │           │        │             │
    └──────┬────┘        └──────┬──────┘
           │                    │
           └──── Shared Analysis Task ────┘
```

## Asset Architecture

Runtime:

```text
SVG-backed assets
      ↓
Flutter renderer
      ↓
state-specific presentation
```

Authoring:

```text
Glaxnimate
      ↓
SVG / animation assets
      ↓
Flutter
```

Glaxnimate is not required by the runtime.

## Design Principle

**Life is behavior, not decoration.**

Character visuals are tied to meaningful system states. Backgrounds and environmental composition remain part of the visual identity where they are supplied by the source artwork.
