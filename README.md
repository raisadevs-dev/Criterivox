# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S5 — Data Foundation + Sandre Data Stewardship is complete.** S5 established the provenance-aware data foundation, confirmation-gated stewardship workflow, Sandre working surface, and the runtime integration required to carry validated material toward Dharen analysis. The Python ↔ WebSocket ↔ Flutter architecture remains intact.

## Current Sprint

**S6 — Context Engine**

S6 adds a traceable context layer above the S5 foundation: provenance graph, structural context diff, evidence-completeness/debt indicator, configurable recheck-aware context memory, agent observability, controlled handoff fields, and a protocol-neutral capability boundary.

## S5 → S6 Foundation

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
DHAREN CONTEXT ENGINE
      ↓
PROVENANCE → CONTEXT → INTERPRETATION
```

S5 preserves source identity, provenance, user confirmation, explicit missingness, anomaly flags, reproducible transformations, and canonical downstream representation. Research-specific semantics remain evidence-gated and are not invented by engineering.

## Character and Interaction Boundary

- **Syvax** remains the dialogue host.
- **Sandre** owns Data Stewardship and participates in an independent character conversation.
- **Dharen** owns contextual structure and downstream handoff.
- **Anuka** is conditionally activated for changed requirements or failed hypotheses.
- **Kaelen** handles build/experimentation work and short-lived scratchpad state.
- **Vivren** challenges interpretation and reasoning.
- **Tarkis** works with questions, hypotheses and alternative explanations.
- Character conversations are independent buffers while task/context/evidence state remains shared and authoritative.
- **Bloom** remains the capability-discovery surface rather than a duplicate work area.

## Character Animation Stack

Criterivox uses a local Web 2D skeletal presentation runtime:

- **Flutter / Dart** — application presentation, semantic state transport, responsive layout and accessibility.
- **HTML + standard JavaScript** — local skeletal rendering boundary embedded through `HtmlElementView`.
- **Plain JSON skeleton data** — bones, slots, character skins/signatures and animation tracks.
- **DragonBones / Spine-style concepts** — hierarchical bones, slots/skins, animation tracks and blended state transitions.

The current renderer is an original lightweight Criterivox skeletal runtime. It is deliberately renderer-independent from the Python/domain layer and leaves a future production DragonBones or Spine adapter as a separate research/licensing decision.

```text
Character reference / design
      ↓
2D bone + slot data
      ↓
JSON skeleton + animation tracks
      ↓
local HTML + JavaScript runtime
      ↓
Flutter Web embedding boundary
      ↓
semantic character state rendered as motion
```

The old SVG character system is no longer part of the current S6 presentation architecture.

## Character State Vocabulary

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

Python/domain/application layers emit semantic state. Flutter carries the contract and the local Web runtime blends the corresponding skeletal pose.

## Research Foundation

Research remains a first-class part of Criterivox. Engineering prototypes are used to test feasibility and architecture, while research claims are kept separate from implementation evidence.

The current S6 research boundary explicitly distinguishes **EVIDENCE, DECISION, ASSUMPTION, HYPOTHESIS, IMPLEMENTED, FUTURE, and UNKNOWN**.

### Research direction

The broader research direction investigates how **context-aware intelligence and explanation can support human decision-making** rather than merely producing automated outputs.
