# Criterivox Character Visual Contract

## Decision

Criterivox uses a **2.5D runtime procedural/vector character system with one authored hero portrait per character**.

The supplied Criterivox group images are the **visual identity reference set**. They establish the shared visual language: cinematic fantasy-tech, dark structured clothing, luminous role accents, distinct silhouettes/accessories, and a cohesive civilization rather than fifteen unrelated mascots.

The group images are not treated as fifteen runtime sprites.

## Separation of concerns

```
Authoritative Character Registry
        |
        v
Semantic Runtime State
        |
        v
Visual State Adapter
        |
        +--------------------+
        |                    |
        v                    v
Visual Character         Animation State
Definition                   |
        |                    |
        +---------+----------+
                  v
        2.5D Character Renderer
                  |
        +---------+----------+
        |                    |
        v                    v
  Runtime body          Hero portrait
  procedural/vector     authored asset
```

## Contract

Every character visual definition MUST provide:

- stable character id
- display name
- visual family
- accent identity
- accessory identity
- hero portrait asset path
- supported operational states
- supported attention states
- default pose
- animation capability set

The visual layer MUST NOT invent semantic runtime facts.

A character glowing, moving, looking toward another character, or changing pose is presentation of a recorded state. It is not evidence that hidden work happened.

## Hero portraits

There is exactly **one canonical hero portrait per character**.

Required assets:

`presentation/assets/characters/portraits/{character_id}.webp`

Required ids:

`syvax, sandre, kaelen, dharen, anuka, vivren, tarkis, pramon, bodhex, medrus, epistre, veridat, manis, viveda, anukor`

Hero portraits are used for:

- Character Chat identity
- profile/detail surfaces
- introduction/civilization presentation
- researcher-facing character identity when appropriate

They are not used as the animated full-body representation.

## Runtime body

The runtime body is constructed from layered vector/procedural components:

- grounding shadow
- legs/feet
- torso
- clothing layers
- arms/hands
- neck/head
- hair/head silhouette
- face
- role accessory
- state/attention overlay
- subtle lighting/glow

The renderer should preserve each character's identity while allowing the pose and motion to change at runtime.

## Animation mapping

Operational states:

- IDLE: subtle breathing/idle motion
- RECEIVE: orientation and attention shift toward the interaction source
- WORK: focused posture and restrained activity
- COMMUNICATE: orientation/gesture toward another participant
- HANDOFF: directional transfer gesture
- COMPLETE: completion emphasis, then settle
- WARNING: controlled warning emphasis

Attention states:

- QUIET
- ATTENTIVE
- FOCUSED
- BUSY
- WAITING
- NEEDS_USER
- COMPLETING
- RECOVERING

No animation may be interpreted as a reasoning trace or hidden chain-of-thought.

## 2.5D requirements

The renderer should create depth through:

- independently transformed layers
- foreground/background ordering
- parallax offsets
- soft shadow
- restrained glow
- perspective-aware accessory placement
- head/eye orientation
- layered clothing shapes

It should remain lightweight enough for mobile and desktop Flutter rendering.

## Portrait-to-body relationship

The hero portrait is the canonical visual reference for identity.

The runtime body does not need pixel-level reproduction of the portrait. It must preserve:

- recognizable hair/head silhouette
- clothing language
- accent family
- major accessory
- broad character proportions
- role-specific visual motif

This avoids forcing a painterly portrait into an animation system that was never designed to animate it.

## Supplied reference images

The supplied group images are reference material for the character visual family and individual identity mapping.

They should be treated as design references, not as runtime scene backgrounds or sprite sheets.

## Current implementation boundary

Implemented:

- visual character contract
- visual registry for all 15 characters
- runtime state enums
- Flutter procedural 2.5D renderer
- hero portrait asset contract

Not yet populated:

- the 15 individual hero portrait files
- final character-specific vector silhouettes/clothing meshes
- full animation library
- environment-specific character poses

This boundary is intentional. It prevents the repository from pretending that the final artwork already exists.

## Deprecated direction

The old skeletal-runtime proposal is not part of this architecture.

When cleanup is performed, skeletal-runtime README/spec references should be removed or marked superseded. The authoritative visual architecture is this contract.
