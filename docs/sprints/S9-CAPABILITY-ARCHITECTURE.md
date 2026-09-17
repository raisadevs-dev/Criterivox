# CRITERIVOX — S9 Capability & Intelligence Architecture

**Status:** FINAL BACKEND / ARCHITECTURE SPRINT  
**Branch:** `s9-capability-intelligence-architecture`  
**Base:** `main`  
**Scope:** reusable computational capabilities, pipelines, execution controls, durable orchestration primitives and presentation/application boundary

## Architectural result

S9 consolidates the reusable backend seam needed by S1–S8 without turning Homes, characters, Syvax or Bloom into computational services.

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

### Core invariants

1. **Homes are presentation/organizational concepts.** A capability never requires a Home.
2. **Characters are behavioral/presentation identities.** They never own computation or authority.
3. **Capabilities are reusable computational units.** They can be consumed by multiple Homes/workflows.
4. **Pipelines compose capabilities through explicit dependencies.** Cycles are rejected.
5. **Events connect work without character-to-character computational coupling.**
6. **S8 remains the durable artifact/event persistence boundary.** S9 uses an adapter over the existing S8 SQLite store rather than introducing a second database architecture.
7. **Integrity is content-hash based.** Mutated payloads fail verification.
8. **Human authority is explicit.** Presentation cannot silently grant consequential execution authority.
9. **Checkpoints are durable artifacts and replay is reconstructed from those artifacts.**
10. **Routing is a decision boundary, not an orchestration monolith.**

## Reused S5–S8 foundations

- S5 Data Foundation and provenance-aware stewardship remain the data source of truth.
- S6 context contracts and browser-first/durable context architecture remain reusable context foundations.
- S7 reasoning artifacts, branches, interventions, critical inspection and hypothesis exploration remain intact.
- S8 artifact contracts, provenance, verification, contradiction/uncertainty, human authority, temporal infrastructure, integrity and SQLite/IndexedDB persistence remain intact.
- The S6 `InternalCapabilityBoundary` is now a compatibility facade over the S9 `CapabilityRegistry`, avoiding a second capability-registration mechanism.

The project materials explicitly establish that civilians represent real computational activity rather than being the computational engines themselves, and that handoff should be expressed through computational events/state/artifacts rather than character-to-character computational dependency. fileciteturn1file10

## New reusable primitives implemented

### Capability system

- `Capability`
- `CapabilityDescriptor`
- `CapabilityRegistry`
- `CapabilityRequest`
- `CapabilityResult`

Descriptors reject character ownership and carry explicit input/output types, tags, permission requirements and estimated cost.

### Pipeline system

- `PipelineDefinition`
- `PipelineStep`
- `PipelineContext`
- `PipelineExecutor`
- `PipelineResult`

Dependency validation, deterministic topological execution, completion/failure events and execution audits are included.

### Execution controls

- `ExecutionContext`
- `ExecutionPolicy`
- `PermissionBoundary`
- `ResourceBudget`
- `RetryPolicy`
- `CircuitBreaker`
- bounded route-hop protection

Machine-readable states include `BUDGET_CAP_REACHED`, `CIRCUIT_TRIPPED` and explicit permission failures. `PERMITTED_ACTION`, `HITL_APPROVAL_REQUIRED`, and `BUDGET_CAP_EXCEEDED` remain application-level vocabulary that can be mapped onto these primitives without coupling them to a character or UI.

### Human challenge

`HumanAuthority` records explicit challenges and supports:

- premise correction
- Socratic gates
- checkpoint pauses
- tool-misuse blocking
- resolution by the authorizing human

States include:

`PREMISE_CORRECTION_REQUIRED`  
`SOCRATIC_GATE_ACTIVE`  
`CHECKPOINT_PAUSE`  
`TOOL_MISUSE_BLOCKED`

The capability records the intervention as an event. It does not simulate intelligence theatrics.

### Durable execution / routing / observability

- `ExecutionJournal`
- `Checkpoint`
- `Trace`
- `Span`
- `CapabilityRouter`
- `ArtifactIntegrity`

Checkpoints are persisted as authoritative S8 audit artifacts. Replay reads those artifacts back after a new process/store instance is opened.

## Capability-family boundary

S9 does not invent fake implementations for every future capability family. Existing S5–S8 implementations are the reusable mechanisms for data, context, evidence, reasoning and XAI. S9 supplies the composition and control plane needed to reuse them.

The package adds explicit contracts for future data/context/knowledge/planning objects (`DataProfile`, `SchemaContract`, `SchemaDriftReport`, `DataQualityGate`, `ContextFrame`, `ContextDiff`, `ContextCheckpoint`, `KnowledgeVersion`, `SkillMetadata`, `MigrationContract`, `DecisionRationale`, `ActionVector`, `ExecutionTreeNode`) where those concepts are not yet consolidated into a common S9 execution seam. These are contracts, not claims that a complete production model exists behind every one.

## Syvax / Anukor boundary

Syvax remains the interaction boundary: intent reception, human-facing adaptation, HITL steering and ingress.

Anukor remains an internal adaptive transport/control-plane concept. The S9 router and event bus provide reusable primitives without making either character a computational monolith.

Bloom remains a presentation/read-model consumer. It does not own provenance, telemetry, budgets, checkpoints, topology, HITL state or routing.

## Persistence model

```text
S9 capability/pipeline execution
        ↓
S9 event + checkpoint/audit objects
        ↓
S8 Artifact / BureauEvent contract
        ↓
Existing S8 SQLite store
        ↕
Existing browser IndexedDB boundary where applicable
```

No second S9 database was introduced.

## Verification evidence

The S9 architecture test suite covers:

- multiple Homes consuming one capability
- composition of multiple capabilities in one pipeline
- character independence
- event-driven capability completion
- durable artifact reload
- integrity mutation detection
- human challenge/interruption states
- permission enforcement
- budget caps
- circuit breaking
- checkpoint replay
- routing loop protection
- pipeline cycle rejection

The legacy S6 capability-boundary tests remain valid through the compatibility facade.

## Intentionally deferred

- Production distributed transport and topology service
- Real external MCP/tool providers
- Full distributed tracing backend
- Universal data/knowledge/skill implementations beyond the existing S5–S8 mechanisms
- Web IndexedDB adapter migration of every S9 checkpoint consumer
- UI redesign/integration
- Any unsupported empirical thresholds for budgets, quality, anomaly detection or model selection

These are explicitly deferred rather than represented by fake implementations.

## Final architecture map

```text
                    HUMAN
                      │
               Syvax / Presentation
                      │
              Application Commands
                      │
        ┌─────────────┴─────────────┐
        │      Capability Registry  │
        └─────────────┬─────────────┘
                      │
              Pipeline Executor
                      │
       ┌──────────────┼──────────────┐
       │              │              │
    Context        Reasoning      Evidence/XAI
       │              │              │
       └──────────────┼──────────────┘
                      │
              Events / Artifacts
                      │
       ┌──────────────┼──────────────┐
       │              │              │
   Permissions     Budgets       Integrity
       │              │              │
       └──────────────┼──────────────┘
                      │
              Checkpoints / Replay
                      │
               S8 persistence
                      │
               SQLite / IndexedDB
```

S9 therefore leaves Criterivox with a reusable backend composition layer while preserving the architectural separation established by the earlier sprints. fileciteturn1file13
