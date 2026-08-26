# ADR-001: S1 Interface and Application Technology

- Status: Accepted
- Date: 2026-08-26
- Sprint: S1
- Scope: User-facing product shell

## Context

Criterivox requires a user-facing browser interface while preserving separation between presentation, application services, domain logic, intelligence, and infrastructure.

S1 uses controlled synthetic data and must establish a reusable foundation rather than a throwaway prototype.

The system must remain capable of evolving toward richer interaction, API-based integration, research interfaces, and future character-driven interaction.

## Requirements

The S1 technology must support:

- responsive browser interaction
- maintainable code
- separation of presentation and application logic
- future API integration
- meaningful automated testing
- local-browser deployment
- reusable UI structures
- future character-driven interaction
- future PWA/desktop evolution
- efficient development

## Options Considered

### Streamlit

Strengths:

- extremely rapid Python-based prototyping
- strong data-oriented workflows
- useful for research exploration

Limitations:

- less suitable as the primary long-term product shell
- product interaction can become tightly coupled to Python application code
- less control over the interaction model required by Criterivox

Decision:

Deferred as the primary product UI.

Potential future role:

Research and data-analysis interface.

### Gradio

Strengths:

- rapid model and intelligence demonstrations
- Python-native
- useful for experimental interfaces

Limitations:

- not ideal for the primary multi-area Criterivox workspace
- less suitable for the long-term product information architecture

Decision:

Deferred as the primary product UI.

Potential future role:

Intelligence/model experimentation interface.

### HTMX

Strengths:

- lightweight browser interaction
- server-driven UI
- minimal client-side JavaScript
- good HTML-first architecture
- strong fit with Python web applications
- supports incremental enhancement

Limitations:

- highly complex client-side interaction may eventually require additional frontend technology
- rich character animation may require a more specialized client layer in future

Decision:

Selected for the S1 browser interface.

### FastAPI

FastAPI is treated as the application/API technology rather than as a direct competitor to the presentation technologies.

Strengths:

- explicit HTTP/API boundary
- Python integration
- type-safe request/response modeling
- testability
- future API integration
- suitable foundation for application services

Decision:

Selected as the S1 application/API boundary.

## Decision

S1 will use:

- HTMX for the primary browser interaction layer
- FastAPI for the application/API boundary
- Python for application services
- controlled synthetic providers for S1 data

Target architecture:

Browser
→ HTMX
→ FastAPI
→ Application Services
→ Synthetic Provider

## Architectural Boundary

The UI must not contain business logic.

The UI requests application capabilities.

Application services coordinate use cases.

Providers supply data.

Future domain and intelligence layers will be introduced independently.

## Consequences

Positive:

- small and understandable S1 stack
- clear separation of concerns
- local-browser deployment remains straightforward
- future API integration is supported
- Python remains central to application development
- specialized Streamlit and Gradio interfaces remain possible later

Trade-offs:

- richer client-side interaction may require additional technology later
- character animation may eventually require a dedicated presentation layer
- S1 intentionally does not optimize for every future interaction requirement

## Future Evolution

Possible future architecture:

Presentation Interfaces
→ Application/API Boundary
→ Application Services
→ Domain
→ Intelligence
→ Infrastructure

Different presentation technologies may coexist where justified.

The architecture must not allow a presentation technology to become the domain or intelligence layer.

## Rejected Decision

A single framework will not be forced across all future Criterivox interfaces merely for technological uniformity.

The technology must serve the role.

## Review Trigger

Revisit this decision if future requirements introduce:

- highly interactive real-time interfaces
- complex character animation
- offline-first requirements
- large client-side state management
- PWA-specific requirements
- specialized research/model interfaces