# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S5 — Data Foundation + Sandre Data Stewardship is complete.** S5 established the provenance-aware data foundation, confirmation-gated stewardship workflow, Sandre working surface, and runtime integration required to carry validated material toward Dharen analysis. The Python ↔ WebSocket ↔ Flutter architecture remains intact.

**S6 — Context Intelligence is NOT YET COMPLETE.** The implementation/handoff foundation exists, including Dharen/Anuka context responsibilities, durable context state, browser-first residency, sandbox/replay, dynamic budgeting and reproducible learned-model code. The remaining S6 phase is deliberate backlog cleaning through testing, verification, ML artifact/inference evidence, evidence collection, modular/SOLID refinement and UI verification.

## S6 Direction

S6 adds an operational context layer above the S5 foundation. It structures, protects, adapts, persists, replays and hands off context while preserving S5 provenance and browser-first residency.

```text
Human Residence
      ↓
Syvax — dialogue / gateway / orchestration
      ↓
S5 DataFoundation
      ↓
S6 Context Intelligence
      ↓
Dharen — Context Master
      ↓
ContextFrame
      ├── normal flow
      └── trigger → Anuka — Context Adaptor
                    ↓
             adaptive state / fork
                    ↓
       Criterivox computational workers
                    ↓
        result / evidence / options
                    ↓
             Human Residence
```

## S5 → S6 Foundation

```text
USER MATERIAL
      ↓
SOURCE / COLLECTION INTAKE
      ↓
EXTRACTION
      ↓
CANDIDATE INFORMATION
      ↓
USER CONFIRMATION
      ↓
PROFILE / QUALITY
      ↓
NORMALIZE / PREPARE
      ↓
CANONICAL DATA
      ↓
SANDRE DATA STEWARDSHIP
      ↓
DHAREN CONTEXT INTELLIGENCE
      ↓
PROVENANCE → CONTEXT → INTERPRETATION
```

S5 preserves source identity, provenance, user confirmation, explicit missingness, anomaly flags, reproducible transformations, and canonical downstream representation. S6 consumes the **complete DataFoundation** rather than a reduced summary.

## Criterivox Civilization and Human Residence

Criterivox is represented as two connected environments:

- **Criterivox Civilization** — specialised computational workers/homes and their domain interactions.
- **Human Residence** — the human-side decision environment.

The human is not another autonomous worker. The Human Residence loop is:

```text
Goal → Data + Context → Criterivox → Decision/Options
→ Challenge → Accept/Reject → Action
→ Real-world Result → new evidence/context
```

Syvax is the gateway between these environments. Bloom is the capability-discovery/world surface. Neither is the source of authoritative S5/S6 computational state.

## Character and Interaction Boundary

- **Syvax** remains the dialogue host, interaction gateway, routing/orchestration and presentation boundary.
- **Sandre** owns Data Stewardship upstream of S6.
- **Kaelen** handles build/experimentation work and short-lived scratchpad activity.
- **Dharen** owns contextual structure, baseline framing and downstream handoff.
- **Anuka** is conditionally activated for changed requirements, evidence, hypotheses, constraints, drift, counterfactuals or downstream incompatibility.
- **Bloom** remains the capability-discovery surface rather than a duplicate work area.
- Characters are representations of computational responsibilities, not the underlying ML/model itself.
- Character conversations are independent buffers while task/context/evidence state remains shared and authoritative.

## S6 Operational Capabilities

- Dynamic context pruning and attentive compression
- Hierarchical memory structuring
- Adaptive context windowing
- Stateful context transfer across agent boundaries
- Context isolation through sandboxing
- In-context scratchpad persistence
- Context clash / poisoning prevention
- Dynamic hierarchy tiering
- Priority-tiered token budgeting
- Contextual replay and shadow testing

## Character Animation Stack

Criterivox uses a local Web 2D skeletal presentation runtime:

- **Flutter / Dart** — application presentation, semantic state transport, responsive layout and accessibility.
- **HTML + standard JavaScript** — local skeletal rendering boundary embedded through `HtmlElementView`.
- **Plain JSON skeleton data** — bones, slots, character skins/signatures and animation tracks.
- **DragonBones / Spine-style concepts** — hierarchical bones, slots/skins, animation tracks and blended state transitions.

The current renderer is an original lightweight Criterivox skeletal runtime. It is deliberately renderer-independent from the Python/domain layer and leaves a future production DragonBones or Spine adapter as a separate research/licensing decision.

## Character State Vocabulary

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

Python/domain/application layers emit semantic state. Flutter carries the contract and the local Web runtime blends the corresponding skeletal pose.

## S6 Quality and Verification Phase

The current S6 exit work is intentionally verification-first:

1. clean and verify SOLID/module boundaries;
2. expand smart unit, contract, integration and regression tests;
3. verify browser/IndexedDB → WebSocket → Python recovery and revision safety;
4. verify sandbox create/run/inspect/compare/promote/discard end-to-end;
5. run reproducible ML training and retain generated artifacts;
6. verify runtime inference using generated artifacts;
7. collect and classify learned evidence, distinguishing weak/public labels from human-validated evidence;
8. refine and verify Syvax, Bloom and Human Residence UI;
9. update final documentation/ADR/backlog status only from actual evidence.

Implementation, trained artifacts, runtime inference and CI evidence are separate claims. S6 must not be marked complete until its remaining gates pass.

## Research Foundation

Research remains a first-class part of Criterivox. Engineering prototypes are used to test feasibility and architecture, while research claims are kept separate from implementation evidence.

The current S6 research boundary explicitly distinguishes **EVIDENCE, DECISION, ASSUMPTION, HYPOTHESIS, IMPLEMENTED, FUTURE, and UNKNOWN**.

### Research direction

The broader research direction investigates how **context-aware intelligence and explanation can support human decision-making** rather than merely producing automated outputs.

## Further S6 Documentation

- `docs/sprints/S6-BACKLOG.md` — consolidated remaining S6 work and exit gates.
- `docs/architecture/S6-SOLID-MODULAR-BOUNDARIES.md` — modular/SOLID boundary decisions.
- `docs/architecture/CRITERIVOX-CIVILIZATION-HUMAN-RESIDENCE-S6.md` — Bloom/Syvax/Civilization/Human Residence relationship.
- `docs/adr/ADR-009-s6-context-human-civilization-boundary.md` — accepted architectural decision.


---

# Current Truth — Post-S6 State

> **Status snapshot for the current \`main\` branch:** Criterivox has moved beyond the S6 context foundation into an integrated **reasoning + evidence/XAI + reusable capability architecture**, with the major S7, S8, S9, frontend-completion, and character-chat work reconciled into \`main\`. This is an architecture-and-research implementation milestone, **not a claim that the entire product is finished or that every planned intelligence capability is production-complete**.

## Where We Came From

S6 established the context-intelligence foundation:

- provenance-aware S5 data remains the upstream data foundation;
- durable context state and context transfer were introduced;
- Dharen/Anuka context responsibilities were formalized;
- browser-first residency, sandbox/replay, budgeting and adaptive context mechanisms were established;
- the architecture explicitly separates implementation, learned artifacts, runtime inference and research evidence.

The important change after S6 is that Criterivox is no longer only a **data + context pipeline**. The repository now contains research and architectural layers for **reasoning, evidence/XAI, human intervention, verification, reusable capabilities, execution controls and observable orchestration**.

## S7 — Reasoning Research Bureau

**S7 reasoning architecture is implemented and integrated.**

The repository now contains:

- a dedicated Reasoning Research Bureau boundary;
- staged reasoning lifecycle and dependency graph;
- inspectable/public reasoning graph models;
- branch provenance;
- reusable reasoning and critical-thinking mechanisms;
- explicit insufficiency and intervention contracts;
- reasoning scenario fixtures and validation;
- a reasoning-bureau presentation surface.

The architectural intent is deliberate: Criterivox exposes **inspectable reasoning artifacts and structured explanations**, not hidden chain-of-thought.

S7 therefore establishes a researchable reasoning layer between context/evidence and decisions, while retaining human intervention as an explicit part of the lifecycle.

## S8 — XAI / Evidence Research Bureau

**The S8 computational and epistemic foundation is integrated. The experimental S8 visual environment is explicitly deferred for redesign.**

S8 establishes durable boundaries for:

- evidence artifacts and provenance;
- verification;
- temporal validity/invalidation;
- authorization and human intervention;
- artifact integrity and tamper detection;
- persistence and reload;
- explanation/provenance inspection;
- cross-context access controls;
- research evaluation of understanding, traceability, problem detection, challenge quality, correction traceability, uncertainty comprehension and authorization awareness.

The S8 evaluation protocol intentionally avoids inventing a universal confidence threshold. Research results are to be reported by task and dimension, with study-specific thresholds and sampling documented separately.

## S9 — Capability & Intelligence Architecture

**S9 architecture is finalized and integrated.**

S9 turns previously domain-specific mechanisms into reusable system primitives:

- capability descriptors and registry;
- reusable pipeline definitions and dependency validation;
- deterministic topological execution;
- execution policy, permissions, budgets, retries and circuit breakers;
- human-authority and challenge states;
- execution journals and checkpoints;
- trace/span and audit primitives;
- capability routing;
- artifact integrity;
- compatibility between the S6 capability boundary and the generic capability registry.

Key architectural invariants now include:

1. Homes are presentation/organizational concepts, not computational authorities.
2. Characters are behavioral/presentation identities, not independent intelligence owners.
3. Capabilities are reusable and character-independent.
4. Pipelines use explicit dependency edges and reject cycles.
5. Events connect work without character-to-character computational coupling.
6. S8 remains the durable artifact/event persistence boundary.
7. Consequential execution requires explicit human authority.
8. Checkpoints and replay use persisted records rather than fictional state.
9. Routing is a control-plane primitive rather than a monolithic character orchestrator.

S9 also explicitly leaves distributed transport/MCP, production distributed tracing, universal knowledge/skill engines and other unsupported capabilities **deferred rather than pretending they exist**.

## Character Chat and Civilization Integration

The later integration work has brought the character-chat backbone into the same \`main\` baseline.

The current architecture therefore treats the characters as **interaction surfaces over real system responsibilities**, not as separate autonomous models. The character registry, responsibility boundaries, handoff contracts, message chips, capability contracts, runtime/application integration and research/test material are part of the consolidated repository.

The full character set is represented in the registry:

\`syvax, dharen, sandre, kaelen, anuka, vivren, tarkis, pramon, bodhex, medrus, epistre, veridat, manis, viveda, anukor\`

This does **not** mean every character has an independent trained model. Characters remain presentation/routing identities over shared authoritative runtime capabilities and state.

## What \`main\` Actually Represents Now

The current architecture can be summarized as:

\`\`\`text
Human Goal / Problem
        ↓
Human Residence
        ↓
Syvax / Character Interaction Boundary
        ↓
Context + Provenance
        ↓
S7 Reasoning
        ↓
S8 Evidence / XAI / Verification
        ↓
S9 Reusable Capabilities + Pipelines
        ↓
Authorized Execution
        ↓
Result / Verification / Audit
        ↓
Knowledge / Adaptation / Future Journey
        ↓
Human Decision
\`\`\`

The repository now has substantially more than a chatbot UI. It contains a research-oriented architecture for making computational work **traceable, inspectable, challengeable, authorized and reusable**.

## What Is Still Not Truthfully Claimable

The following must **not** be described as universally complete merely because their architecture exists:

- a fully autonomous general intelligence;
- a universally trained Criterivox model;
- a production-grade distributed intelligence network;
- production MCP/external tool infrastructure;
- universal knowledge-graph or skill-learning engines;
- universal empirical thresholds for confidence, data quality or model selection;
- complete automatic integration of every S4–S8 lifecycle artifact into every runtime path;
- a finished experimental S8 visual environment;
- complete end-to-end empirical validation of the entire civilization.

Some of these have contracts, persistence models, test fixtures or architectural boundaries. That is evidence of implementation at those layers, **not evidence that the entire capability is empirically solved**.

## Current Maturity Statement

**Criterivox has progressed from a context-aware data foundation into a multi-layer research system with implemented reasoning, evidence/XAI, verification, human-authority, reusable-capability and execution architecture.**

The strongest current claim is therefore:

> **Criterivox is an implemented research prototype and evolving decision-support architecture with durable foundations for context, inspectable reasoning, evidence/XAI, verification, human challenge, reusable capabilities and controlled execution. It is not yet a universally validated autonomous intelligence system.**

That distinction is part of the project's research integrity.

## Repository Integration State

The major recent branches have been reconciled into \`main\`, including:

- S9 Capability & Intelligence Architecture;
- frontend-completion work;
- intelligence-bureau integration;
- character-chat-backbone and its Set 4 validation work.

The current \`main\` branch should therefore be treated as the **integrated baseline** for subsequent development rather than continuing feature work from the older pre-reconciliation branches.

## Immediate Research/Engineering Reality

The next work is not to invent another architectural layer for the sake of having another sprint number. The priority is to **close the gap between existing contracts and verified end-to-end behavior**:

1. broad regression and integration verification;
2. complete the remaining S4/S6–S8 partial lifecycle integrations;
3. connect the research bureaus cleanly to the current frontend and character experience;
4. verify evidence, reasoning, execution, verification and provenance as one operational journey;
5. collect empirical evaluation data rather than substituting architecture diagrams for evidence;
6. document every genuine research contribution separately from planned work.

Human decision authority remains explicit throughout this progression.
