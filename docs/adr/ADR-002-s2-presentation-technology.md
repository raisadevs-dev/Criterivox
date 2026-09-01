# ADR-002 — S2 Presentation Technology

**Status:** Accepted
**Date:** 2026-08-29
**Decision:** Flutter / Dart for the primary browser presentation layer

## Context

Criterivox S2 introduces a character-driven interaction system intended to become a core product experience rather than a decorative interface layer.

The required presentation capabilities include:

* responsive desktop-browser interaction
* responsive mobile-browser interaction
* rich animated character presentation
* 3D characters with a 2D illustrated and sprite-like visual language
* direct character interaction through mouse and touch
* persistent character presence on dedicated pages and functional areas
* context-aware Bloom interaction
* multi-agent visual participation with limited simultaneous activation
* user-to-agent-to-agent communication
* activity/timeline communication
* contextual notifications when the user is occupied elsewhere
* expressive and rich animation states
* reduced-motion support
* accessibility
* future desktop-application evolution

The existing S1 presentation implementation uses FastAPI, Jinja templates, HTML/CSS, and browser JavaScript. This implementation successfully established the initial product shell and Bloom interaction foundation.

However, extending the existing presentation approach into the full S2 character environment would increase frontend state-management, animation, interaction, and maintenance complexity.

The architectural requirement is therefore to select a presentation technology based on Criterivox's actual responsibilities rather than forcing one technology to perform every role.

## Decision

Criterivox will use **Dart + Flutter** as the primary presentation technology for the S2 browser experience.

Flutter Web will initially target:

* desktop browsers
* mobile browsers

The architecture will remain presentation-independent so that future desktop or alternative presentation technologies can be introduced without rewriting the character interaction system.

The Python application/domain/intelligence architecture remains independent of Flutter.

## Architectural Boundary

The resulting presentation boundary is:

```text
Criterivox Application
        ↓
Character / Interaction System
        ↓
Presentation Contract
        ↓
Flutter Adapter
        ↓
Flutter Web
```

The character system must not contain Flutter-specific rendering logic.

Likewise, Flutter presentation components must not contain character domain behavior or intelligence logic.

## Character Rendering Principle

Criterivox characters are conceptually 3D entities expressed through a visual language influenced by 2D illustration and sprite-based animation.

The selected presentation architecture must therefore support rich visual interaction without coupling character identity, behavior, or state to the rendering implementation.

The exact character-rendering technique remains an implementation concern and will be validated through an S2 technical spike.

## Bloom

Bloom will remain an application interaction mechanism rather than an intelligence container.

The target interaction is:

```text
User
 ↓
Bloom
 ↓
Application Action
 ↓
Application Event
 ↓
Character Interaction Layer
 ↓
Character State
 ↓
Flutter Presentation
```

The existing S1 Bloom implementation will not be discarded unnecessarily. Its interaction concepts and tests will be used as the baseline for the richer S2 Bloom implementation.

## Alternatives Considered

### Existing FastAPI + Jinja + JavaScript

**Decision:** Retain for S1 compatibility and backend/application responsibilities, but do not make it the assumed long-term character presentation architecture.

It can support rich interaction, but extending it into the complete character environment would increase manual frontend complexity.

### Streamlit

**Decision:** Not selected as the primary presentation technology.

Streamlit remains potentially useful for future analytical, research, or data-exploration surfaces, but its primary interaction model is not a strong fit for the rich persistent character environment required by S2.

### PySide6

**Decision:** Not selected as the primary presentation technology.

Its desktop capabilities are attractive, but browser-first delivery is a core product requirement.

PySide6 may be reconsidered for a future desktop-specific presentation adapter if justified.

### TypeScript-based browser frameworks

**Decision:** Not selected as the primary S2 technology at this stage.

TypeScript provides a very high browser capability ceiling, particularly for advanced visual rendering, but introduces additional frontend ecosystem complexity that is not currently justified over Flutter for the application's broader cross-platform presentation requirements.

It remains a possible future technology where a specific rendering responsibility requires it.

### Specialized 3D/game rendering technologies

**Decision:** Not selected as the primary application presentation layer.

A specialized renderer may be evaluated if the S2 character technical spike demonstrates that Flutter alone is insufficient for the required visual fidelity.

Any such renderer must remain behind the presentation boundary.

## Consequences

### Positive

* Single declarative UI model for browser presentation
* Strong responsive interaction model
* Rich animation capabilities
* Touch and pointer interaction
* Centralized presentation code
* Strong separation between behavior and presentation
* Future desktop evolution remains possible
* Bloom and character experiences can evolve beyond the S1 static shell

### Negative

* Introduces Dart/Flutter into the technology stack
* Requires learning Flutter/Dart
* Flutter Web may require additional optimization for rich visual experiences
* Advanced 3D character rendering may require a complementary rendering technique
* Existing S1 templates and browser JavaScript will require deliberate migration or coexistence during transition

## Constraints

This decision does not authorize:

* rewriting the entire application
* removing FastAPI without evidence
* moving character logic into Flutter
* introducing unnecessary frontend frameworks
* implementing the complete intelligence engine
* prematurely selecting a specialized 3D engine

## Validation

Before extensive S2 implementation, a technical spike must validate:

1. Flutter Web startup and application integration
2. responsive desktop/mobile behavior
3. rich Bloom interaction
4. direct character interaction
5. character animation-state representation
6. communication overlays
7. multiple visible characters with limited active participants
8. accessibility and reduced-motion behavior
9. integration with the existing Python application boundary
10. maintainability of the resulting architecture

The technology decision may be revisited only if implementation evidence demonstrates a significant mismatch with these requirements.

## Research Position

This decision is an engineering/design decision, not a research finding.

It does not establish that Flutter, animated characters, Bloom navigation, or character-driven interaction improves usability, trust, explainability, cognitive load, or user experience.

Those remain subjects for later evaluation.
