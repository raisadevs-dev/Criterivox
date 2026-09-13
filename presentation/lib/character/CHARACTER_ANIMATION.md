# Criterivox Character Animation

The character visual system is runtime-generated. It does not require PNG or GIF artwork.

## Current characters

The session animation director currently registers:

- Anuka
- Dharen
- Kaelen
- Sandre
- Syvax

Later sprint characters can be added to `SessionCharacterAnimation.activeCharacters` without changing the animation contract.

## Runtime model

`CharacterPresentation` renders `SessionCharacterAnimationView`, which wraps the existing procedural `CharacterRuntimeView`.

The procedural painter remains responsible for character identity, palette, hair, clothing, accessories, facial motion and semantic state gestures. The session director adds a fresh per-session motion profile around that renderer.

Each process receives a new session seed. The seed is combined with the character ID to produce a stable profile for that character during the session. The profile controls animation duration, phase, sway, lift, emphasis and direction.

This means two sessions can have different subtle motion rhythms while the character's identity and palette remain stable.

## Asset strategy

The architecture intentionally leaves room for generated vector/SVG or sprite-sheet frames later. Those assets can become an optional renderer under the same animation contract. GIF is not required and is not the system of record.

## Runtime states

The existing renderer supports semantic states including:

- IDLE
- WORK
- COMMUNICATE
- RECEIVE
- HANDOFF
- WARNING
- COMPLETE

Future characters should reuse these states or explicitly extend the shared contract.

## Reduced motion

`reducedMotion` is propagated through the presentation layer. When enabled, the session animation controller stops and the existing procedural renderer is used without the session animation envelope.
