# Criterivox S7 — Repository / Architecture Gap Assessment

**Baseline:** `main` at `ff1fa840c72ed31b85a226fc6e743699f94140b1`  
**Implementation branch:** `reasoning-research-bureau` (created from `intelligence-bureau`, itself created from `main`)  
**Status:** implementation started; this assessment records repository reality before substantial S7 expansion.

## Documented S7 requirement → repository reality → status → action

| Requirement | Repository reality | Status | Implementation action |
|---|---|---|---|
| Independent S7 computational boundary | Existing Python application/domain/application layers are shared with S5/S6; no S7 package existed | MISSING | Add isolated `src/criterivox/s7` package and API boundary. |
| Artifact + Event + State information model | Existing domain has immutable `DomainEvent`; S6 has durable context/provenance concepts; no S7 analytical artifact/version model | PARTIAL | Add S7-owned immutable artifacts, events and session state without replacing S6 models. |
| Dynamic capability decomposition | Existing `AnalysisTaskService` is largely a fixed deterministic analysis lifecycle | PARTIAL | Add S7 capability planning and mechanism selection above mechanisms, without routing through Syvax. |
| Multiple mechanisms, no monolithic intelligence engine | Existing code contains several application services and S6 mechanisms | MATCH/PARTIAL | Compose specialized S7 mechanisms under Bureau orchestration. |
| Reuse → integrate → invent | Existing domain semantics and presentation contracts are reusable | MATCH | Reuse stable primitives; mark S7 mechanisms as EXISTING/COMPOSED/NEWLY_DESIGNED. |
| Human challenge has computational consequence | S6/Home03 has intervention/steering primitives; no S7 artifact-targeted challenge flow | MISSING | Add S7 challenge event + new branch/continuation. |
| Branching/versioning | Home03 has conversation branches/checkpoints, but not S7 analytical artifact lineage | PARTIAL | Keep existing system intact; add S7 branch/version lineage. |
| Insufficient-information handling | Existing S6 semantics explicitly preserve unknown/missing states | MATCH/PARTIAL | Reuse semantic principle; S7 gates analysis before result creation. |
| Provenance | Existing S5/S6 provenance graph and research semantics exist | PARTIAL | S7 artifacts carry parent lineage and mechanism provenance. |
| Syvax independence | Syvax is deeply integrated into current Home03 routes and shell, but is not required by new S7 package | CONSTRAINT | S7 API imports only S7 modules; presentation will call `/api/s7`, not Syvax. |
| Flutter character presentation | Existing `CharacterPresentation`, `PresentationState`, visual-state and animation infrastructure exists | MATCH/PARTIAL | Extend via S7-derived presentation projection; do not move computation into characters. |
| Exactly three S7 rooms | Current shell has generic pages/placeholders and Home03; no S7 three-room surface | MISSING | Add dedicated S7 Collaboration, Vivren and Tarkis room navigation. |
| Collaboration Room is landing environment | No S7 landing exists | MISSING | Make `/intelligence` open the Collaboration Room. |
| Cinematic, state-grounded UI | Existing Flutter has theme, animation and character infrastructure; S7-specific environment absent | PARTIAL | Build S7 visual surface from authoritative API state. |
| S7 standalone operation | Existing launcher starts one Python runtime + Flutter; S7 has no standalone endpoint | PARTIAL | S7 API is independently callable within the local runtime and does not import Syvax. |
| No fabricated evidence/metrics | Existing research semantics reject unsupported confidence without method | MATCH | Keep empirical values UNKNOWN unless measured. |

## Important repository conflict discovered

`src/criterivox/ui/routes.py` on the current baseline contains unresolved Git conflict markers (`<<<<<<< HEAD`, `=======`, `>>>>>>> origin/main`) inside the committed file. This is a pre-existing repository defect on `main`, not an S7 design decision. It must be resolved before treating the full application runtime as a clean acceptance baseline. S7 implementation must not silently redefine that unrelated conflict.

## Existing useful foundations

- `DomainEvent` is immutable and already provides a common event primitive.
- `research_semantics.py` already models unresolved status, validation state, missingness and traceability constraints.
- S6 provides context, provenance, browser-first persistence concepts and sandbox/replay semantics.
- Flutter already has `CharacterPresentation`, `PresentationState`, character visual state and animation infrastructure.
- `start-criterivox.ps1` provides the established local Python + Flutter runtime boundary.

## S7-specific gap

The largest architectural gap is not UI. It is the absence of a genuine S7 analytical state model and orchestrator that can produce inspectable reasoning/hypothesis/evaluation artifacts and react to human intervention. That is the first implementation priority.

## Evidence boundary

The repository contains S5/S6 research and implementation evidence, but the supplied S7 files do not provide experimental benchmarks for the new reasoning mechanisms. Therefore this implementation uses bounded deterministic mechanisms and records limitations rather than inventing performance claims.
