# ADR-006: Character Visual Assets and State Rendering

- **Status:** Accepted
- **Date:** 2026-09-10
- **Scope:** Character-driven presentation/runtime integration and future character asset production

## Decision

Criterivox separates **character behavior and presentation capability** from **final authored character artwork**.

During the functional sprints, character identity, responsibility, interaction, semantic lifecycle, communication, handoff and presentation-layer behavior are implemented first. The presentation layer therefore provides a real character slot and Flutter capability surface now, while final authored avatars are explicitly marked **Coming Soon** until the end-stage character asset work.

For the current web presentation/runtime boundary, Criterivox uses a local HTML + standard JavaScript 2D skeletal runtime embedded into Flutter Web through `HtmlElementView`.

The runtime uses a Spine / DragonBones-style conceptual model without claiming to embed either third-party runtime:

- local JSON defines a reusable hierarchical humanoid bone graph
- character-specific skin parameters, silhouettes, hair, accessories and signatures distinguish the roster
- semantic states drive explicit animation tracks
- looping and one-shot tracks are supported
- transitions blend between poses
- reduced-motion mode uses a deterministic non-animated pose
- Flutter owns the embedding and semantic-state boundary
- JavaScript owns skeletal interpolation and drawing

The current format is `criterivox-skeletal-v2`. It is an original lightweight Criterivox runtime contract. It is **not** a claim of Spine runtime compatibility or DragonBonesJS runtime integration.

A production asset/runtime decision remains a separate end-stage workstream. If research, licensing, authoring requirements, performance requirements or visual-quality requirements justify a production runtime, Criterivox may add a runtime adapter rather than coupling the domain/application layers to that vendor runtime.

## Functional-Sprint Rule

Character visuals are not allowed to block functional character work.

The following are implemented during normal sprints:

- canonical character identity and role
- residence and interaction relationships
- semantic lifecycle states
- character communication and chat behavior
- presentation-layer state rendering
- accessible status text
- reduced-motion behavior
- reserved avatar/presentation slots
- explicit `Coming Soon` treatment for final artwork
- runtime contracts that can accept authored assets later

The following are intentionally deferred until the dedicated character production workstream:

- final polished character artwork
- final separable artwork pieces
- production rigging/weight authoring
- final facial animation
- production hair/clothing secondary motion
- texture atlases/meshes and other advanced deformation
- final art-direction approval
- selection and integration of a third-party production runtime, if justified

## Runtime Contract

```text
Python semantic character state
        ↓
Dart character presentation/runtime boundary
        ↓
Flutter presentation slot
        ↓
Current: placeholder / capability surface
        ↓
Future: authored skeletal character asset
        ↓
local HTML + JavaScript runtime or validated production-runtime adapter
        ↓
skeleton + skin + semantic animation data
        ↓
visible character
```

The application domain must not depend on artwork format, bone names, rendering technology or a particular vendor runtime.

## Automation Principle

Deterministic and repetitive character-production work should be automated wherever practical.

Automation may generate or validate:

- asset directory structures
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

Human control remains required for final character identity, artistic direction, visual quality and acceptance of AI-generated artwork.

## Character Coverage

The current runtime contract covers Dharen, Syvax, Sandre, Kaelen, Anuka, Vivren and Tarkis. They intentionally share a compatible humanoid topology while remaining distinct through character-specific visual parameters.

Character identity, role, residence and behavioral responsibility remain separate domain concerns. Visual design does not override canonical identity.

## Semantic States

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`.

These are semantic lifecycle states. They are not merely animation names, and Python remains authoritative for their meaning.

## Consequences

- Legacy SVG character assets are not part of the presentation architecture.
- Character behavior can be completed before final artwork exists.
- The application already has a stable presentation location for future avatars.
- Final artwork can be inserted without redesigning character responsibilities or application services.
- The current implementation remains local and has no paid generation dependency.
- The lightweight runtime is useful for current state/rendering validation but is not represented as a production Spine/DragonBones runtime.
- Production-quality authored artwork, advanced deformation, richer constraints and a third-party production runtime remain separate future decisions.

## Related Work

The dedicated future production task is maintained in:

`docs/characters/CHARACTER-ASSET-PRODUCTION-MASTER.md`
