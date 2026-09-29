# Criterivox S5 Complete Data Runtime

## Scope

This record consolidates the S5 runtime path from browser-resident intake through Sandre stewardship, local processing, provenance, quality evaluation, synchronization, recovery, and S6 handoff.

## End-to-end path

```text
USER
  │
  ▼
Flutter / Browser
  │ explicit ingest
  ▼
Python DataFoundationStore
  │
  ├── Sandre stewardship
  ├── provenance ledger
  ├── readiness / quality gates
  ├── schema drift healer
  ├── Kaelen pipeline
  ├── semantic tagging
  ├── synthetic fixtures
  └── local ML baseline
  │
  ▼
PresentationContract / WebSocket
  │ foundation payload + state
  ▼
Browser IndexedDB
  │
  └── recovery after Python restart
          │
          ▼
      foundation_sync
          │
          ▼
  DataFoundationStore.restore_replace
          │
          ▼
  authoritative runtime mirror
```

## Residency

IndexedDB is the browser durable store for the S5 working set. Python keeps the active runtime mirror in memory. The browser therefore remains the recovery boundary for local user work.

## Provenance

Foundation state is represented through explicit source identity, provenance metadata, transformations, and temporal snapshots. Timeline Rewind reconstructs a prior recorded state rather than pretending that historical state can be inferred from the present.

## Quality and evaluation

S5 quality processing includes readiness profiling, missingness/anomaly representation, schema checks, and evaluation-driven gates. The 0.85 readiness alert remains a provisional engineering threshold until empirical validation supports a final threshold. Evaluation resources are tracked in the S5 dataset registry and are not silently copied into the repository without licensing/usage review.

## Pipeline and schema evolution

Kaelen's S5 pipeline representation is a normalized DAG. Schema drift is intercepted before downstream processing and can be healed through declarative mappings with an inspectable patch diff. This keeps transformations explicit and auditable.

## Semantic layer

The S5 semantic tagger produces machine-readable metadata, schema commentary, temporal markers, relationship constraints, and an Agent Readability Score. This is metadata preparation for downstream context work, not the S6 Context Engine itself.

## ML boundary

The current S5 ML implementation is a local scikit-learn `IsolationForest` baseline for anomaly scoring. The architecture remains progressive: deterministic logic first, classical ML where justified, and more advanced models only when evaluation evidence warrants them. Sandre and Kaelen remain ML-capable AI agents/modules, but their character identities are not themselves model definitions.

## Recovery and synchronization

`foundation_sync` is a revisioned runtime message. The server validates the serialized foundation, rejects stale revisions, accepts identical duplicates idempotently, rejects conflicting equal revisions, and can replace the active in-memory foundation when authoritative recovery is requested.

## S6 contract

S6 consumes the canonical foundation and its evidence. Context reasoning is layered above the S5 foundation. S6 must preserve the S5 provenance, confirmation, transformation, quality, and identity guarantees.

## Explicitly deferred

Multimodal vector-lakehouse ingestion is not implemented in S5. Production distributed persistence/authentication and multi-device synchronization are also outside the S5 boundary.
