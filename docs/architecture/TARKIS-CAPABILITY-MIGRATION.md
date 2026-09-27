# Tarkis First-Class Capability Migration

Tarkis owns hypothesis exploration over the shared S7 reasoning bureau.

## Tarkis-owned responsibility

- bounded hypothesis generation
- competing-hypothesis comparison
- supplied-context support review
- supplied-context conflict review
- counterfactual exploration
- hypothesis-basis/provenance tracing
- explicit unestablished status

## Shared S7 mechanisms

The following remain shared:

- AnalysisSession
- ArtifactKind and artifact persistence
- reasoning mechanisms
- hypothesis generation mechanism
- hypothesis comparison mechanism
- reasoning pipeline
- S7 orchestrator
- graph and persistence
- S7 API and environment

Tarkis is a character-owned facade over those mechanisms. This prevents the S7 reasoning engine from being duplicated inside the character package.

## Vivren boundary

Vivren inspects reasoning and exposes critical findings, assumptions, contradictions, limitations and provenance.

Tarkis explores alternatives and compares hypotheses.

`Tarkis → hypothesis exploration → S7 artifacts → Vivren inspection`

## Dart

`presentation/lib/Tarkis/` owns Tarkis-specific capability presentation. The existing S7 environment remains the authoritative workspace and is opened with the Tarkis room selected.

## Truth boundary

Generated candidates are explicitly marked as not established. Comparison only uses supplied context. A hypothesis is never presented as an externally verified fact merely because Tarkis generated it.
