# ADR-006: Character Visual Assets and State Rendering

- **Status:** Accepted
- **Date:** 2026-09-10
- **Scope:** Character-driven presentation/runtime integration

## Decision

Criterivox uses a local HTML + standard JavaScript 2D skeletal runtime embedded into Flutter Web through `HtmlElementView`.

The runtime follows a Spine / DragonBones-style model without depending on either proprietary runtime:

- local JSON rig data defines a hierarchical bone graph
- character-specific skins, silhouettes, hair and signatures distinguish the roster
- semantic states drive explicit animation tracks
- looping and one-shot tracks are supported
- transitions blend between poses
- reduced-motion mode uses a deterministic non-animated pose
- Flutter owns the embedding and semantic-state boundary
- JavaScript owns skeletal interpolation and drawing

The current format is `criterivox-skeletal-v2`. It is an original lightweight runtime contract, not a claim that Criterivox currently embeds the commercial Spine runtime or the DragonBonesJS runtime. A future production-runtime adapter remains possible after research, licensing, authoring and performance validation.

## Runtime Contract

```text
Python semantic character state
        ↓
Dart character runtime boundary
        ↓
Flutter Web HtmlElementView
        ↓
local HTML + JavaScript
        ↓
JSON rig + character skin + semantic animation tracks
        ↓
hierarchical bone evaluation + pose blending
        ↓
visible 2D character
```

## Character Coverage

The runtime covers Dharen, Syvax, Sandre, Kaelen, Anuka, Vivren and Tarkis. They share a compatible humanoid topology intentionally, while their skins, scale, silhouette treatment, hair, accessory/signature and motion parameters differ.

Character identity, role and residence remain separate domain concerns. Visual design does not override canonical identity.

## Semantic States

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`.

These are semantic lifecycle states. They are not merely animation names, and Python remains the authority for their meaning.

## Consequences

- Legacy SVG character assets are no longer part of the presentation runtime.
- Characters can move continuously instead of swapping still frames.
- Visual implementation can evolve without putting bone/rendering knowledge into Python.
- The current implementation remains local and has no paid generation dependency.
- Production-quality authored artwork, mesh deformation, texture atlases, richer constraints and a third-party production runtime remain separate future decisions.
