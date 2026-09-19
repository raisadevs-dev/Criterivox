# Criterivox Visual Appearance Architecture

**Status: DISCUSSION-LOCKED / IMPLEMENTATION-PENDING**

This document records the appearance decisions made for the remaining Criterivox visual architecture work. It is intentionally system-wide: S7, S8 and every other subsystem/homeroom follow the same visual language. Sprint number does not determine visual priority.

## 1. Global Criterivox visual language

**Selected base: Option B — Cinematic Intelligence Interface**

The application should feel like an advanced intelligence environment rather than a conventional dashboard.

Selected characteristics retained from the alternative civilization-oriented direction:

- Deep spatial environments.
- Layered translucent interfaces.
- Characters integrated into rooms.
- Information represented as physical/digital objects within the environment.
- Subtle ambient motion.
- Functional states create stronger visual activity.
- Each character/home has its own visual vocabulary while remaining recognizably Criterivox.
- Strong glass/translucent surfaces.
- Characters and environments remain major visual anchors.
- Graphs, evidence, reasoning and artifacts receive strong UI priority.
- Information clarity is prioritized over decoration.
- Cinematic transitions are preferred over constant environmental animation.

### Core rule

**Artwork provides identity; Flutter provides composition, state connection, motion, effects and interaction.**

The visual system must not imply that a computation, reasoning step, evidence event, handoff or completion happened unless the underlying system state supports it.

## 2. World / environment design

**Selected: Option A — Architectural World**

Criterivox environments are designed as actual spatial architecture rather than unrelated page backgrounds.

Conceptual structure:

```
World
 └── Civilization / Residence
      └── Home
           └── Room
                ├── Environment
                ├── Character
                ├── Information
                ├── Artifact
                └── Interaction
```

The Criterivox Civilization and Human Residence remain distinct experiential worlds while sharing the same visual system.

Architectural depth should be achieved primarily through layered 2D composition and responsive Flutter layout, not by introducing a mandatory 3D engine.

## 3. Character visual specifications

**Deferred to implementation by explicit decision.**

All 15 characters will receive detailed specifications when implementation begins. The user will provide the available character materials at that time.

Each specification is expected to cover:

- canonical identity
- role and visual metaphor
- face
- hair
- clothing
- silhouette
- palette
- accessories
- tools
- portrait
- front/side/back full-body views
- expression states
- activity states
- environmental relationship
- animation behavior

No character specification is to be invented prematurely when source materials are not yet provided.

## 4. PNG / SVG asset preparation pipeline

The project will use a **PNG/SVG-first workflow**.

### Required workflow

```
PNG / SVG artwork
      ↓
canonical asset folder
      ↓
Flutter composition
      ↓
authoritative application/intelligence state
      ↓
procedural animation / effects
      ↓
visual interaction
```

A paid external animation studio is **not a required architectural dependency**.

### Asset principles

- PNG is acceptable for supplied artwork.
- SVG is preferred where scalable/vector artwork is available.
- Assets should be separated into meaningful layers when the supplied material permits it.
- Flattened artwork cannot be made independently animatable without separate source layers.
- The canonical character identity must remain stable across all rooms and screens.
- Asset filenames use lowercase snake_case.
- Git placeholder files may be used to preserve otherwise-empty directories.

### Canonical character asset categories

- portrait
- full_body_front
- full_body_side
- full_body_back
- expressions
- states
- accessories
- tools

Expected semantic names include:

```
<character>_portrait.png

<character>_front.png
<character>_side.png
<character>_back.png

<character>_neutral.png
<character>_smiling.png
<character>_thinking.png
<character>_focused.png
<character>_surprised.png

<character>_idle.png
<character>_receive.png
<character>_work.png
<character>_communicate.png
<character>_handoff.png
<character>_complete.png
```

Accessories and tools use descriptive names such as `<character>_pendant.svg`.

### Current asset status

The canonical asset folder structure has been created in the repository. Final character artwork is **not yet populated** because the character source materials are to be supplied during implementation.

Do not treat procedural placeholders, if later added, as final character design.

## 5. Animation system

**Selected: Option A — Flutter-native procedural animation**

Animation is implemented within Flutter using the application's existing rendering and state architecture.

Expected mechanisms may include:

- AnimationController
- Tween / curve-based interpolation
- transforms
- opacity
- scale
- rotation
- clipping
- CustomPainter
- gradients
- shaders where justified
- state-driven animation controllers
- layered PNG/SVG composition

### Two animation classes

**Semantic animation**
- driven by authoritative application/intelligence state
- represents real activity, state changes, handoffs, completion, warnings or other meaningful events

**Ambient animation**
- decorative environmental motion
- may include subtle lighting, particles, breathing-like movement or other atmosphere

Ambient animation must never communicate false computation or activity.

Animation should be cinematic but controlled. Constant motion is not a requirement.

## 6. Reusable Flutter visual components

**Selected: Option B — Layered Composition Architecture**

The reusable visual architecture is scene/layer based:

```
Scene
 ├── EnvironmentLayer
 ├── CharacterLayer
 ├── LightingLayer
 ├── InformationLayer
 ├── ArtifactLayer
 ├── InteractionLayer
 └── TransitionLayer
```

A room composes the layers it actually needs rather than inheriting a rigid visual template.

Examples:

```
Room
 = Environment
 + Character
 + Information
 + Artifact
 + Interaction
```

This preserves a shared Criterivox identity while allowing each home and character to have a distinct visual vocabulary.

Reusable lower-level components should still be extracted wherever repetition is real. The architecture is layered composition, not permission to duplicate widgets indiscriminately.

## 7. Responsive / cross-platform browser appearance

**Selected: responsive browser-first design.**

The primary target for this appearance architecture is the browser.

The same visual system must adapt across:

- large desktop
- desktop/laptop
- tablet
- mobile browser

The design must not simply shrink a desktop screen until its information becomes microscopic.

### Progressive adaptation

Large viewports may show:

- environment
- character
- multiple information surfaces
- artifacts
- relationships

Smaller viewports progressively reduce simultaneous information density while preserving:

- character identity
- spatial context
- information hierarchy
- interaction access
- navigation
- functional feedback

Use responsive breakpoints, flexible layouts, collapsible surfaces, prioritization and progressive disclosure.

## 8. Final appearance validation

**Selected: Option B — Scenario-Based Appearance Validation**

Validation will focus on complete user/system journeys rather than only isolated screenshots.

Representative scenarios should include:

1. Entry and navigation through the civilization/residence.
2. Character idle state.
3. Active computation.
4. Information/artifact presentation.
5. Character-to-character handoff.
6. Uncertainty or warning.
7. Human challenge/intervention.
8. Result/completion.
9. Responsive browser resizing.
10. Recovery/failure states.

For each scenario verify:

- visual identity
- environment continuity
- state-to-visual correctness
- interaction feedback
- information hierarchy
- artifact visibility
- transition behavior
- responsive behavior
- accessibility
- absence of misleading animation

## 9. Appearance implementation boundary

The appearance architecture is now considered **locked at the discussion level**.

Remaining implementation-time work:

1. Receive the character source materials.
2. Produce the 15 character visual specifications.
3. Prepare/clean supplied PNG/SVG assets.
4. Populate the canonical asset directories.
5. Implement the layered Flutter scene architecture.
6. Implement procedural animation.
7. Implement responsive browser composition.
8. Execute scenario-based appearance validation.
9. Record implementation deviations in project documentation rather than silently changing the architecture.

## 10. Non-goals

This architecture does not require:

- Rive.
- A paid animation studio.
- A proprietary animation runtime.
- A mandatory 3D engine.
- Separate visual architectures for individual sprints.
- Constant decorative animation.
- Flattened one-image-per-screen character implementations.

