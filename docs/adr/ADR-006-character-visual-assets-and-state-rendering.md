# ADR-006: Character Visual Assets and State Rendering

- **Status:** Accepted
- **Date:** 2026-09-10
- **Scope:** Character-driven presentation/runtime integration and future character asset production

## Decision

Criterivox separates **character behavior and presentation capability** from **final authored character artwork**.

During the functional sprints, character identity, responsibility, interaction, semantic lifecycle, communication, handoff and presentation-layer behavior are implemented first. Final visual production is deliberately deferred until the functional character system is stable.

The presentation layer must nevertheless be visibly functional now. Therefore, Criterivox uses a **pure Flutter procedural character renderer** during the functional sprints. It provides animated character representations directly in the Flutter presentation layer without requiring final authored artwork, SVG assets, an iframe, JavaScript, or a third-party animation runtime.

The current Flutter renderer uses `CustomPainter` and `AnimationController` to provide reusable visual behavior for the canonical semantic states:

- `IDLE`
- `RECEIVE`
- `WORK`
- `COMMUNICATE`
- `HANDOFF`
- `COMPLETE`
- `WARNING`

The procedural renderer provides state-appropriate motion including breathing, subtle weight shift, attention/head movement, arm/hand movement, speaking indication, facial-state indication and lightweight accessory motion. These are **presentation approximations for functional validation**, not claims of final authored animation quality.

The presentation boundary remains independent from the future authored asset pipeline. When final artwork becomes available, the procedural renderer can be replaced behind the same character presentation contract without changing character responsibilities, domain services or semantic lifecycle meaning.

A production skeletal asset/runtime decision remains a separate end-stage workstream. The future production pipeline may use a validated Spine/DragonBones-style production solution or another suitable runtime, subject to research, platform support, performance, authoring and licensing requirements. Criterivox must not claim integration or compatibility with a third-party runtime until that runtime and its format/licensing requirements have actually been verified.

## Current Functional-Sprint Runtime

```text
Python semantic character state
        ↓
Dart character presentation boundary
        ↓
Flutter CharacterPresentation
        ↓
Pure Flutter procedural character renderer
        ↓
CustomPainter + AnimationController
        ↓
Visible animated character representation
```

This runtime is intentionally local and dependency-light. It exists to make character behavior and semantic state visible while final artwork is deferred.

## Future Production Asset Runtime

```text
Canonical Character Bible
        ↓
Visual specification
        ↓
AI-assisted artwork preparation
        ↓
Separate authored pieces
        ↓
Rigging / attachments / weights
        ↓
Animation layers
        ↓
Runtime validation
        ↓
Validated production runtime adapter
        ↓
Flutter character presentation boundary
        ↓
Final authored character
```

The application domain must not depend on artwork format, bone names, rendering technology or a particular vendor runtime.

## Functional-Sprint Rule

Character visuals are not allowed to block functional character work.

The following are implemented during normal sprints:

- canonical character identity and role
- residence and interaction relationships
- semantic lifecycle states
- character communication and chat behavior
- presentation-layer state rendering
- pure Flutter animated character representations
- accessible status text
- reduced-motion behavior
- reserved presentation slots
- explicit indication that final authored artwork is coming later
- runtime contracts capable of accepting the future authored presentation

The following remain intentionally deferred until the dedicated character production workstream:

- final polished character artwork
- final separable artwork pieces
- production rigging/weight authoring
- final facial animation
- production-quality hair/clothing secondary motion
- texture atlases/meshes and advanced deformation
- final art-direction approval
- selection and integration of a third-party production runtime, if justified

## Automation Principle

Deterministic and repetitive character-production work should be automated wherever practical.

Automation may generate or validate:

- character package directories
- manifests and naming conventions
- skeleton schemas and reusable rig templates
- attachment metadata
- animation-track templates
- procedural secondary-motion parameters
- asset validation
- missing-asset detection
- runtime compatibility checks
- CI validation
- character-package completeness reports

AI may assist with visual concept exploration, artwork generation, controlled variations, cleanup and piece-separation preparation. Human control remains required for canonical character identity, artistic direction, visual quality and final acceptance.

## Character Coverage

The current functional character presentation contract covers the roster represented by the existing character identity system, including Dharen, Vivren, Tarkis, Sandre, Kaelen, Anuka and Syvax. The character system is extensible to the remaining canonical roster without requiring a new presentation architecture.

Character identity, role, residence and behavioral responsibility remain separate domain concerns. Visual design does not override canonical identity.

## Semantic States

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`.

These are semantic lifecycle states. They are not merely animation names, and Python remains authoritative for their meaning.

## Consequences

- Legacy SVG character assets are not part of the current presentation architecture.
- The functional application no longer needs the web iframe/JavaScript character renderer.
- Characters are visibly animated in the Flutter presentation layer before final artwork exists.
- Character behavior can be completed independently of final artwork.
- Final artwork can be inserted later without redesigning character responsibilities or application services.
- The current functional renderer has no paid generation dependency.
- Procedural visuals are intentionally not represented as production-quality authored character art.
- A production skeletal runtime remains a future technical/research decision rather than an unverified claim.

## Related Work

The living end-stage production task is maintained in:

`docs/characters/CHARACTER-ASSET-PRODUCTION-MASTER.md`
