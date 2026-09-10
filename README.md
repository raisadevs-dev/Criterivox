# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S5 — Data Foundation + Sandre Data Stewardship is complete.** S5 established the provenance-aware data foundation, confirmation-gated stewardship workflow, Sandre working surface, and the runtime integration required to carry validated material toward Dharen analysis. The existing Python ↔ WebSocket ↔ Flutter architecture remains intact.

## Current Sprint

**S6 — Context Engine**

S5 hands S6 a validated canonical data foundation containing raw/supplied/derived distinctions, provenance, validation and normalization information, confirmation state, and transformation history. S6 adds context reasoning above this boundary without replacing the S5 data foundation.

## S5 Completed Foundation

```text
USER MATERIAL
      ↓
SOURCE / COLLECTION INTAKE
      ↓
EXTRACTION
      ↓
CANDIDATE INFORMATION
      ↓
USER CONFIRMATION
      ↓
PROFILE / QUALITY
      ↓
NORMALIZE / PREPARE
      ↓
CANONICAL DATA
      ↓
SANDRE DATA STEWARDSHIP
      ↓
DHAREN ANALYSIS
      ↓
S6 CONTEXT ENGINE
```

S5 preserves source identity, provenance, user confirmation, explicit missingness, anomaly flags, reproducible transformations, and canonical downstream representation. Research-specific semantics remain evidence-gated and are not invented by engineering.

## Character and Interaction Boundary

- **Syvax** remains the dialogue host.
- **Sandre** owns Data Stewardship and can participate in an independent stewardship chat surface.
- **Dharen** owns the Analysis Workspace and downstream structural-context handoff.
- **Bloom** remains the capability-discovery surface rather than a duplicate work area.

Python remains authoritative for semantic character state. Flutter renders that state through the existing WebSocket presentation contract.

## Character Animation Stack

Criterivox uses a vector-first character presentation pipeline:

- **Flutter / Dart** — application presentation, state-driven motion, responsive layout and accessibility.
- **SVG** — portable vector artwork for characters and interface animation assets.
- **Glaxnimate** — authoring workflow for vector character artwork and animation source.

The practical pipeline is:

```text
Character design
      ↓
Glaxnimate
      ↓
SVG assets
      ↓
Flutter SVG rendering
      ↓
Flutter state-driven animation
      ↓
Visible character
```

## Character State Vocabulary

The shared character state vocabulary remains:

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

The Python/domain/application layers emit semantic state. Flutter maps that state to visual motion, emphasis and accessibility semantics.

## Research Foundation

Research remains a first-class part of Criterivox. Engineering prototypes are used to test feasibility and architecture, while research claims are kept separate from implementation evidence.

### Research direction

The broader research direction investigates how **context-aware intelligence and explanation can support human decision-making** rather than merely producing automated outputs.
