# Tarkis First-Class Capability Migration

Tarkis owns bounded hypothesis exploration.

## Owned responsibility

- hypothesis variation from supplied material
- competing hypothesis comparison
- bounded counterfactual/scenario exploration
- branch exploration
- challenge-driven exploration/revision

## Shared S7 computation

The S7 reasoning bureau remains the computational engine. Tarkis wraps the existing hypothesis mechanism and exposes character-owned exploration artifacts. S7 models, persistence, artifact lineage, orchestration, and mechanism registry remain shared.

## Truth boundary

Tarkis generates candidates, not externally established facts. Candidate evidence status remains explicit. Counterfactual work is bounded by a supplied causal model/intervention and does not infer effects beyond that model.

## Four-layer ownership

Python: `src/criterivox/Tarkis/`
Tests: `tests/Tarkis/`
Dart: `presentation/lib/Tarkis/`
Dart tests: `presentation/test/Tarkis/`

The existing S7 environment is reused as the authoritative workspace, with Tarkis selected as the Hypothesis Exploration Chamber.
