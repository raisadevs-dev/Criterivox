# Vivren First-Class Capability Migration

Vivren owns the critical-reasoning inspection responsibility. S7 remains the computational reasoning bureau and stays shared with Tarkis.

## Vivren-owned surface

- critical inspection
- assumption review
- evidence-reference inspection
- contradiction review
- limitation and uncertainty exposure
- provenance tracing
- structured public reasoning summaries

Vivren does **not** own the S7 reasoning engine, persistence, graph construction, mechanism registry, or hidden reasoning. Those remain shared S7 computational infrastructure.

## Four-layer ownership

Python:
`src/criterivox/Vivren/`

Tests:
`tests/Vivren/`

Dart:
`presentation/lib/Vivren/`

Dart tests:
`presentation/test/Vivren/`

The existing S7 environment remains the authoritative analytical workspace. Vivren's dedicated Dart workspace embeds that environment with the critical-reasoning room selected.

Global character identity, visual state, navigation and S7 infrastructure remain shared.

## Truth boundary

Vivren exposes structured inspection artifacts only. It does not expose or claim access to hidden chain-of-thought. Evidence acquisition is not treated as verification, and unresolved contradictions remain visible.
