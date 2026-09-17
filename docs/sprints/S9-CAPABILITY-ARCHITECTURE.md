# CRITERIVOX — S9 Capability & Intelligence Architecture

**Status:** FINAL BACKEND / ARCHITECTURE SPRINT  
**Branch:** `s9-capability-intelligence-architecture`  
**Base:** `main`  
**Scope:** reusable computational capabilities, pipelines, execution controls, durable orchestration primitives and presentation/application boundary

## Repository inventory classification

| Area | Classification | S9 treatment |
|---|---|---|
| S5 data foundation | EXISTING / REUSABLE | Preserved. |
| S6 context | EXISTING / REUSABLE | Preserved; existing capability boundary is retained as a compatibility facade. |
| S7 reasoning | EXISTING / REUSABLE | Preserved; artifacts, branches, mechanisms and interventions remain authoritative. |
| S8 evidence/XAI | EXISTING / REUSABLE | Preserved; artifacts, provenance, verification, temporal, authorization, integrity and persistence remain authoritative. |
| Generic capability registry | MISSING | Implemented in `criterivox.capabilities.core`. |
| Generic pipeline executor | MISSING | Implemented with dependency validation and event emission. |
| Cross-cutting execution controls | PARTIAL | Consolidated in S9 without replacing S8 policy. |
| Human challenge seam | PARTIAL | Existing S7/S8 interventions retained; reusable S9 authority contract added. |
| Durable checkpoint/replay seam | PARTIAL | S9 journal persists checkpoints through the existing S8 artifact store. |
| Routing/observability seam | MISSING | S9 router, trace/span and audit primitives added. |
| S8 experimental visual environment | DEFERRED | Not revived or redesigned in S9. |
| Distributed transport/MCP | DEFERRED | No unverified production implementation invented. |

## Architecture

```text
Presentation
    ↓
Application / Use Cases
    ↓
Reusable Capabilities / Pipelines
    ↓
Ports / Adapters
    ↓
Infrastructure

Cross-cutting:
registry • events • state • provenance • integrity • checkpoints/replay
permissions • budgets • circuit breakers • retries • observability • audit
```

### Invariants

1. Homes are organizational/presentation concepts; capabilities never require a Home.
2. Characters are behavioral/presentation identities; they never own computation or authority.
3. Capabilities are reusable computational units and are character-independent.
4. Pipelines compose capabilities through explicit dependency edges; cyclic graphs are rejected.
5. Events connect work without character-to-character computational coupling.
6. S8 remains the durable artifact/event persistence boundary; S9 adds an adapter rather than a second database.
7. Artifact integrity is verified against canonical content hashes.
8. Human authority is explicit for consequential execution and intervention.
9. Checkpoints are durable artifacts and replay reconstructs them from persisted records.
10. Routing is a control-plane primitive, not a monolithic orchestrator.

## Reused S5–S8 foundations

S5 Data Foundation remains the upstream provenance-aware data source. S6 remains the reusable context layer. S7 remains the reasoning research bureau with actual reasoning artifacts, branches, mechanisms and interventions. S8 remains the evidence/XAI bureau with authoritative artifact contracts, verification, provenance, temporal state, human authority, integrity and local persistence.

The existing S6 `InternalCapabilityBoundary` is now a compatibility facade over the S9 registry. This removes a duplicate capability-registration mechanism without breaking its existing request/response contract.

The project architecture also explicitly separates civilian presentation from computation: characters represent genuine system activity but are not computational models. Handoffs are represented through events, state and artifacts rather than character-to-character computation.

## New reusable primitives

### Capability

`Capability`, `CapabilityDescriptor`, `CapabilityRegistry`, `CapabilityRequest`, `CapabilityResult`.

Descriptors carry explicit type/tag/permission/cost metadata and reject character ownership.

### Pipeline

`PipelineDefinition`, `PipelineStep`, `PipelineContext`, `PipelineExecutor`, `PipelineResult`.

Dependency validation, deterministic topological execution, completion/failure events and execution audits are implemented.

### Execution

`ExecutionContext`, `ExecutionPolicy`, `PermissionBoundary`, `ResourceBudget`, `RetryPolicy`, `CircuitBreaker`, plus bounded route-hop protection.

Machine-readable enforcement includes `BUDGET_CAP_REACHED`, `CIRCUIT_TRIPPED`, and explicit permission failures. Application state can map these to `PERMITTED_ACTION`, `HITL_APPROVAL_REQUIRED`, or `BUDGET_CAP_EXCEEDED` without coupling the core to presentation.

### Human challenge

`HumanAuthority` and `HumanChallengeState` implement actual intervention records for:

- `PREMISE_CORRECTION_REQUIRED`
- `SOCRATIC_GATE_ACTIVE`
- `CHECKPOINT_PAUSE`
- `TOOL_MISUSE_BLOCKED`
- `RESOLVED`

No character is granted authority by identity alone.

### Durable execution / observability / routing

`ExecutionJournal`, `Checkpoint`, `Trace`, `Span`, `CapabilityRouter`, and `ArtifactIntegrity` are implemented. Checkpoints are stored as S8 audit artifacts, so replay uses the existing persistence architecture.

## Foundation contracts

Where S5–S8 already provide implementations, S9 reuses them. Where a common cross-capability vocabulary was absent, S9 adds contracts for `DataProfile`, `SchemaContract`, `SchemaDriftReport`, `DataQualityGate`, `DataReadinessDecision`, `ContextFrame`, `ContextDiff`, `ContextCheckpoint`, `KnowledgeVersion`, `SkillMetadata`, `MigrationContract`, `DecisionRationale`, `ActionVector`, and `ExecutionTreeNode`.

These are contracts only. They do not falsely claim that complete ML, knowledge-graph, skill-compilation or multimodal engines exist behind every family.

## Persistence / integrity

```text
S9 execution
   ↓
S9 events / checkpoints / audits
   ↓
S8 Artifact + BureauEvent
   ↓
existing S8 SQLite / IndexedDB boundaries
```

No second S9 persistence architecture was introduced.

## Verification

`tests/test_s9_capabilities.py` covers multiple-Homes reuse, multi-capability composition, character independence, event-driven completion, persisted artifact reload, integrity mutation detection, human interruption states, permission enforcement, budget caps, circuit breaking, checkpoint replay, routing-loop protection and pipeline-cycle rejection.

The pre-existing S6 capability-boundary tests remain supported through the compatibility facade.

## Deferred

- production distributed transport/topology service;
- real external MCP/tool providers;
- production distributed tracing backend;
- universal knowledge/skill implementations beyond verified S5–S8 mechanisms;
- every-platform S9 checkpoint adapter beyond the established persistence boundaries;
- UI redesign/presentation integration;
- unsupported empirical thresholds for data quality, budgets, anomaly detection or model selection.

These are intentionally deferred, not represented by placeholders marketed as completed intelligence.
