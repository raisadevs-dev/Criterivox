# ADR-003: Incremental Automated Testing

## Status

Accepted

## Date

2026-08-26

## Context

Criterivox is a research-oriented system where correctness, reproducibility, and maintainability are important.

Testing must therefore be integrated into development rather than postponed until the end of implementation.

## Decision

Criterivox will use incremental automated testing.

The project will use appropriate testing levels including:

- unit tests
- integration tests
- API tests when APIs exist
- UI tests where justified
- algorithm tests
- regression tests
- security-focused tests where appropriate

Tests will focus on meaningful behavior, edge cases, failure modes, and research-critical logic rather than pursuing an arbitrary coverage percentage.

## Rationale

Different parts of Criterivox have different correctness requirements.

For example, domain rules and algorithms require strong deterministic testing, while some visual interactions may be better validated through targeted UI tests and usability evaluation.

## Consequences

### Positive

- Earlier defect detection
- Safer refactoring
- Improved reproducibility
- Better confidence in research results

### Negative

- Development requires additional test effort
- Tests must be maintained alongside implementation

## Reconsideration Conditions

Testing tools and levels may change as the architecture and deployment model evolve.