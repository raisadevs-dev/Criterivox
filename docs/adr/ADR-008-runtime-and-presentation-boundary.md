# ADR-008: S5 Runtime and Presentation Boundary

- **Status:** Accepted
- **Date:** 2026-09-10
- **Sprint:** S5
- **Scope:** Sandre runtime participation, Python-to-Flutter state propagation, character identity, and workspace presentation

## Context

S5 extends the existing Python → WebSocket → Dart presentation path with Sandre stewardship state and contextual workspace navigation. Character identity and semantic state must remain authoritative at the application/runtime boundary. Flutter must render the received semantic state rather than invent application behavior.

S5 also requires Sandre stewardship to remain distinct from Dharen's analysis workspace and from the Bloom capability-discovery surface.

## Decision

Python remains authoritative for semantic character state. Runtime presentation contracts carry canonical character identifiers, task/foundation information, stewardship state, and contextual door addresses to Flutter.

Character identifiers crossing the presentation boundary are canonicalized to the registry representation so the runtime cannot reject a valid character solely because of casing.

Sandre owns the Data Stewardship workspace and may participate in an independent Sandre chat surface. Dharen owns the Analysis Workspace. Bloom remains the capability-discovery surface and does not duplicate Sandre's working controls.

The existing runtime architecture is extended rather than replaced. S5 does not make Flutter the source of truth for character state.

## Consequences

- Runtime character events remain renderer-independent.
- Sandre and Dharen have distinct functional surfaces.
- Workspace routing can follow application-generated contextual addresses.
- Character identity validation is consistent at the presentation boundary.
- Existing S2/S3/S4 runtime architecture remains intact.

## Rejected Alternatives

- Using the most recently emitted character state as the universal workspace state.
- Rendering Sandre in Dharen's Analysis Workspace.
- Duplicating Sandre stewardship controls inside Bloom.
- Allowing Flutter to invent or override semantic character state.

## Traceability

This decision extends the S5 architecture documentation and preserves the S2/S3/S4 runtime boundary and character-state decisions.
