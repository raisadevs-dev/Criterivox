# Criterivox Visual Appearance Architecture

## Locked visual direction

- Global visual language: **B — Cinematic Intelligence Interface**, with these retained exceptions from Option A:
  - deep spatial environments
  - layered translucent interfaces
  - characters integrated into rooms
  - information represented as physical/digital objects in the environment
  - subtle ambient motion
  - stronger visual activity during functional states
  - each character/home has its own visual vocabulary while remaining recognizably Criterivox
  - strong glass/translucent surfaces
  - character/environment as visual anchors
  - graphs, evidence, reasoning and artifacts receive stronger UI priority
  - emphasis on information clarity
  - cinematic transitions rather than constant environmental animation
- World/environment design: **A — Architectural World**.
- Animation system: **A — Flutter-native procedural animation**.
- Reusable Flutter components: **B — Layered Composition Architecture**.
- Browser appearance: responsive browser-first design using the same visual system across viewport sizes.
- Final validation: **B — Scenario-Based Appearance Validation**.
- All Criterivox homes, characters, bureaus and rooms follow the same global rules. No subsystem receives special visual treatment merely because of its sprint number.

## Asset workflow

Artwork is supplied as PNG/SVG. Flutter owns composition, state connection, motion, transitions, effects and interaction. No paid animation studio is a required dependency.

Character asset folders use canonical names for portrait, front/side/back views, expressions, states, accessories and tools. The exact character specifications will be completed during implementation from the supplied character materials.

## State integrity

Semantic animation must correspond to authoritative application/intelligence state. Ambient animation is decorative and must never imply computation, reasoning, evidence generation, handoff or completion that did not occur.

## Browser responsiveness

Use progressive spatial adaptation rather than simply shrinking desktop layouts. Large desktop, desktop/laptop, tablet and mobile browser layouts should preserve identity, hierarchy and interaction while reducing simultaneous information density as viewport space decreases.
