# ADR-006: Character Visual Assets and State Rendering

- **Status:** Accepted
- **Date:** 2026-09-08
- **Scope:** S4 character-driven presentation/runtime integration

## Context

CRITERIVOX requires Dharen and Syvax to behave as functional interaction entities rather than decorative mascots. The supplied character boards define the intended visual identity and provide six representative visual states for the initial character lifecycle.

The application already has a semantic runtime model in which Python is authoritative for character state and Flutter renders that state. The earlier SVG artwork was only placeholder vector artwork and did not represent the supplied character designs.

## Decision

Use the supplied Dharen and Syvax visual boards as the visual source for the initial character presentation assets.

The supported lifecycle order is:

`IDLE → RECEIVE → WORK → COMMUNICATE → HANDOFF → COMPLETE`

Flutter selects the visual frame from the semantic presentation state. Flutter must not independently invent or reorder the character lifecycle.

Character artwork remains a presentation concern. Python continues to own semantic state, task lifecycle, and application behavior.

The current implementation uses SVG-backed character assets and a reusable `CharacterFrame` renderer. The supplied visual material, including its designed background treatment, is retained rather than replacing the characters with isolated placeholder silhouettes.

## Runtime Contract

```text
Python semantic character state
        ↓
WebSocket runtime
        ↓
Dart PresentationState
        ↓
CharacterFrame / character renderer
        ↓
Supplied visual state
        ↓
Flutter presentation
```

## Authoring Decision

SVG is the runtime asset format. Glaxnimate remains an authoring-time tool for future refinement and animation authoring. Glaxnimate is not a runtime dependency.

The current assets should not be described as pure vector redraws of the supplied images. They are SVG-backed presentation assets using the supplied visual material. Future asset work may convert individual states into cleaner, individually authored SVG/animation assets without changing the runtime contract.

## Consequences

### Positive

- Dharen and Syvax now visually correspond to the supplied character identity boards.
- Character lifecycle state has a direct presentation representation.
- Runtime semantics remain independent of artwork.
- Future character animation work can replace assets without redesigning Python application behavior.

### Trade-offs

- The supplied boards are state references, not a complete production animation rig.
- Individual state assets may need further authoring for smoother animation and smaller payloads.
- Background-rich visual assets require deliberate responsive cropping/layout handling.

## Rejected Alternatives

1. Keep the previous placeholder SVG characters. Rejected because they did not represent the intended character identity.
2. Put character lifecycle logic entirely inside Flutter. Rejected because semantic state must remain authoritative outside presentation.
3. Treat six still frames as a complete animation system. Rejected because visual keyframes and animation authoring are different concerns.
