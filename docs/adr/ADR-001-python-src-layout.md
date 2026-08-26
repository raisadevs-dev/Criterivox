# ADR-001: Python Project Structure and src Layout

## Status

Accepted

## Date

2026-08-26

## Context

Criterivox is being developed as a research-driven software system requiring maintainability, testing, reproducibility, and future architectural extensibility.

The project needs a structure that separates application source code from tests, documentation, experiments, configuration, and development artifacts.

## Decision

Criterivox will use Python with a `src` package layout.

Application code will reside under:

    src/criterivox/

Tests will reside under:

    tests/

Documentation will reside under:

    docs/

Research experiments and notebooks will remain separate from production application code.

## Rationale

The `src` layout provides clearer separation between source code and repository tooling and helps prevent accidental imports caused by the repository root being placed directly on Python's import path.

The structure also supports future separation of domain, application, intelligence, infrastructure, and interface components.

## Consequences

### Positive

- Clear source-code boundaries
- Better package discipline
- Easier testing
- Supports modular architecture
- Keeps experiments separate from production code

### Negative

- Slightly more verbose imports/setup than a flat project
- Developers must understand the package structure

## Reconsideration Conditions

This decision may be revisited if the project adopts a fundamentally different runtime or packaging architecture.