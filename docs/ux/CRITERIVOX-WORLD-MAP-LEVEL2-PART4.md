# Criterivox World Map — Level 2, Part IV
## Intelligence Quarter & Decision & Action Quarter
### Internal Functional-Spatial Specification

## 1. Purpose

This document defines the internal functional-spatial specification for the Level-1 **Intelligence Quarter** and **Decision & Action Quarter** of the Criterivox World Map.

It translates the previously defined research responsibilities into spatial rooms, chambers, desks, observatories, gates, and inspection surfaces without redefining the underlying computational architecture.

The spatial model follows:

WORLD → GATE → REGION → QUARTER → HOME → ROOM / CHAMBER / DESK → INTERACTION SURFACE → SYSTEM OUTPUT

The two quarters represent a critical transition:

**CONTEXT → HYPOTHESIS → REASONING AUDIT → DECISION → EXECUTION PLAN → ACTION CONTRACT**

Vivren and Tarkis govern the quality and resilience of reasoning. Pramon and Bodhex govern planning, operational trade-offs, executable action preparation, and controlled execution readiness.

Characters remain representations of system responsibilities. They are not separate autonomous systems merely because they occupy separate homes.

---

## 2. Level-1 Naming Alignment

Legacy numeric labels are intentionally removed.

| Legacy label | Level-1 canonical name | Members |
|---|---|---|
| Home 04 | **Intelligence Quarter — Vivren’s Intelligence Home** | Vivren, Tarkis |
| Home 05 | **Decision & Action Quarter — Pramon’s Planning & Decision Home** | Pramon, Bodhex |

The Level-1 names are canonical for navigation, documentation, UI labels, spatial maps, and future implementation.

---

# PART I — INTELLIGENCE QUARTER

## 3. Intelligence Quarter

**Primary responsibility**

- Critical reasoning
- Hypothesis generation
- Adversarial hypothesis testing
- Fallacy and assumption detection
- Process-level reasoning evaluation
- Epistemic boundary enforcement
- Counterfactual exploration
- Reasoning-path search
- Goal-drift detection
- Conflict recording
- Formal reasoning translation
- Evidence-driven hypothesis revision

### Members

**Vivren — Senior Critic / Discernment**

Owns:

- adversarial critique
- process supervision
- epistemic boundary checking
- logical integrity
- hypothesis pruning
- disagreement recording
- semantic-anchor protection
- formal validation preparation

**Tarkis — Hypothesis Specialist / Fast Explorer**

Owns:

- hypothesis generation
- alternative reasoning branches
- counterfactual exploration
- search-tree expansion
- hypothesis revision
- failure reflection
- exploratory reasoning states

### Primary inbound relationships

- Dharen → Intelligence Quarter
- Syvax → Intelligence Quarter
- Anukor → Intelligence Quarter

### Primary outbound relationships

- Intelligence Quarter → Medrus
- Intelligence Quarter → Pramon
- Intelligence Quarter → Veridat
- Intelligence Quarter → Manis
- Intelligence Quarter → Viveda

The quarter does not imply a fixed sequential pipeline. Anukor may dynamically route work across the network.

---

## 4. Intelligence Home Spatial Grammar

The home is organized as a progression from **hypothesis formation → adversarial examination → search → refusal → formalization → conflict resolution**.

### Core spatial nodes

1. **Hypothesis Workshop**
2. **Adversarial Debate Arena**
3. **Epistemic Audit Chamber**
4. **Reasoning Search Observatory**
5. **Counterfactual Simulation Deck**
6. **Process Supervision Gallery**
7. **Epistemic Boundary Gate**
8. **Reflexion Ledger**
9. **Handoff Integrity Gate**
10. **Goal Alignment Observatory**
11. **Formal Logic Studio**
12. **Conflict Resolution Chamber**

---

## 5. Hypothesis Workshop

### Purpose

Primary workspace for Tarkis to transform structured context into candidate hypotheses.

### Visible elements

- current context summary
- hypothesis candidates
- alternative branches
- assumption markers
- hypothesis status
- originating context reference
- downstream destination

### Outputs

- RAW_HYPOTHESIS
- ALTERNATIVE_HYPOTHESIS
- HYPOTHESIS_BRANCH_SET
- CANDIDATE_SCENARIO

### HCI purpose

The user can see that a hypothesis is **generated**, not yet established as truth.

---

## 6. Adversarial Debate Arena

### Purpose

Structured Vivren–Tarkis deliberation surface.

### Functional behavior

Tarkis proposes a hypothesis.

Vivren produces:

- counter-hypotheses
- objections
- assumption probes
- edge cases
- logical challenges
- requests for refinement

Tarkis may revise or defend the hypothesis.

### Spatial interface

**Debate Split-Screen**

| Tarkis side | Shared center | Vivren side |
|---|---|---|
| Thesis | Logical Friction Gauge | Critique |
| Alternatives | Iteration count | Counter-hypothesis |
| Revision | Convergence state | Objections |

### Outputs

- DEBATE_TRACE
- COUNTER_HYPOTHESIS
- REVISED_HYPOTHESIS
- CONVERGENCE_STATE

The interface exposes the deliberation structure without exposing private chain-of-thought.

---

## 7. Epistemic Audit Chamber

### Purpose

Inspect whether a hypothesis satisfies defined reasoning-quality criteria.

### Functions

- fallacy detection
- unstated assumption detection
- unsupported extrapolation detection
- correlation/causation warning
- false-dilemma warning
- hasty-generalization warning
- premise integrity inspection

### Interaction

A flagged claim can open an **Epistemic Audit Card** containing:

- flagged claim
- detected issue category
- supporting evidence
- affected dependency
- correction requirement
- audit status

### Outputs

- FALLACY_FLAG
- ASSUMPTION_FLAG
- PREMISE_WARNING
- EPISTEMIC_AUDIT_RECORD

---

## 8. Reasoning Search Observatory

### Purpose

Visualize alternative reasoning paths and test-time search allocation.

### Functions

- branch generation
- branch scoring
- branch pruning
- search-depth control
- computational budget visualization
- path comparison

### Interface

**Reasoning Depth Control**

- Fast Exploration
- Balanced Search
- Deep Search
- Experimental Search

The displayed depth must represent an actual configured execution budget when implemented. A decorative slider must never imply real compute scaling.

### Outputs

- REASONING_TREE
- BRANCH_SCORE_SET
- PRUNED_PATH_SET
- SEARCH_BUDGET_STATE

---

## 9. Counterfactual Simulation Deck

### Purpose

Allow controlled exploration of alternative conditions.

### Functions

- variable substitution
- boundary-condition testing
- scenario comparison
- hypothesis stability testing
- edge-case exploration

### Spatial model

A matrix of scenario cards:

**BASELINE → VARIABLE CHANGE → RESULTING PATH → VIVREN EVALUATION**

### Outputs

- COUNTERFACTUAL_SCENARIO
- SCENARIO_RESULT
- STABILITY_COMPARISON
- EDGE_CASE_RECORD

Counterfactual results must be clearly separated from observed evidence.

---

## 10. Process Supervision Gallery

### Purpose

Evaluate reasoning quality at the process level rather than only at final-output level.

### Functions

- step-level evaluation
- node quality scoring
- invalid-step detection
- regeneration trigger
- process trace inspection

### Interface

A reasoning stream with structured status markers:

- VALID
- NEEDS_REVIEW
- INVALID
- REGENERATE

### Outputs

- STEP_CONFIDENCE
- NODE_EVALUATION
- PROCESS_HALT
- REGENERATION_REQUEST

The interface must not present private chain-of-thought as an inspectable user artifact. It displays permitted reasoning summaries, evaluation metadata, and traceable evidence.

---

## 11. Epistemic Boundary Gate

### Purpose

Prevent hypothesis generation when required context is materially incomplete.

### Trigger conditions

- missing critical variables
- insufficient context
- conflicting context
- unsupported assumptions required to continue
- unresolved context poisoning signal

### Interface

**Missing Information Diagnostic**

Displays:

- missing variable
- why it matters
- source of required information
- affected hypothesis
- requested correction

### Outputs

- INSUFFICIENT_CONTEXT
- VARIABLE_GAP_SET
- EPISTEMIC_REFUSAL
- CONTEXT_REQUEST

This is a controlled refusal state, not a failure of the system.

---

## 12. Reflexion Ledger

### Purpose

Record structured lessons from rejected hypotheses and failed reasoning attempts.

### Functions

- failure capture
- remediation recording
- alternative strategy registration
- repeated-failure detection
- revision history

### Outputs

- FAILURE_REASON
- REMEDIATION_RECORD
- REFLEXION_ENTRY
- REPEATED_FAILURE_SIGNAL

The ledger stores structured learning information, not unrestricted hidden model reasoning.

---

## 13. Handoff Integrity Gate

### Purpose

Verify that reasoning payloads crossing the home boundary conform to defined contracts.

### Functions

- schema validation
- payload integrity checking
- contract verification
- malformed-payload rejection
- handoff status display

### Interface

**Handoff Integrity Shield**

States:

- VALIDATED
- REJECTED
- SCHEMA_MISMATCH
- REQUIRES_REVIEW

### Outputs

- VALIDATED_HANDOFF
- SCHEMA_MISMATCH_ERROR
- HANDOFF_REVIEW_REQUIRED

Cryptographic signing is a planned implementation capability unless actually implemented.

---

## 14. Goal Alignment Observatory

### Purpose

Detect semantic drift between the original user objective and revised hypotheses.

### Functions

- semantic-anchor reference
- goal comparison
- drift detection
- reset recommendation
- alignment history

### Interface

**Goal Alignment Meter**

The threshold must be configurable and evidence-backed. A fixed value such as 85% is a design parameter, not a universal truth.

### Outputs

- GOAL_ALIGNMENT_SCORE
- SEMANTIC_DRIFT_SIGNAL
- ROOT_CONTEXT_RESET
- ALIGNMENT_HISTORY

---

## 15. Formal Logic Studio

### Purpose

Translate approved natural-language claims into structured logical representations.

### Functions

- proposition extraction
- logical relation mapping
- decision-tree construction
- formal consistency checking
- typed contract preparation

### Views

- Plain-language view
- Logic view
- Flow view
- Structured contract view

### Outputs

- FORMAL_ARGUMENT
- LOGIC_GRAPH
- DECISION_TREE
- VALIDATION_CONTRACT

---

## 16. Conflict Resolution Chamber

### Purpose

Provide an explicit surface for unresolved Vivren–Tarkis disagreement.

### Functions

- disagreement comparison
- iteration history
- objection inspection
- unresolved issue classification
- human escalation

### Interface

**Conflict Resolution Drawer**

Displays:

- Tarkis thesis
- Vivren objection
- supporting evidence
- unresolved point
- previous attempts
- available human intervention

### Outputs

- DISAGREEMENT_RECORD
- CONFLICT_ESCALATION
- HUMAN_REVIEW_REQUIRED
- RESOLUTION_STATUS

---

## 17. Intelligence Quarter Functional Matrix

| Member | Responsibility | Primary outputs |
|---|---|---|
| Tarkis | Hypothesis generation and exploration | hypotheses, alternatives, scenarios, reasoning branches |
| Vivren | Critique and epistemic control | audits, objections, process evaluations, refusal signals |
| Shared | Deliberation and formalization | reviewed hypotheses, conflict records, structured contracts |

---

# PART II — DECISION & ACTION QUARTER

## 18. Decision & Action Quarter

**Primary responsibility**

- empirical proof weighting
- planning
- multi-objective trade-off analysis
- execution readiness
- contingency planning
- action compilation
- tool governance
- resource governance
- durable workflow state
- execution health monitoring

### Members

**Pramon — Planning & Empirical Proof Owner**

Owns:

- decision planning
- empirical evidence weighting
- trade-off optimization
- contingency design
- resource governance
- decision rationale
- durable state coordination

**Bodhex — Executable Perception & Action Specialist**

Owns:

- action compilation
- tool precondition mapping
- executable payload construction
- isolated execution summaries
- tool protocol adaptation
- execution health reporting

### Primary inbound relationships

- Intelligence Quarter
- Medrus
- Veridat
- Anukor
- Syvax

### Primary outbound relationships

- Bodhex / execution layer
- Human Residence
- Results Journal
- Anukor
- Medrus / peer review
- Viveda / learning

---

## 19. Decision & Action Home Spatial Grammar

The home is organized as:

**PROOF → PLAN → TRADE-OFF → CONTINGENCY → ACTION CONTRACT → GOVERNED EXECUTION → REPLAY / RECOVERY**

### Core spatial nodes

1. **Planning Hall**
2. **Trade-Off Observatory**
3. **Action Contract Studio**
4. **Contingency Planning Chamber**
5. **Empirical Proof Desk**
6. **Decision Rationale Archive**
7. **Peer Review Gate**
8. **Blast-Radius Control Room**
9. **Subagent Isolation Chamber**
10. **Execution DAG Observatory**
11. **Resource Budget Observatory**
12. **FinOps Control Desk**
13. **MCP Tool Registry**
14. **Durable Replay Chamber**
15. **Tool Health & Circuit Breaker Wall**

---

## 20. Planning Hall

### Purpose

Transform validated hypotheses and evidence into executable plans.

### Functions

- objective decomposition
- step planning
- dependency identification
- action sequencing
- execution readiness assessment

### Outputs

- EXECUTION_PLAN
- PLAN_STEP_SET
- DEPENDENCY_SET
- EXECUTION_READINESS_STATE

---

## 21. Trade-Off Observatory

### Purpose

Expose competing planning objectives without hiding trade-offs behind a single score.

### Dimensions may include

- accuracy
- latency
- resource cost
- evidence strength
- safety
- execution complexity

### Interface

**Trade-Off Matrix / Pareto View**

Users can inspect alternative plans and their measured or estimated characteristics.

### Outputs

- TRADE_OFF_PROFILE
- PLAN_ALTERNATIVE_SET
- PARETO_CANDIDATE_SET

A visual frontier is only presented as computed analysis when the underlying metrics actually exist.

---

## 22. Action Contract Studio

### Purpose

Translate a decision into a structured executable contract.

### Interface

**Plan vs. Action Contract**

| Planning view | Action view |
|---|---|
| human-readable objective | structured action |
| rationale | tool arguments |
| dependencies | preconditions |
| constraints | rate limits |
| expected result | validation requirements |

### Outputs

- ACTION_CONTRACT
- TOOL_ARGUMENT_SET
- PRECONDITION_SET
- EXECUTION_CONSTRAINTS

---

## 23. Contingency Planning Chamber

### Purpose

Represent alternative execution paths when primary steps fail.

### Functions

- failure branch definition
- fallback selection
- retry policy
- rerouting
- dependency-aware recovery

### Interface

**Contingency Flow Canvas**

Primary route and fallback routes are visually distinct.

### Outputs

- CONTINGENCY_GRAPH
- FALLBACK_PATH
- RETRY_POLICY
- REROUTE_REQUEST

---

## 24. Empirical Proof Desk

### Purpose

Connect planning decisions to evidence strength.

### Functions

- evidence inspection
- evidence-to-step mapping
- uncertainty marking
- proof requirement identification
- validation request

### Outputs

- EMPIRICAL_SCORE
- EVIDENCE_DEPENDENCY
- PROOF_GAP
- VALIDATION_REQUEST

Scores are system-specific evaluation outputs, not claims of objective mathematical truth.

---

## 25. Decision Rationale Archive

### Purpose

Maintain an auditable record of why a plan was selected.

### Contents

- selected plan
- rejected alternatives
- evidence references
- trade-off measurements
- constraints
- approval state
- timestamp/version

### Outputs

- DECISION_RATIONALE_RECORD
- PLAN_SELECTION_RECORD
- ALTERNATIVE_REJECTION_RECORD
- AUDIT_EXPORT

Export formats may include JSON or PDF when implemented.

---

## 26. Peer Review Gate

### Purpose

Allow high-impact plans to be challenged against evidence and historical results before execution.

### Relationship

**Pramon ↔ Medrus**

### Functions

- historical comparison
- previous-failure lookup
- plan challenge
- evidence sufficiency review

### Outputs

- PEER_REVIEW_REQUEST
- HISTORICAL_RISK_SIGNAL
- PLAN_REVIEW_RESULT

---

## 27. Blast-Radius Control Room

### Purpose

Determine the operational impact of proposed actions before dispatch.

### Risk dimensions

- read-only
- external request
- state-changing
- destructive / high-impact

### Interface

**Blast-Radius Meter**

Potential states:

- SAFE
- REVIEW
- APPROVAL_REQUIRED
- BLOCKED

### Outputs

- PERMITTED_ACTION
- HITL_APPROVAL_REQUIRED
- ACTION_BLOCKED
- RISK_PROFILE

The interface must never imply that a dangerous or destructive action is automatically authorized merely because a plan exists.

---

## 28. Subagent Isolation Chamber

### Purpose

Represent isolated execution contexts and clean return contracts.

### Functions

- isolated task context
- execution trace separation
- summary compression
- result validation
- return-contract enforcement

### Interface

**Transcript Compression View**

Displays permitted metadata such as:

- raw trace size
- summary size
- compression ratio
- returned structured fields

The system must avoid presenting private chain-of-thought as a user-facing transcript.

### Outputs

- ISOLATED_TASK
- COMPRESSED_EXECUTION_SUMMARY
- SUBAGENT_RETURN_CONTRACT

---

## 29. Execution DAG Observatory

### Purpose

Visualize task dependencies and identify parallelizable work.

### Functions

- dependency mapping
- topological ordering
- parallel branch identification
- blocked-node visualization
- execution progress

### Interface

**Execution DAG Canvas**

Nodes represent tasks.

Edges represent dependencies.

Node states may include:

- READY
- RUNNING
- BLOCKED
- COMPLETE
- FAILED
- RECOVERING

### Outputs

- EXECUTION_DAG
- READY_NODE_SET
- BLOCKED_DEPENDENCY
- PARALLEL_EXECUTION_GROUP

---

## 30. Resource Budget Observatory

### Purpose

Monitor computational and service-resource constraints before and during execution.

### Measures may include

- token estimate
- actual token usage
- API request count
- latency
- concurrency
- configured budget
- remaining budget

### Outputs

- RESOURCE_ESTIMATE
- RESOURCE_USAGE
- BUDGET_WARNING
- BUDGET_CAP_REACHED

The displayed values must originate from actual telemetry when labelled as live.

---

## 31. FinOps Control Desk

### Purpose

Govern economic cost of agentic execution.

### Functions

- projected cost
- token expenditure
- execution budget
- throttling
- model/pipeline adjustment
- authorization boundary

### Outputs

- SPEND_PROJECTION
- COST_GUARDRAIL_STATE
- BUDGET_AUTHORIZATION_REQUIRED
- EXECUTION_THROTTLED

Currency values must be environment-specific. Example dollar limits are configuration examples, not canonical Criterivox policy.

---

## 32. MCP Tool Registry

### Purpose

Provide a visible registry of standardized tool contracts.

### Functions

- tool inventory
- schema inspection
- endpoint metadata
- capability mapping
- health metadata
- contract validation

### Interface

**MCP Tool Inventory Drawer**

Each tool may expose:

- tool identifier
- schema version
- capability
- permissions
- latency metadata
- health state
- availability

### Outputs

- MCP_TOOL_SCHEMA
- TOOL_CAPABILITY_RECORD
- TOOL_PERMISSION_PROFILE
- TOOL_HEALTH_STATE

MCP integration is a planned capability unless connected and tested in the runtime.

---

## 33. Durable Replay Chamber

### Purpose

Represent durable execution state and controlled workflow replay.

### Functions

- checkpoint inspection
- state restoration
- event history
- replay selection
- failure-point inspection

### Interface

**Workflow Replay Bar**

Allows authorized users to inspect persisted execution states.

### Outputs

- EXECUTION_CHECKPOINT
- REHYDRATION_STATE
- REPLAY_REQUEST
- EVENT_LOG_REFERENCE

---

## 34. Tool Health & Circuit Breaker Wall

### Purpose

Isolate malfunctioning tools and prevent cascading workflow failures.

### Functions

- health monitoring
- timeout tracking
- retry tracking
- circuit state
- fallback reporting

### States

- HEALTHY
- DEGRADED
- ISOLATED
- RECOVERING

### Outputs

- CIRCUIT_TRIPPED
- TOOL_HEALTH_EVENT
- FALLBACK_REPORT
- REROUTE_REQUEST

The threshold for tripping a circuit breaker must be configurable rather than hard-coded as a universal rule.

---

## 35. Decision & Action Functional Matrix

| Member | Responsibility | Primary outputs |
|---|---|---|
| Pramon | Planning, proof weighting, trade-offs, governance | plans, trade-off profiles, decision rationale, contingency graphs |
| Bodhex | Action compilation, tool contracts, execution support | action contracts, tool payloads, execution DAGs, health reports |
| Shared | Governed execution readiness | approved plans, controlled actions, recovery states |

---

# PART III — CROSS-QUARTER NETWORK

## 36. Intelligence → Decision Handoff

The canonical conceptual handoff is:

**Dharen → Tarkis → Vivren → Evidence / Verification → Pramon → Bodhex**

However, this is not a mandatory linear runtime route.

Anukor provides dynamic routing across these boundaries.

### Handoff contract

The Intelligence Quarter should provide:

- hypothesis identifier
- context reference
- assumptions
- uncertainty metadata
- validation status
- goal alignment status
- unresolved conflicts
- structured contract where available

The Decision & Action Quarter should return:

- feasibility status
- evidence requirements
- plan alternatives
- resource requirements
- execution constraints
- approval requirements

---

## 37. Evidence Feedback Loop

When downstream evidence or verification invalidates a hypothesis:

**Pramon / Veridat → Intelligence Quarter → Tarkis revision → Vivren audit → downstream validation**

This creates a visible non-linear loop rather than pretending every workflow is a one-way pipeline.

---

## 38. Human Intervention Boundary

Human intervention is available at meaningful decision boundaries.

### Intelligence Quarter

- epistemic refusal
- unresolved disagreement
- goal drift
- low-confidence hypothesis
- ambiguous context

### Decision & Action Quarter

- high-impact action
- approval-required operation
- budget escalation
- unresolved plan trade-off
- blocked dependency
- tool health failure

The human is not reduced to an approval button. The spatial model should allow inspection, challenge, comparison, and intervention.

---

# PART IV — BLOOM RELATIONSHIP

## 39. Bloom Connection

Bloom remains the **global central nexus**.

The Intelligence Quarter and Decision & Action Quarter connect to Bloom through their Level-1 quarter/home boundaries.

Bloom may expose:

- active reasoning state
- active plan state
- cross-home handoffs
- intervention checkpoints
- provenance references
- execution state
- network activity

This section does not redefine Bloom's global feature set from earlier Level-2 parts.

---

# PART V — SHARED CHARACTER STATE PRESENTATION

## 40. Runtime Character States

Vivren, Tarkis, Pramon, and Bodhex use the shared semantic character-state contract.

Examples:

- IDLE
- RECEIVE
- WORK
- COMMUNICATE
- HANDOFF
- COMPLETE
- WARNING

Attention states remain separate:

- QUIET
- ATTENTIVE
- FOCUSED
- BUSY
- WAITING
- NEEDS_USER
- COMPLETING
- RECOVERING

Visual animation communicates state. It does not invent intelligence or imply functionality that does not exist.

---

# PART VI — RUNTIME TRUTH CONTRACT

## 41. Capability Status

Every advanced feature must be explicitly classified.

| Status | Meaning |
|---|---|
| **LIVE** | Implemented and connected to real runtime behavior |
| **SIMULATED** | Demonstrative behavior with controlled/mock data |
| **PLANNED** | Designed but not implemented |
| **RESEARCH PROTOTYPE** | Experimental implementation under evaluation |

The UI must never represent a PLANNED feature as LIVE.

Examples:

- MCTS visualizer: PLANNED or RESEARCH PROTOTYPE until implemented and evaluated.
- MCP registry: PLANNED until actual tool contracts are connected and tested.
- Durable replay: LIVE only when durable state and replay are implemented.
- Cost telemetry: LIVE only when actual usage telemetry feeds the display.
- Debate arena: LIVE only when actual structured deliberation is connected.
- Formal schema compiler: LIVE only when generated contracts are validated by the implementation.

---

# PART VII — ACCESSIBILITY & AGE-PROGRESSIVE HCI

## 42. Spatial Accessibility

All quarter interactions must have non-spatial equivalents.

Required:

- labels
- status text
- keyboard/controller navigation where supported
- readable contrast
- reduced-motion mode
- focus indicators
- screen-reader-compatible semantic descriptions
- no essential information conveyed only through animation or color

## 43. Progressive Depth

The same spatial structure supports progressive understanding.

### Entry level

- characters
- home
- simple role
- simple status

### Intermediate level

- collaboration
- evidence
- hypotheses
- plans
- dependencies

### Advanced level

- reasoning paths
- provenance
- process evaluation
- uncertainty
- contracts
- DAGs
- resource telemetry
- replay state
- governance boundaries

The system does not create separate worlds for different ages or skill levels. Complexity is progressively disclosed.

---

# PART VIII — HCI & RESEARCH GAIN

## 44. Intelligence Quarter Gain

The Intelligence Quarter makes otherwise invisible reasoning governance spatially understandable.

It provides:

- visible hypothesis formation
- adversarial critique
- uncertainty boundaries
- process-quality inspection
- non-linear revision
- conflict visibility
- semantic-goal protection
- structured formalization

## 45. Decision & Action Quarter Gain

The Decision & Action Quarter makes operational decision-making inspectable before execution.

It provides:

- trade-off visibility
- evidence-to-plan linkage
- contingency awareness
- action-contract transparency
- permission boundaries
- dependency visualization
- resource governance
- durable recovery visibility
- tool-health observability

## 46. Combined Research/HCI Gain

Together, the quarters create a spatial representation of the transition:

**“Is this reasoning sufficiently justified?”**

→ **“What should be done?”**

→ **“Under what constraints?”**

→ **“What happens if execution fails?”**

→ **“Where can a human inspect or intervene?”**

This supports Criterivox's broader principle:

**Invisible computational responsibility becomes navigable, inspectable spatial structure.**

---

# PART IX — ACCEPTANCE CRITERIA

## 47. Intelligence Quarter

- [ ] Level-1 name is used everywhere.
- [ ] Vivren and Tarkis are represented as distinct responsibilities within one Intelligence Home.
- [ ] Hypothesis generation is visually separated from validation.
- [ ] Adversarial critique is inspectable.
- [ ] Epistemic refusal is represented as a valid system state.
- [ ] Reasoning search is distinguishable from evidence.
- [ ] Counterfactuals are labelled as hypothetical.
- [ ] Conflict escalation has a visible human boundary.
- [ ] Goal drift is represented without pretending a fixed threshold is universally valid.
- [ ] Private chain-of-thought is not exposed as a user-facing artifact.

## 48. Decision & Action Quarter

- [ ] Level-1 name is used everywhere.
- [ ] Pramon and Bodhex have distinct but connected responsibilities.
- [ ] Evidence is linked to planning decisions.
- [ ] Trade-offs are visible.
- [ ] Contingency paths are visible.
- [ ] Action contracts are inspectable.
- [ ] High-impact actions have an approval boundary.
- [ ] Tool execution is permission-aware.
- [ ] Resource budgets are observable when telemetry exists.
- [ ] Tool failures can be represented without falsely claiming automatic recovery.
- [ ] Replay is clearly marked LIVE/SIMULATED/PLANNED/RESEARCH PROTOTYPE.

## 49. Cross-Quarter

- [ ] Handoffs are contract-based.
- [ ] Dynamic routing remains compatible with Anukor.
- [ ] Evidence can invalidate and reroute a hypothesis.
- [ ] Human intervention is available at meaningful checkpoints.
- [ ] Bloom remains the global nexus.
- [ ] Character animation represents semantic runtime state.
- [ ] Spatial behavior does not invent backend capabilities.

---

# 50. Boundary With Level 2 Part V

Part IV ends at the boundary between:

**REASONING QUALITY + DECISION / ACTION READINESS**

and the next Level-1 functional areas.

Part V must not duplicate:

- Intelligence Quarter internals
- Decision & Action Quarter internals
- Bloom's global feature set
- Anukor's network-layer specification
- Human Residence internals
- previously defined Evidence & Experiment Quarter features

Future parts should extend the Level-1 world rather than reintroduce legacy Home numbers.

---

# 51. Canonical Level-2 Part IV Model

**WORLD**

→ **GATE 1 — Criterivox Civilization**

→ **INTELLIGENCE QUARTER**

→ **Vivren's Intelligence Home**

→ Hypothesis Workshop  
→ Adversarial Debate Arena  
→ Epistemic Audit Chamber  
→ Reasoning Search Observatory  
→ Counterfactual Simulation Deck  
→ Process Supervision Gallery  
→ Epistemic Boundary Gate  
→ Reflexion Ledger  
→ Handoff Integrity Gate  
→ Goal Alignment Observatory  
→ Formal Logic Studio  
→ Conflict Resolution Chamber

→ **DECISION & ACTION QUARTER**

→ **Pramon's Planning & Decision Home**

→ Planning Hall  
→ Trade-Off Observatory  
→ Action Contract Studio  
→ Contingency Planning Chamber  
→ Empirical Proof Desk  
→ Decision Rationale Archive  
→ Peer Review Gate  
→ Blast-Radius Control Room  
→ Subagent Isolation Chamber  
→ Execution DAG Observatory  
→ Resource Budget Observatory  
→ FinOps Control Desk  
→ MCP Tool Registry  
→ Durable Replay Chamber  
→ Tool Health & Circuit Breaker Wall

→ **BLOOM / ANUKOR / HUMAN INTERVENTION**

→ dynamic routing  
→ evidence feedback  
→ decision inspection  
→ controlled action readiness  
→ human challenge  
→ real-world result

This is the canonical Level-2 Part IV internal functional-spatial model.


---

# CURRENT BRANCH IMPLEMENTATION — ui-stabilization-system-behavior

This section supersedes earlier status labels where they conflict with the current implementation.

## Canonical runtime

Part IV is implemented as one integration layer:

- src/criterivox/world/level2_part4.py
- src/criterivox/ui/level2_part4_routes.py
- tests/test_world_map_level2_part4_runtime.py
- presentation/lib/world_map_level2_part4_page.dart
- presentation/lib/app_shell.dart

The integration layer reuses Part I–III routing, tracing/events, collaboration, HumanAuthority, evidence/provenance, Work Materials, sandbox, checkpoint/replay and telemetry. It intentionally creates no replacement engines for those capabilities.

## Implemented contracts

### Intelligence

Hypothesis creation, bounded reasoning search, adversarial debate, epistemic audit records, counterfactual scenarios, structured reflexion, goal-alignment measurement, handoff validation, conflict records and formal logic graph construction are represented by runtime contracts and API routes.

### Decision & Action

Planning, declared-metric trade-offs, Action Contracts, contingency graphs, proof packages, peer review, blast-radius states, execution DAGs, resource budgets, FinOps budget checks, tool registration/health, replay records and decision archiving are represented by runtime contracts and API routes.

### Truth model

- LIVE: connected runtime/control contract
- SIMULATED: bounded scenario/search behavior
- HISTORICAL: replay/reflexion records
- PLANNED: reserved for capabilities not yet connected

The presentation reads capability truth from the canonical Part-IV runtime state rather than hard-coding a separate status catalogue.

## Navigation reconciliation

civilization-part4 is the canonical Part-IV presentation route.

The historical decision-action route remains as a compatibility route but now opens the canonical Part-IV surface rather than maintaining a second Decision & Action presentation architecture.

The generic Level-2 operational catalogue remains a compatibility/read-model surface. It is not treated as a second backend implementation.

## Validation boundary

The repository includes focused Part-IV runtime tests. CI/local execution must still be run in an environment containing the project's Python and Flutter dependencies; repository writes alone do not constitute a test pass.

