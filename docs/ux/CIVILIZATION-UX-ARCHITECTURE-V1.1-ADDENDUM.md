# Criterivox Civilization UX Architecture — v1.1 Addendum

**Status:** LOCKED — DOCUMENTATION COMPLETE FOR CURRENT CIVILIZATION + HUMAN RESIDENCE UX BASELINE  
**Branch:** `main`  
**Date:** 2026-09-18  
**Parent document:** `docs/ux/GATE1-GATE2-CIVILIZATION-UX-ARCHITECTURE.md`  
**Scope:** Home 01, Home 02, Home 04–08, Anukor, Private Room, Collaboration Room, Guest Pass, Gate 2 research loop

## 1. Purpose

This addendum completes the pending documentation layer for the Criterivox civilization UX architecture. It records the detailed Home 01/Home 02 specifications and the finalized Gate 2 human-facing rooms discussed after the original Gate 1/Gate 2 baseline.

This document is a **UX and architecture specification**, not a claim that every described mechanism is already implemented. The implementation-truthfulness rule from the parent document remains binding.

The core separation remains:

```text
Civilization UX
    ↓
Characters + Homes + Bloom + Syvax + Human Residence
    ↓
Presentation / Read Models / Interaction Boundaries
    ↓
S1–S9 reusable architecture
    ↓
Capabilities + Pipelines + Events + State + Provenance
+ Checkpoints + Permissions + Budgets + Human Authority
```

Homes and characters organize and explain work. They do not become independent orchestration engines merely because the UX represents them as intelligent residents.

---

# 2. Home 01 — Sandre's Data Foundation Home

**Residents:** Sandre — Data Steward; Kaelen — Data Builder  
**Primary focus:** data stewardship, storage, quality, ingestion, transformation, and infrastructure pipelines.

### Core question

> Can this data be trusted and understood enough to enter the intelligence workflow?

### Sandre — Data Steward

Sandre represents data quality and stewardship responsibilities:

- quality validation
- privacy masking and sanitization
- anomaly filtering
- semantic enrichment
- metadata and lineage preparation
- data-quality checks
- context annotation
- verified payload handoff

Sandre's output is a quality-qualified data state, not a declaration that the underlying real-world information is universally true.

### Kaelen — Data Builder

Kaelen represents preparation and transformation responsibilities:

- schema transformation
- structured or streaming ingestion
- DAG construction
- schema-drift remediation
- supported vector encoding
- lakehouse/package preparation
- schema remapping

Kaelen does not own the global pipeline engine. Actual execution remains within the reusable capability and pipeline architecture.

### Home 01 flow

```text
INGEST
  ↓
PROFILE
  ↓
VALIDATE
  ↓
SANITIZE
  ↓
ANNOTATE
  ↓
TRANSFORM
  ↓
EVALUATE
  ↓
PACKAGE
  ↓
HANDOFF
```

### Dynamic Data Readiness Profiling

The UI may expose:

- completeness
- schema alignment
- anomaly indicators
- validation status
- semantic readiness
- downstream compatibility

Readiness thresholds must come from actual validation or execution policy. A decorative fixed percentage must not be presented as measured data quality.

### Schema Drift Interceptor

The intended inspectable flow is:

```text
OLD SCHEMA
    ↓
DRIFT DETECTED
    ↓
PATCH / MAPPING PROPOSAL
    ↓
VALIDATION
    ↓
ACCEPTED / REJECTED
    ↓
NEW SCHEMA
```

“Self-healing” means an authorized transformation proposal or application. It does not mean the character can rewrite the architecture or bypass governance.

### Epistemic Data Lineage & Provenance Ledger

Home 01 may inspect provenance and lineage exposed by the underlying S8/S9 artifact, event, and provenance infrastructure. It must not create a duplicate authoritative provenance database merely for the UI.

### Synthetic Data Laboratory & Edge Caching

Synthetic test data must remain visibly distinct from real research or user data.

```text
REAL DATA        ≠        SYNTHETIC TEST DATA
```

A generator remains pluggable unless an actual generator is implemented.

### Context Engineering & Semantic Tagging

The Semantic Inspector may expose:

- definition
- type
- temporal scope
- source
- ambiguity notes
- downstream use
- traceability
- semantic relationships

An “Agent Readability Score” is a valid UI concept only when an actual evaluator produces the score.

### Multimodal / Vector Lakehouse Ingestion

The intended abstraction is:

```text
Raw Artifact
   ↓
Ingestion Capability
   ↓
Modality
   ↓
Derived Representation
   ↓
Indexed / Searchable Artifact
```

This remains pluggable/future-capable unless the corresponding infrastructure is implemented.

### Evaluation-Driven Data Quality Gates

The inspection view should expose, where available:

- failed checks
- violated constraints
- affected fields
- evidence
- remediation
- resulting readiness

---

# 3. Home 02 — Dharen's Context Home

**Residents:** Dharen — Context Master / Scope Boundary Control; Anuka — Context Adaptor / Situational Management  
**Primary focus:** problem framing, context structuring, scope control, adaptation, and situational management.

### Core question

> What is the correct frame and boundary for this problem?

### Dharen — Context Master

Dharen represents:

- problem framing
- scope boundaries
- context hierarchy
- compression and pruning
- priority handling
- clash resolution
- validated context-frame construction

### Anuka — Context Adaptor

Anuka represents:

- context drift detection
- adaptation
- state differences
- counterfactual branches
- sandboxed isolation
- working scratchpad
- checkpoint continuity

Anuka is not the same architectural role as Anukor. **Anuka is a Home 02 resident concerned with contextual adaptation; Anukor is the roaming network/control-plane resident.**

### Home 02 flow

```text
RAW INPUT
  ↓
SCOPE
  ↓
STRUCTURE
  ↓
PRIORITIZE
  ↓
COMPRESS
  ↓
CHECK CLASHES
  ↓
ISOLATE
  ↓
ADAPT
  ↓
CHECKPOINT
  ↓
CONTEXT FRAME
```

### Dynamic Context Pruning

The UI may expose:

- original context
- compressed context
- retained information
- removed information
- rationale for removal

Compression must remain inspectable rather than becoming invisible information loss.

### Adaptive Context Shift Interceptor

The intended inspection view is:

```text
OLD CONTEXT
    ↓
CHANGE DETECTED
    ↓
VARIABLE / CONSTRAINT DIFF
    ↓
AFFECTED REASONING
    ↓
DOWNSTREAM REFRESH
```

### Hierarchical Context Tree

The tree distinguishes:

- Global Goal
- Domain
- Hard Constraints
- Soft Guidelines
- Environment

Where supported, nodes should expose origin, confidence, timestamp, source, scope, and dependencies.

### Context Branch / Shadow Testing

Context branches are represented as reusable execution/state capabilities. The character does not own the branch engine.

### Context Clash & Poisoning Firewall

The Context Sanity Matrix may expose:

- conflicting claims or constraints
- source
- scope
- contradiction type
- warning
- proposed resolution

### Isolated Execution Sandbox

A sandbox view may expose:

- state boundary
- inputs
- outputs
- isolation state
- discard/reuse rules

Actual isolation must be backed by the underlying execution capability.

### Scratchpad vs Checkpoint

The distinction is locked:

- **Scratchpad:** current working state.
- **Checkpoint:** durable recoverable state.

Neither requires exposing private chain-of-thought. The UX should expose structured state, decisions, assumptions, artifacts, or other inspectable records that the architecture actually persists.

### Priority-Tiered Token / Resource Budgeting

The UI may represent:

- Critical
- High
- Medium
- Low

Any budget-changing control must invoke the actual execution-policy boundary.

---

# 4. Home 01 ↔ Home 02 Handoff

The primary conceptual handoff is:

```text
HOME 01 — SANDRE / KAELEN
“What is this data?”
        ↓
Validated / prepared data
        ↓
HOME 02 — DHAREN / ANUKA
“What does it mean here?”
        ↓
Downstream intelligence
```

Context-change loop:

```text
Human / Syvax
    ↓
Anuka detects contextual change
    ↓
Dharen recalculates frame
    ↓
Unchanged data / newly required data
    ↓
Home 01
```

The actual handoff is implemented through underlying artifacts, events, state, capabilities, and pipeline execution rather than direct character-owned computation.

---

# 5. Home 04 — Vivren's Intelligence Home

**Residents:** Vivren and Tarkis  
**Primary focus:** critical reasoning, adversarial hypothesis testing, fallacy detection, and epistemic rigor.

The documented capability set includes:

1. Adversarial Debate Engine / Vivren–Tarkis Arena
2. Logical Fallacy & Assumption Detector
3. Test-Time Compute Dial / search expansion
4. Hypothesis Backtracking
5. Counterfactual What-If Matrix
6. Formal Logic Translator
7. Step-Level Process Reward Supervision
8. Epistemic Boundary & Honest Refusal Valve
9. MCTS Hypothesis Visualizer
10. Self-Correction / Reflexion Ledger
11. Zero-Trust Inter-Agent Handoff Verification
12. Goal Drift & Semantic Anchor Radar
13. Formal Pydantic/JSON Schema Compiler
14. Disagreement & Conflict Escalation Ledger

Numerical values such as an “85% alignment” threshold remain examples/configuration candidates unless an actual evaluated policy establishes them.

Reasoning inspection must use structured reasoning artifacts, hypotheses, critiques, branches, assumptions, and audit records rather than requiring exposure of private chain-of-thought.

---

# 6. Home 05 — Pramon's Planning & Decision Home

**Residents:** Pramon and Bodhex  
**Primary focus:** empirical proof, actionable planning, trade-off deliberation, decision rationale, and execution readiness.

The documented capability set includes:

1. Pareto Trade-Off Optimization
2. Executable Perception & Action Vector Synthesizer
3. Dynamic Contingency / Self-Healing Execution Tree
4. Empirical Evidence Strength Evaluator
5. Audit-Ready Decision Rationale
6. Cross-Home Research Ping
7. Blast-Radius Guardrail / Tool Sandboxing
8. Isolated Context Summary Handoff
9. DAG Task Dependency Mapper
10. Real-Time Token/API Rate Throttler
11. Agentic FinOps Cost Guardrail
12. MCP Standardized Tool Adapter
13. Durable Execution Replay / Time-Travel Debugger
14. Automatic Tool Circuit Breaker

Bodhex does not own global MCP infrastructure or global budget policy. Pramon does not bypass S9 permission, budget, checkpoint, circuit-breaker, or human-authority boundaries.

---

# 7. Home 06 — Medrus / Epistre / Veridat Evidence Bureau

**Primary focus:** empirical verification, knowledge retention, cryptographic provenance, and historical retrieval.

The documented feature family includes:

- Grounded Evidence Matrix / Fact Checking
- Epistemic Provenance & Audit Trail
- Temporal Knowledge Graph / Retention Store
- Contradiction Interceptor
- Cryptographic Execution Receipts & Artifact Vault
- Cross-Household Truth Ping
- Bi-Temporal Fact Invalidation
- Dual Engine RAG vs Semantic Compiler
- Provenance Dossier
- Background Memory Consolidation
- Adversarial Memory Poisoning Firewall
- Zero-Trust Tenant Context Isolation
- Semantic Entropy Monitor
- Citation-Linked Line-Level Attribution

Medrus, Epistre, and Veridat are character representations of evidence and knowledge responsibilities. They do not own an independent provenance database outside the S8/S9 architecture.

Confidence thresholds such as `>95%` are examples unless an actual evaluated mechanism establishes them.

---

# 8. Home 07 — Manis's Human Challenge Home

**Primary focus:** human assumption stress-testing, cognitive friction, red-teaming unconscious bias, and operational counter-balancing.

### Key capabilities

1. Unstated Assumption Stress-Tester
2. Human Intent Realignment Engine
3. Socratic Friction Gate / HITL Interceptor
4. Anti-Dogma Knowledge Audit
5. Anti-Sycophancy Policy Engine
6. Multi-Turn Adversarial Drift Simulator
7. Automation Bias Interrupter
8. Rule Generalization Stress-Tester
9. Crew Resource Management Challenge Protocol
10. SME Human Metric Alignment Engine
11. Agentic Tool Misuse & Scope Expansion Scanner
12. Automation Complacency Breaker

Manis may challenge, escalate, and surface disagreement. Manis does **not** become the ultimate authority over the human. S9 `HumanAuthority` remains the actual authority boundary.

“Human intent” is a candidate interpretation that can be challenged or clarified. It is not magical access to an unobservable inner state.

Behavioral metrics such as vigilance scores or alignment deltas require careful research interpretation, privacy safeguards, and appropriate consent. They must not silently become judgments about a person's character or worth.

---

# 9. Home 08 — Viveda's Knowledge Home

**Primary focus:** knowledge synthesis, generalized schema formation, dynamic ontology distillation, and transfer learning.

### Key capabilities

1. Inductive Trajectory Distiller
2. Generative Ontology & Dynamic Schema Weaver
3. Cross-Domain Transfer Learning Engine
4. Epistemic Boundary Refiner
5. Skill-Library Compiler
6. Autonomous Memory Pruning & Utility Evaluation
7. Progressive Disclosure Skill Compiler / `SKILL.md` Package Weaver
8. Dynamic Graph-RAG & Ontology Mutation Engine
9. Neuro-Symbolic Schema Compiler
10. Automated Heuristic Decay & Active Memory Pruning
11. MemSync Cross-Session Persistence Engine
12. Hierarchical Skill Taxonomy Weaver
13. Reflection-Driven Policy Synthesizer
14. Ontological Schema Version Control & Migration

The conceptual loop is:

```text
Medrus / Evidence
      ↓
Viveda / Abstraction
      ↓
Manis / Challenge
      ↓
Refined Knowledge
```

Repeated observation must not automatically become universal truth. Knowledge outputs require evidence, scope, uncertainty, validation, and epistemic state.

“Permanent intelligence,” autonomous skill compilation, autonomous forgetting, and policy synthesis remain qualified derived capabilities unless implemented and validated.

---

# 10. Anukor — Network Resident Without a Home

Anukor remains a roaming network/control-plane representation rather than a conventional Home resident.

### Primary responsibilities

- dynamic task routing
- cross-household context movement
- loop/deadlock interruption
- load balancing
- event-driven dispatch
- topology representation
- transport/control-plane observability

### Documented capabilities

1. Intent-Based Dynamic Network Router
2. Cross-Household Context Tunnelling
3. Circuit Breaker & Loop Interceptor
4. Relational Edge Weight Decay Engine
5. Native A2A/MCP Protocol Bridge
6. Ephemeral Context Envelope
7. Distributed Tracing & Telemetry Map
8. Dynamic Topological Sharding
9. Task-Adaptive Topology Router
10. Transition-Counter Circuit Breaker
11. OpenTelemetry OTLP Span Carrier
12. Asynchronous Event-Driven Mesh Dispatcher

### Architectural boundary

Anukor does **not** introduce a second orchestration architecture. These behaviors map onto S9 routing, pipelines, dependency graphs, events, execution policy, budgets, circuit breakers, checkpoints, provenance, and permissions.

A “15-character network” is a UX/topology representation, not a requirement for fifteen independent computational nodes.

A2A/MCP/REST translation, OpenTelemetry traces, and dynamic topology mutation must only be represented as implemented when actual adapters/runtime support exists.

---

# 11. Gate 2 — Private Room

**Purpose:** individual decision laboratory and personal executive command center.

The Private Room preserves the user's ultimate decision authority while making the decision process structured, challengeable, bounded, and learnable.

## 11.1 Core questions

- How can incomplete real-world goals be framed without inventing missing constraints?
- How can a human challenge reasoning without reading unstructured walls of text?
- What safety boundaries prevent accidental or impulsive execution?
- How can actual outcomes refine future decisions without confusing correlation with proof?

## 11.2 Private Room lifecycle

```text
Goal + Data + Context
        ↓
Structured Ingestion
        ↓
Trade-Off Options
        ↓
Human Challenge
        ↓
Decision
        ↓
Action Safety Gate
        ↓
Execution
        ↓
Real-World Result
        ↓
Prediction Variance
        ↓
Personal Learning
        ↺
```

## 11.3 Goal & Context Decomposition Canvas

The Input Bay separates:

- **Goal**
- **Static Data**
- **Dynamic Context**

Possible system tags:

- `DATA_COMPLETE`
- `CONTEXT_SLOT_MISSING`
- `AMBIGUOUS_BOUNDS`

Dharen flags missing operational variables before downstream option generation when the underlying context capability supports this.

## 11.4 Pareto Decision Frontier

The Private Room presents multiple decision vectors rather than a single “best” answer.

Example option dimensions:

- speed
- cost
- reliability
- risk
- rigor

A preference slider may alter option calculations only when a real decision engine supports dynamic recalculation. The UI must not fake live optimization.

## 11.5 Socratic Challenge & Stress-Test Bench

A human may move an option into a challenge surface where Manis exposes:

- unstated assumptions
- counter-scenarios
- constraint failures
- alternative interpretations
- risk cases

The human may counter, accept, reject, modify variables, or revise the option.

The challenge surface is a human-agency mechanism, not a forced rejection gate.

## 11.6 Two-Factor Judgment & Action Safety Gate

Before consequential action dispatch, the system may present an approval briefing containing:

- Action Scope
- Blast Radius
- Rollback Plan
- Resource Cost

A two-factor or equivalent approval mechanism may be used where the actual authorization infrastructure supports it.

Bodhex dispatch remains bounded by actual S9 permission, execution policy, budget, circuit breaker, checkpoint, and human-authority contracts.

## 11.7 Bi-Temporal Results Journal

The Results Journal records:

- original decision
- prediction
- action
- observed result
- timing of prediction
- timing of observed result
- relevant context changes
- evidence
- uncertainty
- candidate follow-up/retest

The journal may calculate a **Prediction Variance Score** as an outcome/calibration measure. It must not automatically interpret one deviation as causal evidence.

Medrus and Viveda may consume qualified outcome evidence for future knowledge refinement when the underlying knowledge/evidence lifecycle permits it.

---

# 12. Gate 2 — Collaboration Room

**Purpose:** multi-human and multi-agent decision laboratory.

The Collaboration Room extends the Private Room lifecycle to explicit team participation, scoped access, disagreement, shared approval, and shared outcome ownership.

## 12.1 Roles

| Role | Access | Primary responsibility |
|---|---|---|
| House Owner | Full workspace governance | permissions, privacy, approval policy |
| Resident | Scoped collaboration | goals, data, options, challenges, co-signing where authorized |
| Guest | Restricted temporary access | inspect allowed threads and provide limited feedback |

Actual access must be enforced by authorization policy rather than UI labels.

## 12.2 RBAC Context Isolation

The canvas may expose visibility badges such as:

- `PUBLIC_TO_ROOM`
- `RESIDENT_ONLY`
- `OWNER_CONFIDENTIAL`

Private context must not leak into shared decision state merely because a participant is present in the room.

## 12.3 Consensus & Decision Polling

The room may capture:

- option votes
- targeted challenges
- disagreement sources
- unresolved constraints
- consensus state

A threshold such as `<70%` may be configured as a policy trigger, but it is not a universal research truth. Manis intervention should be policy-driven and inspectable.

## 12.4 Noise-Filtered Team Context

Syvax may convert team discussion into **candidate structured context** such as:

- Goal Update
- Data Input
- Decision Constraint
- Open Question
- Human Preference

A validation boundary should separate candidate extraction from authoritative context. Casual conversation must not silently become permanent system memory.

## 12.5 Multi-Signatory Action Gate

High-impact shared actions may require multiple designated human approvals.

The UI may expose:

```text
REQUIRED SIGNATURES: 2
COLLECTED: 1
STATUS: LOCKED
```

Execution unlocks only when the actual authorization policy says the required approvals are satisfied.

## 12.6 Shared Results Journal & Attribution Ledger

A shared outcome record may contain:

- original team goal
- context used
- option set
- team positions
- chosen option
- approvals
- execution receipt
- observed result
- contributor attribution
- follow-up/retest requirements

Attribution records participation and accountability; it should not be used as an unsupported measure of individual performance or worth.

---

# 13. Gate 2 — Guest Pass Room

**Purpose:** ephemeral evaluation and isolated decision-support experience without requiring a permanent Human Residence.

## 13.1 Guest lifecycle

```text
Guest Ingress
    ↓
Ephemeral Session
    ↓
Goal + Data + Context
    ↓
Decision Support
    ↓
Logic X-Ray
    ↓
Trade-Off Sparring
    ↓
Leave              Claim Residence
  ↓                         ↓
Destroy / Expire        Migrate State
```

## 13.2 Ephemeral isolation

The intended model is an isolated temporary session with an explicit lifetime.

A UI may display:

- `ISOLATED_EPHEMERAL_STATE`
- session identifier
- expiry/TTL state

A hardware-isolated MicroVM, Firecracker/gVisor deployment, or equivalent is an infrastructure implementation choice, not an automatic consequence of this specification.

“Zero persistent footprint” and “memory vaporization” may only be advertised as guarantees after actual storage, expiry, deletion, logging, cache, artifact, and backup behavior has been implemented and verified.

## 13.3 Decision Logic X-Ray

The guest may inspect an explainable trace showing supported contributions from:

- Anukor routing
- Dharen context framing
- Pramon decision/planning
- Manis challenge
- evidence/reasoning stages where available

The trace should be derived from actual events/artifacts/read models. It must not fabricate internal work that did not occur.

## 13.4 Ephemeral Trade-Off Sparring Deck

Guests may modify supported variables such as cost, speed, risk, or other contextual constraints and inspect resulting option changes.

Live recalculation is shown only where backed by a real capability.

## 13.5 Workspace Ownership Handover

A future/implemented conversion path may migrate an ephemeral decision thread into a permanent Private Room.

The migration contract should explicitly define:

- artifacts transferred
- provenance retained
- context transferred
- permissions reassigned
- temporary state removed
- session expiration behavior

A “Claim House & Save Decision” UI control must not imply encrypted key migration unless that cryptographic mechanism actually exists.

---

# 14. Unified Gate 2 Research Loop

The three Gate 2 rooms collectively support the research-oriented lifecycle:

```text
                    HUMAN
                      ↓
                  QUESTION
                      ↓
                   CONTEXT
                      ↓
                   EVIDENCE
                      ↓
                  REASONING
                      ↓
              HUMAN CHALLENGE
                      ↓
              ALTERNATIVE HYPOTHESIS
                      ↓
             DECISION / EXPERIMENT
                      ↓
               OBSERVED RESULT
                      ↓
             OUTCOME COMPARISON
                      ↓
          QUALIFIED KNOWLEDGE UPDATE
                      ↓
          CONTEXT-CONDITIONED REUSE
```

### Research layers

**Layer 1 — Intelligence effectiveness**

- technical validity
- evidence grounding
- explanation quality
- hypothesis quality
- decision utility
- outcome validity

**Layer 2 — Human–AI collaboration**

- human agency
- challenge behavior
- disagreement handling
- trust calibration
- intervention quality
- decision participation

The interface can make these interactions observable and structured, but interaction telemetry is not automatically research evidence. Research use requires appropriate consent, privacy, data minimization, retention, anonymization/pseudonymization, and applicable ethics/approval requirements.

---

# 15. Combined Civilization Flow

```text
GATE 1 — UNDERSTAND THE CIVILIZATION

Characters / Homes / Bloom / Evidence / Routing / Reasoning
                         ↓
                      Syvax
                         ↓
GATE 2 — WORK WITH THE CIVILIZATION
                         ↓
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
     PRIVATE       COLLABORATION       GUEST
      ROOM             ROOM             PASS
        │                │                │
        └────────────────┼────────────────┘
                         ↓
                   S1–S9 SUBSTRATE
                         ↓
        Evidence → Reasoning → Challenge
                         ↓
                Hypothesis / Action
                         ↓
                    Real Result
                         ↓
               Knowledge / Reuse
```

---

# 16. Locked Architectural Principles

1. Gate 1 explains and exposes the civilization.
2. Gate 2 gives humans a structured environment for real decisions.
3. Private Room is the individual decision laboratory.
4. Collaboration Room is the multi-human decision laboratory.
5. Guest Pass is the ephemeral evaluation boundary.
6. Human authority remains explicit.
7. Characters embody roles; they do not own the underlying architecture.
8. Homes organize specialized work; they do not become separate AI brains.
9. Anukor is the network/control-plane resident and remains spatially fluid.
10. Syvax is the human interaction boundary, not a monolithic orchestrator.
11. Bloom is a presentation/read-model layer, not an orchestration engine.
12. Provenance, checkpoints, budgets, permissions, events, and state remain in the underlying architecture.
13. Manis challenges humans and system reasoning without becoming ultimate authority.
14. Dharen frames context without inventing unsupported facts.
15. Outcome variance is measurement, not automatic causal proof.
16. Consensus thresholds are configurable policy, not universal scientific constants.
17. Real data and synthetic data remain visibly distinct.
18. Visual scores are not measurements unless produced by an actual evaluator.
19. Simulated traces are never presented as live execution.
20. Guest isolation and vaporization are guarantees only when actually enforced.
21. Human collaboration data is permission-scoped.
22. Research telemetry is not automatically research evidence.
23. Progressive disclosure remains the primary strategy for complex telemetry.
24. Reusable capabilities remain character-independent.

---

# 17. Implementation Truthfulness Matrix

Every documented UX element should be classified as one of:

| Status | Meaning |
|---|---|
| **Implemented** | Backed by actual application/runtime behavior. |
| **Visualized** | Derived from actual state and rendered through a UI metaphor. |
| **Simulated** | Deliberately demonstrative and not live execution. |
| **Planned** | Reserved for a future implementation. |

The UI must never use visual sophistication to conceal an implementation gap.

---

# 18. Documentation Closure State

With this addendum, the current documentation baseline covers:

- Gate 1 civilization experience
- Gate 2 Human Residence structure
- Private Room
- Collaboration Room
- Guest Pass
- Syvax interaction boundary
- Bloom visualization boundary
- Home 01 / Sandre + Kaelen
- Home 02 / Dharen + Anuka
- Home 04 / Vivren + Tarkis
- Home 05 / Pramon + Bodhex
- Home 06 / Medrus + Epistre + Veridat
- Home 07 / Manis
- Home 08 / Viveda
- Anukor network/control-plane role
- Home-to-Home conceptual handoffs
- Human decision lifecycle
- Research-oriented interaction loop
- Implementation truthfulness rules
- Architectural separation from S1–S9

This closes the current **Civilization + Human Residence UX documentation pass**. Future changes should be recorded as explicit revisions rather than silently changing the locked baseline.
