# ADR-006: Character Visual Assets and State Rendering

- **Status:** Accepted and superseded by S6 skeletal runtime decision
- **Date:** 2026-09-10
- **Scope:** Character-driven presentation/runtime integration

## Context

Criterivox requires characters to behave as functional interaction entities rather than decorative mascots. Python remains authoritative for semantic character state and application behavior.

The former SVG frame system was a temporary presentation implementation. It has now been removed. Character rendering needs continuous skeletal motion, explicit bone/pose data, state blending, and a renderer that can evolve independently of the Flutter domain layer.

## Decision

Use a local HTML + standard JavaScript 2D skeletal runtime embedded into Flutter Web through `HtmlElementView`.

The runtime follows a Spine / DragonBones-style model:

- character definition is plain JSON data
- bones/limbs are animated through pose tracks
- skins/signatures are character-specific
- semantic states drive animation tracks
- state transitions blend rather than swapping still images
- Flutter owns the embedding boundary and semantic state
- JavaScript owns visual interpolation and drawing

The current runtime is an original Criterivox skeletal format (`criterivox-skeletal-v1`). It is deliberately not coupled to a proprietary authoring tool or external network asset service. The JSON model leaves a future adapter path open for a production Spine or DragonBones runtime if research, licensing, performance and authoring requirements justify it.

The supported semantic lifecycle remains:

`IDLE → RECEIVE → WORK → COMMUNICATE → HANDOFF → COMPLETE`

with `WARNING` as an exceptional state.

## Runtime Contract

```text
Python semantic character state
        ↓
WebSocket runtime contract
        ↓
Dart PresentationState
        ↓
Flutter skeletal runtime bridge
        ↓
local HTML / JavaScript canvas runtime
        ↓
JSON skeleton + animation tracks
        ↓
blended 2D character pose
```

## Character Coverage

The runtime registry currently contains distinct skeletal definitions for:

- Dharen
- Syvax
- Sandre
- Kaelen
- Anuka
- Vivren
- Tarkis

Character identity, role and residence remain separate domain concerns. Visual design must not override canonical character identity.

## Consequences

### Positive

- No SVG character dependency remains in the presentation runtime.
- Character states are rendered dynamically rather than as still-frame swaps.
- Visual animation can evolve without changing Python domain semantics.
- Character-specific visual signatures are represented as runtime data.
- JSON skeleton data can later be exported or replaced by a production skeletal runtime format.
- The web runtime remains local and does not require a paid generation service.

### Trade-offs

- The current renderer is an original lightweight skeletal implementation, not a full production Spine/DragonBones editor/runtime.
- Production-quality art authoring and richer bone constraints remain future work.
- Flutter Web platform-view behavior must be covered by CI/browser testing.

## Rejected Alternatives

1. Keep the previous SVG frame assets. Rejected because they limited state rendering and left a placeholder-oriented visual architecture.
2. Put animation logic entirely inside Flutter. Rejected because the character renderer should remain replaceable and web-skeletal animation is better isolated at the presentation boundary.
3. Make Python aware of bones or renderer details. Rejected because semantic state and visual implementation must remain separated.
4. Introduce a proprietary production runtime before research/licensing validation. Rejected for now; the Criterivox skeletal contract keeps that decision reversible.
