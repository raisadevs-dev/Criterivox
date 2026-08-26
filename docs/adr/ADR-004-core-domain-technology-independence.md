# ADR-004: Core Domain Technology Independence

## Status

Accepted

## Date

2026-08-26

## Context

Criterivox is intended to evolve into a research-driven intelligence and decision-support system that may use multiple technologies, algorithms, AI methods, data sources, and deployment models.

Early coupling to a specific AI provider, social-media platform, database, or deployment environment could unnecessarily constrain future research and product evolution.

## Decision

Criterivox core domain concepts and business rules should remain independent of specific external technologies wherever reasonably practical.

External technologies should be accessed through appropriate application or infrastructure boundaries.

Examples include:

- AI providers
- databases
- social-media platforms
- external APIs
- deployment environments
- storage systems

## Rationale

This preserves:

- research flexibility
- testability
- maintainability
- deployment flexibility
- provider independence
- future extensibility

It also allows alternative algorithms and technologies to be evaluated experimentally without rewriting the core domain.

## Consequences

### Positive

- Easier experimentation
- Reduced vendor coupling
- Better testability
- Greater architectural flexibility

### Negative

- Some abstractions may be required
- Excessive abstraction must be avoided

## Guiding Principle

Abstractions should be introduced when they protect a meaningful architectural boundary, not merely because a future technology might exist.

## Reconsideration Conditions

This decision may be revisited when actual system requirements demonstrate that tighter coupling provides a measurable and justified benefit.