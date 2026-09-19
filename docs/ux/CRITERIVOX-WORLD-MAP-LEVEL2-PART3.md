# Criterivox World Map — Level 2, Part III

## Knowledge Quarter & Challenge Quarter
### Internal Functional-Spatial Specification

---

## 1. Purpose

Level 2 Part III converts two Level-1 functional areas into an internal spatial and interaction specification:

1. **Knowledge Quarter — Viveda’s Knowledge Home**
2. **Challenge & Review Quarter — Manis’s Human Challenge Home**

This document defines how their responsibilities become rooms, work areas, inspection surfaces, collaboration boundaries, observable system events, and human intervention points.

It does not redefine the Criterivox computational architecture. It translates existing responsibilities into a spatial HCI model.

**Runtime truth rule:** a visible capability is presented as **LIVE** only when the corresponding backend/runtime behavior exists. Otherwise it must be labelled **PLANNED**, **SIMULATED**, or **RESEARCH PROTOTYPE**.

---

## 2. Level-1 Naming Alignment

Legacy numeric Home labels are intentionally removed from the internal world map.

| Level-1 World Location | Resident(s) | Responsibility |
|---|---|---|
| **Knowledge Quarter** | **Viveda** | Knowledge synthesis, reusable understanding, ontology/schema formation, transfer and knowledge refinement |
| **Challenge & Review Quarter** | **Manis** | Human challenge, assumption stress-testing, red-teaming, oversight and operational counter-balancing |

Viveda and Manis are separate residents because their responsibilities are complementary but intentionally different:

**Viveda:** generalize what has been learned.

**Manis:** challenge whether that generalization should be trusted.

---

## 3. Shared Spatial Grammar

Both quarters use the established Criterivox naming semantics:

- **Home** — character residence and responsibility domain.
- **Hall** — public/shared interaction area.
- **Chamber** — deep inspection or decision analysis.
- **Workshop** — transformation/construction area.
- **Archive** — retained evidence, knowledge, or historical state.
- **Desk** — focused operational workspace.
- **Garden** — reflective, exploratory, or branching space.
- **Gate** — controlled boundary or handoff.
- **Observatory** — monitoring and system-state inspection.
- **Library** — reusable knowledge or skill collection.

Neither Home is merely decorative. Every spatial object should expose an underlying responsibility, state, relationship, or evidence boundary.

---

# 4. Knowledge Quarter — Viveda’s Knowledge Home

## 4.1 Resident

**Viveda**

### Primary responsibility

Knowledge Synthesis, Generalized Schema Formation, Dynamic Ontology Distillation, Transfer Learning, Skill Compilation, and Long-Term Knowledge Refinement.

Viveda converts validated episodic observations into reusable understanding.

The conceptual transformation is:

**Evidence → Pattern → Generalization → Validation → Reusable Knowledge → Transfer → Re-evaluation**

Medrus supplies evidence and execution history. Viveda abstracts it into reusable structures. Manis challenges those abstractions before they become trusted generalized rules.

---

## 4.2 Key Questions

The Knowledge Home must allow inspection of:

- How are repeated execution traces converted into reusable principles?
- Which observations support a generalized rule?
- How is a new domain ontology constructed?
- Which knowledge is transferable to another context?
- What evidence supports a skill or schema?
- Which rules have become outdated?
- How are old schemas migrated without breaking dependent workflows?
- How are reusable skills exposed without inflating active context?
- How are probabilistic insights converted into deterministic contracts?
- How does learned knowledge persist across sessions?
- How are atomic skills composed into higher-order competencies?

---

# 5. Knowledge Home Spatial Structure

## 5.1 Knowledge Hall

**Purpose:** public entry and overview of Viveda's current knowledge state.

Displays:

- active knowledge domains
- newly distilled patterns
- knowledge awaiting validation
- recently updated schemas
- transfer candidates
- deprecated knowledge
- active skill packages
- current learning/refinement activity

The Hall provides orientation before entering deeper inspection spaces.

---

## 5.2 Trajectory Distillation Workshop

**Responsibility:** convert episodic execution trajectories into generalized strategies.

### Primary feature

**Inductive Trajectory Distiller**

Medrus evidence packages enter the Workshop. Viveda identifies recurring structures while removing transient details such as temporary identifiers, variable names, or session-specific values.

### Spatial mechanism

A visual **Trajectory-to-Rule Synthesizer** shows:

**many execution traces → recurring pattern → abstract strategy → reusable workflow**

The system must distinguish:

- observed trace
- inferred pattern
- proposed rule
- validated rule

This prevents an inference from visually masquerading as established knowledge.

---

## 5.3 Ontology Weaver

**Responsibility:** construct and evolve structured domain knowledge.

### Primary feature

**Generative Ontology & Dynamic Schema Weaver**

Viveda builds structured representations containing:

- entities
- relationships
- constraints
- taxonomy nodes
- validation rules
- domain boundaries

### Spatial mechanism

**Knowledge Graph Weaver**

Users can inspect:

- entity nodes
- relationship edges
- domain hierarchy
- constraints
- schema signatures
- historical changes

The graph is an inspection representation, not proof that every displayed relationship is computationally active.

---

## 5.4 Structural Transfer Chamber

**Responsibility:** identify reusable structural strategies across domains.

### Primary feature

**Cross-Domain Transfer Learning Engine**

Viveda compares structural characteristics of a target problem against previously validated knowledge.

### Spatial mechanism

**Structural Analogy Split View**

Left side:

**Target Context**

Right side:

**Reusable Prior Pattern**

Center:

**Structural Similarity / Transfer Conditions**

The interface must expose why a transfer candidate is considered analogous rather than presenting transfer as automatic correctness.

---

## 5.5 Rule Friction Chamber

**Responsibility:** expose knowledge boundaries through Manis collaboration.

### Primary feature

**Epistemic Boundary Refiner**

Viveda sends proposed generalized rules toward Manis for adversarial testing.

Manis returns:

- edge cases
- counterexamples
- boundary failures
- contradictory conditions
- refinement requirements

### Spatial mechanism

**Rule Friction Terminal**

The room displays:

**Viveda Rule → Manis Challenge → Failure/Pass → Boundary Refinement**

Conditional exceptions may be represented explicitly, including structured **UNLESS** branches.

---

## 5.6 Skill Library

**Responsibility:** package validated knowledge for controlled reuse.

### Primary feature

**Skill-Library Compiler**

Validated reasoning patterns may become reusable executable skills or tool contracts.

### Spatial mechanism

**Compiled Skill Inventory**

Each skill can expose:

- skill identifier
- purpose
- input contract
- output contract
- validation status
- observed success rate
- latency metrics
- version
- provenance
- deprecation status

No executable skill is treated as trusted merely because Viveda generated it.

---

## 5.7 Skill Packaging Studio

**Responsibility:** progressive disclosure of reusable skills.

### Primary feature

**Progressive Disclosure Skill Compiler**

Knowledge is separated into staged representations:

- lightweight metadata
- detailed procedure
- execution implementation

The UI demonstrates how downstream agents can discover a skill without loading its entire procedure into active context.

### Spatial mechanism

**Skill Packaging Bench**

Shows:

**Skill Metadata → Detailed Procedure → Execution Package**

and the corresponding context/payload footprint.

---

## 5.8 Ontology Mutation Observatory

**Responsibility:** monitor dynamic changes to knowledge structures.

### Primary feature

**Dynamic Graph-RAG & Ontology Mutation Engine**

New evidence may:

- create concepts
- create relationships
- update relationships
- invalidate taxonomy paths
- preserve historical versions

### Spatial mechanism

**Ontology Mutation View**

Changes are classified semantically as:

- added
- modified
- deprecated
- disputed
- awaiting validation

The interface must preserve historical lineage rather than silently rewriting the past.

---

## 5.9 Schema Translation Terminal

**Responsibility:** convert generalized knowledge into deterministic machine-readable contracts.

### Primary feature

**Neuro-Symbolic Schema Compiler**

Natural-language or probabilistic knowledge patterns are transformed into typed structures such as:

- Pydantic models
- validation contracts
- MCP-compatible tool schemas

### Spatial mechanism

**Schema Translation Split Screen**

**Conceptual Knowledge → Typed Contract**

The UI exposes:

- required fields
- types
- constraints
- validation rules
- compatibility status

---

## 5.10 Knowledge Utility Observatory

**Responsibility:** evaluate whether retained knowledge remains useful.

### Primary features

- Autonomous Memory Pruning
- Utility Evaluation
- Heuristic Decay
- Active Knowledge Refinement

### Spatial mechanism

**Knowledge Utility Gauge**

Tracks:

- usage frequency
- success/failure history
- confidence
- transfer performance
- age
- recent validation
- proposed archival status

A low-use rule is not automatically false. Utility and validity are separate dimensions.

---

## 5.11 Skill Health & Decay Observatory

**Responsibility:** detect obsolete or degraded reusable skills.

### Spatial mechanism

**Skill Health & Decay Radar**

Displays:

- active usage
- success trend
- failure trend
- validation age
- domain drift
- deprecation candidate
- revalidation requirement

Possible machine events:

- `SKILL_REVALIDATION_REQUIRED`
- `SKILL_DEPRECATED`
- `SKILL_REDISTILL_REQUIRED`

These are event-contract examples, not claims that the runtime currently emits them.

---

# 6. Cross-Session Knowledge Archive

## 6.1 MemSync Persistence Chamber

**Responsibility:** represent persistence and synchronization of distilled knowledge across sessions and supported environments.

### Primary feature

**MemSync Cross-Session Persistence Engine**

### Spatial mechanism

**MemSync Status Board**

Displays:

- knowledge state version
- synchronization state
- replication status
- state hashes
- sync timestamps
- conflict state

The interface must distinguish local persistence, distributed synchronization, and unresolved conflicts.

---

# 7. Hierarchical Skill Garden

## 7.1 Purpose

Represent how small operational skills combine into larger competencies.

### Primary feature

**Hierarchical Skill Taxonomy Weaver**

Example conceptual hierarchy:

**Level 0 — Atomic**
- individual tool/action

**Level 1 — Compound**
- composed execution sequence

**Level 2 — Strategic**
- domain-level reusable policy

### Spatial mechanism

**Skill Hierarchy Visualizer**

Users can move from:

**Strategic Competency → Compound Skill → Atomic Action**

without losing provenance.

---

# 8. Reflection & Policy Evolution Chamber

## 8.1 Reflection-Driven Policy Synthesizer

When validated execution failures are available, Viveda can analyze the failure trajectory and derive candidate negative constraints or refinement rules.

### Spatial mechanism

**Policy Evolution Log**

Shows:

- triggering evidence
- observed failure
- inferred anti-pattern
- proposed constraint
- validation status
- affected knowledge domain
- resulting schema version

The system must not imply that every failure automatically produces a permanent policy.

---

# 9. Schema Versioning Archive

## 9.1 Ontological Schema Version Control

Viveda maintains versioned representations of domain ontologies.

### Spatial mechanism

**Schema Versioning Drawer**

Displays:

- active version
- historical versions
- breaking changes
- migration contracts
- dependent components
- compatibility status

Conceptual version path:

**v1.0 → v1.1 → v2.0**

Historical records remain inspectable even after migration.

---

# 10. Viveda Collaboration Network

Primary relationships:

### Viveda ↔ Medrus
**Evidence → Knowledge**

Medrus provides validated evidence and execution history. Viveda abstracts recurring patterns.

### Viveda ↔ Manis
**Challenge → Refinement**

Manis stress-tests generalized knowledge. Viveda refines or limits the abstraction when evidence warrants it.

### Viveda ↔ Bodhex
**Knowledge → Tool Contract**

Validated knowledge can become typed tool or execution contracts where the implementation supports this pathway.

### Viveda ↔ Tarkis
**Reusable Knowledge → Reasoning Context**

Validated knowledge may be supplied to reasoning workflows under explicit transfer conditions.

---

# 11. Challenge & Review Quarter — Manis’s Human Challenge Home

## 11.1 Resident

**Manis**

### Primary responsibility

Human Assumption Stress-Testing, Cognitive Friction Injection, Red-Teaming, Anti-Sycophancy, Automation-Bias Mitigation, Tool-Misuse Detection, and Human Oversight.

Manis exists as an intentionally independent challenge function.

His purpose is not to generate disagreement for entertainment. His purpose is to expose assumptions, boundary failures, unsafe shortcuts, and unexamined dependence on automation.

---

# 12. Key Questions

The Challenge Home must allow inspection of:

- What assumptions are hidden inside the current plan?
- Does the user's literal instruction match the broader contextual objective?
- What happens if a critical assumption is false?
- Is the system agreeing merely because agreement is easier?
- Could automation cause the human to overlook an important condition?
- Has a previously validated rule become stale?
- Could a tool request exceed its permitted scope?
- Does a proposed action require explicit human confirmation?
- Do automated evaluation metrics match expert human judgment?
- Can a multi-turn interaction gradually drift into an invalid state?

---

# 13. Challenge Home Spatial Structure

## 13.1 Challenge Hall

Public entry point for Manis.

Displays:

- active challenges
- unresolved assumptions
- pending human checkpoints
- current red-team activity
- rule challenges
- tool-scope warnings
- metric disagreements
- operator vigilance indicators

---

## 13.2 Assumption Stress Chamber

**Responsibility:** expose hidden assumptions.

### Primary feature

**Unstated Assumption Stress-Tester**

Manis extracts assumptions from proposed plans and produces test vectors.

Examples of assumption categories:

- access assumptions
- data availability
- environmental stability
- user behavior
- permission scope
- resource availability
- temporal assumptions

### Spatial mechanism

**Assumption Blindspot Board**

Each assumption links to:

**Assumption → Evidence → Vulnerability → Test → Result**

---

## 13.3 Intent Realignment Chamber

**Responsibility:** compare literal instruction with contextual objective.

### Primary feature

**Human Intent Realignment Engine**

Uses Dharen's active context frame as a comparison boundary.

### Spatial mechanism

**Literal vs. True Intent Split View**

Left:

**Literal Instruction**

Right:

**Contextual Objective**

Center:

**Detected Alignment / Mismatch**

The system should present this as a challenge or proposed interpretation, not as an unquestionable statement of what the human "really" wants.

---

# 14. Socratic Friction Gate

## 14.1 Purpose

Introduce meaningful human review before consequential actions.

### Primary feature

**Socratic Friction Gate & HITL Interceptor**

For designated high-impact operations, Manis can pause execution and expose:

- proposed action
- reason for intervention
- relevant risk
- affected scope
- fallback path
- required human verification

### Spatial mechanism

**Socratic Override Gate**

The checkpoint must provide an explicit human decision boundary rather than a decorative warning.

---

# 15. Anti-Dogma Knowledge Audit

## 15.1 Manis ↔ Viveda Protocol

Manis audits generalized rules retained by Viveda.

### Process

**Stored Rule → New Evidence → Challenge → Boundary Test → Pass / Refine / Retire**

### Spatial mechanism

**Dogma Challenge Board**

Displays:

- challenged rule
- supporting history
- new conflicting evidence
- challenge reason
- Viveda response
- resulting refinement status

This makes knowledge evolution inspectable rather than invisible.

---

# 16. Anti-Sycophancy Observatory

## 16.1 Anti-Sycophancy Policy Engine

Manis checks whether a response path is accepting a false or unsupported premise without sufficient challenge.

### Spatial mechanism

**Sycophancy Guardrail Indicator**

Possible state:

**SKEPTICAL_ENGAGEMENT**

The indicator links to the underlying premise and evidence rather than merely labelling the response as biased.

---

# 17. Multi-Turn Adversarial Drift Chamber

## 17.1 Purpose

Test whether gradual conversational changes create cumulative logical or policy drift.

### Primary feature

**Multi-Turn Adversarial Drift Simulator**

### Spatial mechanism

**Conversational Drift Map**

Shows:

**Current State → Potential Drift → Vulnerability → Boundary**

It must clearly distinguish:

- observed conversation state
- simulated future branch
- detected vulnerability
- confirmed failure

---

# 18. Automation Bias Interrupter

## 18.1 Purpose

Reduce blind acceptance of automated outputs in designated high-impact situations.

### Primary feature

**Automation Bias Interrupter**

### Spatial mechanism

**Cognitive Friction Gate**

The user is presented with the relevant verification boundary before approval.

The interface should avoid unnecessary interruptions for low-impact actions. The purpose is meaningful oversight, not approval fatigue.

---

# 19. Rule Generalization Stress-Test Canvas

## 19.1 Manis ↔ Viveda Dynamic

Every candidate generalized rule can be subjected to:

- counterfactual cases
- inverse scenarios
- edge conditions
- noisy inputs
- out-of-distribution cases

### Spatial mechanism

**Rule Stress-Test Canvas**

Displays:

**Viveda Rule → Manis Test Cases → Pass/Fail → Boundary Refinement**

This directly connects the Knowledge Quarter with the Challenge & Review Quarter.

---

# 20. CRM-Style Challenge Protocol

## 20.1 Structured Human Oversight

For designated high-impact operations, Manis can create a structured briefing checkpoint.

### Spatial mechanism

**Cockpit Briefing Drawer**

Contains:

- proposed action
- scope
- potential expansion
- abort conditions
- human verification requirement
- checkpoint status

The aviation-inspired metaphor is an HCI representation for explicit challenge-and-response, not a claim that Criterivox is an aviation system.

---

# 21. SME Metric Alignment Chamber

## 21.1 Purpose

Compare automated evaluation with human expert judgement where human-labelled evaluation is available.

### Primary feature

**SME Human Metric Alignment Engine**

### Spatial mechanism

**Metric Alignment Heatmap**

Shows:

**Automated Score ↔ Human Label → Alignment Delta**

The system should preserve the distinction between an automated evaluator and an actual human assessment.

---

# 22. Tool Misuse & Scope Observatory

## 22.1 Purpose

Inspect whether planned tool execution exceeds declared permissions or intended scope.

### Primary feature

**Agentic Tool Misuse & Scope Expansion Scanner**

### Spatial mechanism

**Scope Violation Shield**

Displays:

- requested tool
- declared permission
- requested parameters
- detected expansion
- affected data/resource
- block/allow state

Possible event:

`TOOL_MISUSE_BLOCKED`

only when the runtime actually implements that event.

---

# 23. Operator Vigilance Observatory

## 23.1 Purpose

Represent patterns of human interaction with automated checkpoints.

### Primary feature

**Automation Complacency Breaker**

The system can identify repeated rapid approvals or other configured signals that may warrant additional verification.

### Spatial mechanism

**Operator Vigilance Index**

Potential measurements:

- approval interval
- review duration
- checkpoint engagement
- verification frequency
- skipped inspection steps

These are interaction metrics, not psychological diagnoses.

---

# 24. Manis Functional Matrix

| Feature | Primary Function | Machine / System Output |
|---|---|---|
| Assumption Stress-Tester | Exposes hidden assumptions | Assumption Test Vectors |
| Intent Realignment | Compares instruction with contextual objective | Intent Alignment / Challenge Payload |
| Socratic Friction Gate | Creates explicit human checkpoint | Checkpoint State |
| Anti-Dogma Audit | Challenges stale generalized knowledge | Knowledge Challenge Record |
| Anti-Sycophancy Engine | Detects unsupported premise acceptance | Premise Challenge |
| Adversarial Drift Simulator | Tests multi-turn trajectory drift | Drift Graph / Vulnerability Record |
| Automation Interrupter | Prevents blind high-impact approval | Verification Checkpoint |
| Rule Stress-Tester | Tests generalized rules against edge cases | Boundary Test Results |
| CRM Challenge Protocol | Structures high-impact human review | Briefing / Abort Conditions |
| SME Metric Alignment | Compares automated and human evaluation | Alignment Delta |
| Tool Misuse Scanner | Detects permission/scope expansion | Scope Violation Record |
| Complacency Breaker | Detects repeated low-engagement approvals | Vigilance Metrics |

---

# 25. Cross-Quarter Knowledge ↔ Challenge Network

The two areas form a deliberate feedback loop:

**Medrus**
→ validated evidence

**Viveda**
→ generalized knowledge

**Manis**
→ challenge and boundary testing

**Viveda**
→ refined knowledge

**Tarkis / downstream reasoning**
→ contextual reuse

**Real execution**
→ new evidence

The loop is therefore:

**EVIDENCE → KNOWLEDGE → CHALLENGE → REFINEMENT → REUSE → NEW EVIDENCE**

This is a knowledge lifecycle, not a rigid sequential execution chain. Anukor may route information dynamically through the network.

---

# 26. Bloom Relationship

The Bloom remains the global spatial nexus defined in Level 2 Part I/II.

Part III does not duplicate Bloom functionality.

From the Knowledge Quarter, the Bloom may provide access to:

- knowledge activity state
- schema-change events
- transfer activity
- skill validation state
- knowledge lineage

From the Challenge & Review Quarter, the Bloom may provide access to:

- active challenge state
- human checkpoint state
- scope warnings
- rule stress-test activity
- unresolved review state

The Bloom is therefore the **global view**, while each Home remains the **deep inspection space**.

---

# 27. Human Intervention Boundaries

Human intervention is meaningful at clearly defined boundaries.

### Knowledge Quarter

Human may inspect:

- proposed generalized rule
- ontology mutation
- skill package
- schema migration
- deprecation proposal
- transfer candidate

### Challenge & Review Quarter

Human may inspect:

- assumption challenge
- intent mismatch
- high-impact checkpoint
- scope violation
- rule challenge
- automated/human metric disagreement

The system must avoid forcing the human to inspect every low-impact event.

---

# 28. Shared Character State Presentation

Both residents use the established semantic state model:

**IDLE → RECEIVE → WORK → COMMUNICATE → HANDOFF → COMPLETE → IDLE**

Warnings use:

**WARNING**

Attention states may include:

**QUIET, ATTENTIVE, FOCUSED, BUSY, WAITING, NEEDS_USER, COMPLETING, RECOVERING**

### Viveda examples

- RECEIVE — evidence package arrives
- WORK — distillation or schema construction
- COMMUNICATE — knowledge package prepared
- HANDOFF — sends validated knowledge onward
- WARNING — schema conflict or validation failure

### Manis examples

- RECEIVE — plan or rule arrives for challenge
- WORK — stress-test executes
- COMMUNICATE — challenge result prepared
- NEEDS_USER — human checkpoint required
- WARNING — scope or assumption violation detected

Animations must represent real semantic state. Decorative motion must not imply hidden computation.

---

# 29. Accessibility & Age-Progressive HCI

The same spatial world supports progressive depth.

### Entry level

Users understand:

- Viveda learns and organizes knowledge.
- Manis checks assumptions and challenges decisions.

### Intermediate level

Users can inspect:

- evidence-to-rule relationships
- challenge-to-refinement loops
- skill hierarchies
- checkpoints
- knowledge versions

### Advanced level

Users can inspect:

- ontology mutations
- provenance
- schema contracts
- transfer conditions
- adversarial test graphs
- metric alignment
- policy evolution
- permission boundaries

Accessibility requirements:

- every visual state has text/status equivalents
- reduced-motion mode
- keyboard/focus navigation
- non-colour-only status indicators
- readable graph labels
- explicit checkpoint status
- no critical information conveyed solely through animation

---

# 30. Runtime Truth Contract

The UI must distinguish four states:

**LIVE** — connected to implemented runtime behavior.

**SIMULATED** — demonstrative behavior with no production backend.

**PLANNED** — designed but not implemented.

**RESEARCH PROTOTYPE** — experimental implementation under evaluation.

Examples of capabilities that require explicit implementation before being shown as LIVE:

- MemSync
- autonomous ontology mutation
- executable skill compilation
- automatic heuristic decay
- cross-device synchronization
- adversarial drift simulation
- automated SME metric recalibration
- operator vigilance detection
- tool-scope blocking

This prevents the world map from becoming a collection of fictional backend claims.

---

# 31. Research & HCI Gain

Level 2 Part III adds a spatial representation of the **knowledge-validation loop**.

### 1. Knowledge becomes inspectable

Users can physically navigate from evidence-derived patterns to reusable schemas and skills.

### 2. Generalization becomes challengeable

Manis provides a dedicated spatial counter-function to Viveda's abstraction.

### 3. Learning becomes traceable

The path:

**Evidence → Pattern → Rule → Challenge → Refinement**

can be represented spatially.

### 4. Reuse becomes explainable

Transfer candidates expose their structural relationship rather than appearing as unexplained recommendations.

### 5. Knowledge decay becomes visible

Deprecated or degraded knowledge becomes an observable lifecycle state.

### 6. Human oversight becomes spatial

Critical intervention points become places in the world rather than arbitrary popups.

### 7. Agent collaboration becomes understandable

Viveda's relationships with Medrus, Manis, Tarkis, and Bodhex become navigable system relationships.

### 8. Research becomes testable

The spatial model creates potential HCI evaluation dimensions:

- knowledge comprehension
- provenance comprehension
- challenge discoverability
- intervention efficiency
- trust calibration
- cognitive load
- error recovery
- understanding of automation boundaries

---

# 32. Acceptance Criteria

Part III is structurally complete when:

- [ ] Viveda is located in the **Knowledge Quarter**.
- [ ] Manis is located in the **Challenge & Review Quarter**.
- [ ] Legacy numeric Home labels are absent from the Level-2 spatial naming.
- [ ] Viveda's rooms map to knowledge responsibilities.
- [ ] Manis's rooms map to challenge and oversight responsibilities.
- [ ] Medrus ↔ Viveda evidence-to-knowledge flow is represented.
- [ ] Viveda ↔ Manis challenge-to-refinement flow is represented.
- [ ] Viveda ↔ Bodhex tool-contract relationship is represented without claiming unimplemented functionality.
- [ ] Dharen ↔ Manis context/challenge relationship is represented.
- [ ] Bloom remains the global nexus rather than being duplicated inside either Home.
- [ ] Human intervention boundaries are explicit.
- [ ] Character states remain semantically grounded.
- [ ] LIVE / SIMULATED / PLANNED / RESEARCH PROTOTYPE distinctions are preserved.
- [ ] Accessibility and progressive-disclosure requirements are represented.
- [ ] No character is presented as having independent intelligence outside the underlying module responsibility.

---

# 33. Boundary With Level 2 Part IV

Level 2 Part III defines the internal spatial-functional model for:

**Knowledge Quarter + Challenge & Review Quarter**

It does not define:

- additional quarters not covered by this part
- new character responsibilities
- final implementation architecture
- production backend capabilities
- character dialogue/scripts
- final visual assets
- animation implementation
- detailed code-level contracts

Those belong to later implementation or specification layers.

---

# 34. Canonical Level 2 Part III Model

**CRITERIVOX WORLD**

→ **Gate 1 — Criterivox Civilization**

→ **Knowledge Quarter**
- **Viveda**
- Knowledge Hall
- Trajectory Distillation Workshop
- Ontology Weaver
- Structural Transfer Chamber
- Rule Friction Chamber
- Skill Library
- Skill Packaging Studio
- Ontology Mutation Observatory
- Schema Translation Terminal
- Knowledge Utility Observatory
- Skill Health & Decay Observatory
- MemSync Persistence Chamber
- Hierarchical Skill Garden
- Reflection & Policy Evolution Chamber
- Schema Versioning Archive

→ **Challenge & Review Quarter**
- **Manis**
- Challenge Hall
- Assumption Stress Chamber
- Intent Realignment Chamber
- Socratic Friction Gate
- Anti-Dogma Knowledge Audit
- Anti-Sycophancy Observatory
- Multi-Turn Adversarial Drift Chamber
- Automation Bias Interrupter
- Rule Generalization Stress-Test Canvas
- CRM Challenge Protocol
- SME Metric Alignment Chamber
- Tool Misuse & Scope Observatory
- Operator Vigilance Observatory

→ **The Bloom**
- Global navigation
- Global telemetry
- Cross-home activity
- Provenance/lineage access
- Human intervention signalling

### Core Part III Loop

**MEDRUS → VIVEDA → MANIS → VIVEDA → DOWNSTREAM REUSE → REAL RESULT → MEDRUS**

### Human-facing interpretation

**Observe → Generalize → Challenge → Refine → Reuse → Verify**

This is the internal spatial model for Level 2 Part III.
