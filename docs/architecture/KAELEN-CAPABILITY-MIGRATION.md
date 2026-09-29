# Kaelen First-Class Capability Migration

**Branch:** `character-capability-bundles`

Kaelen is a first-class build/experimentation worker. The migration moves Kaelen-owned computational behavior out of the shared S5 application runtime and into `src/criterivox/Kaelen/`.

## Implemented capabilities

- Schema diff and drift detection
- Alias-based schema remapping
- Deterministic type transformation
- Reversible transformation mapping
- Declarative normalized pipeline DAG construction
- Structured pipeline handoff packages
- Event-by-event streaming ingestion with sequence checkpoints and replay rejection
- Streaming DAG execution
- Deterministic local vector encoding
- Vectorized package manifests suitable for local inspection/storage
- ML-assisted constrained schema-change planning
- Temporary Kaelen experimentation state

## Explicit boundary

The vector encoder is a deterministic feature-hash encoder. It is **not** a semantic embedding model.

The vectorized lakehouse artifact is a local inspectable package manifest. It is **not** a distributed lakehouse connector.

Streaming is bounded in-process event processing with checkpoints. It is **not** a Kafka/Flink/Spark-class distributed stream runtime.

These boundaries keep the implementation truthful while making the previously absent capability surfaces executable.

## Ownership

The following remain shared:

- provenance ledger
- foundation synchronization
- semantic tagging
- evaluation gates
- synthetic-data engine

Kaelen imports these shared mechanisms but does not own their implementation.

## Compatibility

Legacy imports from `criterivox.application.s5_advanced_runtime` and `criterivox.ml.kaelen` remain available as compatibility surfaces, while implementation ownership is now under `criterivox.Kaelen`.

## Presentation

The Level-2 pipeline construction and schema-drift rooms are now marked functionally implemented. Multimodal vector/lakehouse ingestion remains planned because the migrated implementation is deliberately tabular/local rather than pretending to provide multimodal distributed infrastructure.
