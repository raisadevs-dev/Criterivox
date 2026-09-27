# Criterivox S8 — Set H Implementation Evidence

**Set H:** Persistence & Local Intelligence  
**Date:** 17 September 2026

Set H establishes the persistence and local-intelligence infrastructure without making the presentation layer the intelligence engine.

## Implemented

### Persistence
- Canonical JSON-compatible S8 artifact envelope.
- Shared `S8ArtifactPersistence` contract.
- Repository façade that validates artifacts before persistence.
- In-memory adapter for deterministic tests.
- IndexedDB adapter with put/get/list/clear/close.
- Native SQLite adapter through `sqflite`.
- Platform-safe SQLite boundary: native platforms use SQLite; web uses IndexedDB rather than pretending SQLite is available.

### Temporal infrastructure
- Explicit UTC occurrence timestamps.
- Optional observation timestamp and source.
- Monotonic sequence within a temporal sequencer.
- Injectable clock for deterministic testing.

### Python / local intelligence
- Versioned `criterivox.s8.local-intelligence.v1` request protocol.
- Injectable transport boundary between Flutter and Python/local computation.
- Explicit local NLP/LLM capability contract.
- Fail-closed no-model implementation.
- No character widget owns or invokes a model directly.

## Matrix mapping

| ID | Current state |
|---|---|
| TECH-02 | PARTIAL: explicit Python boundary exists; concrete Python runtime service is not included in this slice. |
| TECH-03 | PARTIAL: IndexedDB CRUD adapter exists; browser runtime verification remains. |
| TECH-04 | PARTIAL: native SQLite adapter exists; native runtime/build verification remains. |
| TECH-05 | PARTIAL: persistence repository and artifact serialization exist; full application lifecycle wiring remains. |
| TECH-06 | PARTIAL: explicit temporal infrastructure exists; full event-history integration remains. |
| TECH-07 | PARTIAL: local NLP/LLM boundary exists; capability-to-model selection and concrete model implementation remain intentionally separate. |

## Architectural invariants

1. Storage does not manufacture verification truth.
2. Web persistence remains IndexedDB-native.
3. Native persistence can use local SQLite.
4. Python computation is behind an explicit boundary.
5. Model selection follows capability requirements, not character names.
6. Missing model implementations fail closed.
7. Temporal information is data, not animation.
8. Presentation remains independent from computational implementation.

## Verification limitation

The GitHub editing environment used for this implementation does not execute the Flutter toolchain. Tests were added but are **not claimed as executed**. Browser IndexedDB and native SQLite runtime behavior still require local CI/device verification.
