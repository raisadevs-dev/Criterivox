# Criterivox S5 — Browser-First Data Residency

## Decision

Criterivox uses a browser-first/local-first residency boundary for the S5 working set.

```text
Browser / IndexedDB
      │
      │ explicit user ingest
      ▼
Python local runtime
Sandre / Kaelen processing
      │
      │ presentation contract + processed result
      ▼
Browser / IndexedDB
      │
      └── restored into the next Criterivox browser session
```

The browser-resident working set and the Criterivox browser session are treated as one user-owned local residency boundary. Python's `DataFoundationStore` remains the processing/runtime mirror for the active process, not a second durable user-data residency system.

## Storage boundary

- IndexedDB is the durable browser store for the Criterivox working-session snapshot.
- The snapshot preserves the selected intake request, Home 01 local preferences, the latest presentation state, and the active foundation identifier.
- The existing `PresentationContract` remains separate from browser presentation storage: foundation state continues to travel through explicit contract fields such as `foundation_id`, confirmation, provenance-related state, and S5 feature payloads.
- Browser presentation storage records the contract-shaped session state for restoration. It does not replace the presentation contract.
- Training consent remains explicit and defaults to `false`.
- Sensitive material is persisted locally only as part of the explicit browser working-set flow; transmission to Python still requires the existing user-triggered ingest action.

## Why IndexedDB

The project working-set target is below 200 MB. IndexedDB is therefore used instead of treating LocalStorage as the primary data store. `idb_shim` provides IndexedDB APIs across Flutter targets and supports the web implementation used by the browser presentation.

## Runtime rule

Python may process, normalize, profile, validate, and temporarily mirror the selected foundation in memory. A Python process restart must not be interpreted as durable loss of the user's browser-resident working set. The browser is the recovery boundary.

## Scope limitation

This sprint intentionally does not add multimodal vector-lakehouse infrastructure. The Home 01 vector surface stops at an embedding-ready representation marker.

## Session restoration

On runtime connection, the presentation client restores the last browser-resident `PresentationState` before live WebSocket updates arrive. A newer Python presentation contract can then replace that restored state.
