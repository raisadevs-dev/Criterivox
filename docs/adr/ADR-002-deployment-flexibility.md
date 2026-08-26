# ADR-002: Preserve Deployment Flexibility

## Status

Accepted

## Date

2026-08-26

## Context

Criterivox may eventually operate as a local browser application, web application, desktop application, or hybrid system.

At the current stage, the domain and persistence requirements are not mature enough to justify committing to a single deployment model.

## Decision

The core Criterivox architecture will remain deployment-agnostic during early development.

The system should preserve clean boundaries between:

- presentation
- interaction
- application services
- domain
- intelligence
- infrastructure and data

Deployment-specific concerns should not be embedded into core domain logic.

## Rationale

The research and product requirements are still evolving.

Prematurely coupling the system to a specific deployment model could create unnecessary architectural constraints and future rework.

A browser-based interface may still be used locally, similar in principle to applications such as Jupyter, without requiring a cloud deployment.

## Consequences

### Positive

- Local deployment remains possible
- Web deployment remains possible
- Desktop shells remain possible
- Future synchronization can be introduced later
- Core domain remains portable

### Negative

- Some architectural decisions may initially remain abstract
- Additional boundaries may introduce small amounts of complexity

## Reconsideration Conditions

The deployment architecture should be selected when actual requirements for persistence, authentication, synchronization, performance, privacy, and multi-device use provide sufficient evidence.