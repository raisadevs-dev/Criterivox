# Criterivox Character Visual System

The current character system is an animation subsystem, not an image-file dependency.

## Layers

1. `CharacterVisualProfile` stores identity, palette, hair, clothing, accessory and motion style.
2. `CharacterRuntimeView` remains the primary Flutter renderer and draws articulated body, clothing, hair, hands, face, accessories and semantic state gestures.
3. `SessionCharacterAnimationView` creates a fresh per-process session rhythm and composes the runtime renderer with generated vector detail effects.
4. `CharacterDetailLayer` adds generated vector highlights, signatures and state energy without PNG/GIF dependencies.
5. `GeneratedVectorAnimation` can emit session-aware SVG frames in memory for future sprite/vector consumers.
6. `CharacterAnimationStateMapper` provides the shared runtime-to-visual semantic contract.

## Current characters

Anuka, Dharen, Kaelen, Sandre and Syvax are registered for session generation. Future sprint characters can be added to the profile registry and active session set without changing the rendering contract.

## Runtime semantics

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `WARNING` and `COMPLETE` are visual states. More specific runtime activities such as routing, validating and contextualizing map to the shared `WORK` state unless a dedicated state is required.

The same semantic state can be forwarded to Bloom and telemetry, keeping character motion, petal energy and system status conceptually synchronized.

## Asset strategy

Procedural Flutter is the source of truth for identity. SVG/vector frames are generated as a secondary representation. Raster/pixel-art sprite sheets remain optional consumers for miniature views. GIF is not a foundational format.

## Accessibility

Reduced-motion mode stops session animation and keeps the semantic character renderer visible. No identity information depends on motion alone.
