# ADR-001: UI and Application Technology

## Status
Accepted

## Context

Criterivox requires a UI architecture capable of supporting:

- Three-layer navigation
- Bloom-based primary exploration
- Conventional fallback navigation
- Context-aware interaction
- Progressive disclosure
- Future rich visual interactions
- Future agent integration
- Python-based application development
- Clean separation between UI and application logic

## Decision

Criterivox uses a hybrid web architecture:

- Python backend
- FastAPI for the application/API boundary
- HTMX for server-driven UI interactions
- HTML/CSS/JavaScript for the interface and client-side interaction behavior

Streamlit and Gradio are retained as possible supporting technologies for
future specialized interfaces, prototypes, experiments, or components where
they provide a better fit.

They are not required to replace the current application architecture.

## Rationale

The selected architecture provides:

- Direct control over the Criterivox interface
- Support for conventional web navigation
- Support for Bloom interactions
- Separation between UI and application logic
- A clear path toward future API-driven functionality
- Flexibility for richer client-side interaction when required

## Consequences

### Positive

- Greater control over the UI than a purely framework-driven dashboard
- Clear application boundary
- Suitable foundation for contextual interaction
- Future backend/API integration remains possible

### Negative

- More frontend implementation work than Streamlit or Gradio
- Some interactions require JavaScript
- Rich visual behavior requires additional frontend development

## Deferred Evaluation

The suitability of Streamlit and Gradio for future specialized modules,
experiments, or rapid prototypes remains open.

The current decision does not prohibit their future use.

## Current Limitations

The current Bloom implementation is still prototype-level.

Contextual capability filtering exists, but deeper component-specific
Bloom transformation and rich visual/agent behavior remain future work.

## Decision Owner

Criterivox project owner

## Date

2026-08-27