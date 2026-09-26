# Criterivox World Map — Level 2, Part II

## Gateway Quarter, The Bloom, Data Stewardship Quarter & Context Quarter — Internal Functional-Spatial Specification

### Document Status

- **Project:** Criterivox
- **Layer:** Internal World Map / Level 2
- **Part:** II
- **Scope:** Functional-spatial definition of the first four operational homes and the central Bloom nexus
- **Audience:** Product, UX/HCI, architecture, research, implementation and evaluation
- **Status:** Internal specification
- **Relationship:** Extends Level 2 Part I; does not replace it
- **Implementation truth:** A feature described here is a design requirement/candidate until its backend contract, runtime behavior and tests exist.

---

# 1. Purpose

Level 2 Part II translates the Criterivox role architecture into inspectable spatial workplaces.

It defines:

1. **Gateway Quarter — Syvax’s Interaction & Gateway Home**
2. **The Bloom — Central Spatial and Operational Nexus**
3. **Data Stewardship Quarter — Sandre & Kaelen’s Data Foundation Home**
4. **Context Quarter — Dharen & Anuka’s Context Home**

The objective is not to turn backend services into decorative buildings. Each room, workstation, visual signal and transition must expose a real system responsibility or a clearly labelled simulation.

> **Spatial principle:** If a user can see, enter or manipulate something, the system should be able to explain what invisible computational or interaction concept that thing represents.

---

# 2. Relationship to Level 2 Part I

Level 2 Part I established:

**World Entry → Roster → Supervision → Network Inspection → Guest Evaluation**

Part II moves from the global supervisory view into the first operational homes.

The resulting progression is:

**World → Roster → Home → Room → Active Task → Data/Context → Routing → Human Intervention → Evidence of State**

Part II therefore defines the operational layer beneath the Level 1 world map and above implementation-specific UI components.

---

# 3. Canonical Home Map

| Home | Resident(s) | Primary Responsibility | Main Boundary |
|---|---|---|---|
| Data Stewardship Quarter | Sandre + Kaelen | Data foundation, stewardship, ingestion and transformation | Raw data → validated/structured data |
| Context Quarter | Dharen + Anuka | Context framing, adaptation and scope control | Data/task → usable context |
| Gateway Quarter | Syvax | Human interaction, reception, routing and output translation | Human ↔ Criterivox |
| Bloom | Shared nexus, no conventional resident | Spatial navigation, cross-home visibility and operational coordination | Home ↔ Home |

**Anukor is not assigned to a Home.** He remains a network-layer resident operating across the spatial system.

---

# 4. Gateway Quarter — Syvax’s Interaction & Gateway Home

## 4.1 Identity

**Resident:** Syvax  
**Role:** Interaction, dialogue, orchestration and gateway  
**Primary Focus:** Human-machine dialogue, interface orchestration, task reception, routing and output translation.

The Gateway Quarter is the primary human-system boundary.

Syvax functions conceptually as:

- reception desk
- interaction gateway
- task intake point
- routing coordinator
- output translator
- human intervention channel
- interaction safety boundary

The home must therefore feel **open, legible and responsive**, rather than like a backend server room.

---

# 5. Home 03 — Key HCI Questions

### 5.1 Intent Disambiguation

What is the user actually trying to accomplish?

### 5.2 Cognitive Load Management

How can multi-character execution be understandable without exposing unnecessary technical trace data?

### 5.3 Adaptive Output

How should the result be presented for the current task?

Examples:

- conversational response
- structured cards
- table
- graph
- evidence view
- code-oriented workspace
- decision comparison

### 5.4 Human Steering

Can the user pause, redirect, constrain or stop active execution without restarting the entire task?

### 5.5 System Transparency

Can the user understand:

- what was received
- what was interpreted
- which homes are active
- what state the system is in
- what requires human intervention
- what has completed

---

# 6. Home 03 Spatial Structure

The Gateway Quarter should be organized around a central reception/workspace with secondary inspection areas.

### Primary Spaces

1. **Syvax Reception**
   - primary conversation/input area
   - human-facing character position

2. **Routing Radar Wall**
   - active task routing
   - participating homes
   - current execution state

3. **Dialogue Archive**
   - conversation history
   - branch navigation
   - session snapshots

4. **Universal Intake Desk**
   - text
   - image
   - document
   - audio
   - structured payloads

5. **UI Workbench**
   - generated task-specific output components

6. **Steering Console**
   - pause
   - redirect
   - modify constraints
   - resume
   - stop

7. **Safety Station**
   - validation and guardrail status

8. **Bloom Connection**
   - visible connection to the central nexus

---

# 7. Home 03 Functional Features

## 7.1 Generative Intent Dispatcher & Routing Matrix

### Purpose

Transform a raw user request into an explicit, inspectable task-routing representation.

### Functional behavior

Syvax receives the request and determines:

- detected goal
- relevant task type
- required context
- required data
- candidate downstream homes
- execution dependencies
- human checkpoints

### Spatial representation

A **Task Routing Radar** appears near Syvax.

Example conceptual route:

**Syvax → Dharen → Tarkis → Medrus → Syvax**

The visualization represents actual runtime routing when available.

Simulated routing must be explicitly labelled.

### Output contract

Potential structured representation:

- task ID
- intent class
- extracted goal
- constraints
- required capabilities
- route
- checkpoint policy
- execution status

---

# 8. Adaptive Human-Centric Output Renderer

## Purpose

Translate completed internal outputs into a representation suitable for the user's current task.

### Possible presentation modes

- Executive Summary
- Detailed Evidence / Decision Lineage
- Structured Data
- Interactive Visualization
- Code Workspace
- Raw Machine Payload

### Important boundary

A **Detailed Reasoning Tree** must not expose private chain-of-thought.

It should expose structured, auditable information such as:

- claims
- evidence
- assumptions
- decision factors
- tool results
- validation states
- rejected alternatives where intentionally recorded
- provenance

### Spatial component

**Syvax’s Lens / View Mode Switcher**

The user can change representation without changing the underlying result.

---

# 9. Mid-Flight Human-in-the-Loop Steering

## Purpose

Give the user control over active execution.

### Controls

- Pause
- Add constraint
- Correct goal
- Redirect
- Approve
- Reject
- Resume
- Stop

### Spatial component

**Steering Console**

The active pipeline remains visible while the user inserts an intervention.

### Runtime requirement

A pause button is only truthful if the backend can actually suspend or safely checkpoint the corresponding workflow.

If the implementation cannot interrupt execution, the interface must not pretend that it can.

---

# 10. System Telemetry & Silence Translator

## Purpose

Translate system activity into human-readable status rather than raw infrastructure logs.

### Example status semantics

- Receiving request
- Structuring context
- Checking evidence
- Comparing alternatives
- Waiting for another home
- Awaiting human input
- Recovering from an error
- Completing

### Spatial component

A **Living Status Ticker** appears beneath or beside Syvax.

### Design rule

The ticker should communicate meaningful state, not produce constant chatter.

Silence can be represented as:

**Working quietly · next update when a meaningful state changes**

rather than fabricated activity.

---

# 11. Dialogue History & Conversation Branch Management

## Purpose

Represent non-linear problem solving without forcing every experiment into one linear transcript.

### Spatial component

**Conversation Tree Navigator**

Each branch may record:

- originating turn
- changed input
- active characters
- context snapshot
- resulting state
- branch status

### Supported operations

- open branch
- fork branch
- compare branch
- return to parent
- archive branch
- continue branch

Branching must preserve lineage so the user knows which state produced which result.

---

# 12. Multi-Modal Reception & Payload Ingestion

## Purpose

Provide one human-facing intake boundary for heterogeneous input.

### Supported conceptual payload classes

- text
- images
- documents
- audio
- structured data
- code snippets

### Spatial component

**Universal Dropzone**

Visual indicators should show:

- file type
- ingestion state
- validation state
- destination
- failure state

Validated data may be handed to Sandre for data processing.

---

# 13. Dynamic UI Intent Synthesizer

## Purpose

Allow Syvax to present output through task-appropriate interface components.

### Possible generated components

- comparison tables
- parameter controls
- flow diagrams
- evidence cards
- timelines
- decision matrices
- structured forms

### Spatial component

**UI Workbench**

The workbench is not an unrestricted code-generation surface. Components must be constrained by an approved rendering schema and validated before presentation.

---

# 14. Systemic Safety & Guardrail Inspector

## Purpose

Perform pre-execution checks at the human-system boundary.

### Checks may include

- malformed input
- contradictory constraints
- unsafe or disallowed operations
- prompt-injection indicators
- unavailable capability requests
- scope violations

### Spatial component

**Safety Shield**

States:

- CLEAR
- CHECKING
- WARNING
- BLOCKED
- NEEDS_USER

The system should explain the category of the problem without exposing hidden security rules or internal secrets.

---

# 15. Home 03 Functional Matrix

| Capability | Human Sees | Machine Output |
|---|---|---|
| Intent Dispatch | Routing Radar | Structured task plan |
| Output Rendering | View Mode Switcher | Presentation specification |
| HITL Steering | Steering Console | Control/intervention event |
| Telemetry Translation | Status Ticker | Semantic state event |
| Conversation Branching | Conversation Tree | Branch/session lineage |
| Multimodal Intake | Universal Dropzone | Normalized payload |
| Dynamic UI | UI Workbench | Validated UI component spec |
| Safety | Safety Shield | Validation/guardrail result |

---

# 16. The Bloom — Central Nexus

## 16.1 Identity

**The Bloom** is the central spatial nexus of Criterivox civilization.

It has three simultaneous functions:

1. **Navigation**
2. **System observability**
3. **Cross-home interaction representation**

It is not a replacement for Anukor.

- **Anukor** performs network-layer routing.
- **The Bloom** makes relevant routing and system activity spatially understandable to humans.

The Bloom therefore acts as the **human-observable spatial heartbeat**, while Anukor remains the network-layer connective mechanism.

---

# 17. The Bloom Spatial Model

The Bloom contains:

- central core
- eight Home petals
- connecting vine pathways
- activity indicators
- checkpoint indicators
- provenance access
- timeline access
- oversight controls

Each petal corresponds to a Home.

Anukor is represented through the connecting network rather than as a ninth conventional Home.

---

# 18. Petal Teleportation Matrix

## Purpose

Provide direct spatial navigation to Homes.

### Interaction

- hover/focus → preview
- select → destination confirmation/transition
- enter → Home view

### Accessibility

The same destination must be available through:

- keyboard navigation
- semantic labels
- text navigation
- reduced-motion transition

Teleportation is a spatial metaphor for navigation, not literal movement of a backend process.

---

# 19. Bioluminescent Civilization Pulse

## Purpose

Provide a glanceable representation of system state.

### Suggested semantic states

| Bloom State | Meaning |
|---|---|
| Soft steady | Idle/standby |
| Active pulse | Work occurring |
| Connected pulse | Cross-home execution |
| Amber attention | Human attention required |
| Warning state | System or evidence issue |
| Recovery state | System recovering |

### Important correction

Do not use color alone to encode confidence, uncertainty or errors.

Every state requires:

- icon/shape
- text label
- semantic status
- accessible announcement where appropriate

---

# 20. Seed Allocation & Context Distribution

The original metaphor of **Light Seeds** represents context/data movement through the spatial model.

### System meaning

A seed may represent:

- context envelope
- task handoff
- validated payload
- event
- provenance reference

### Runtime rule

Seeds should animate only when an actual corresponding event exists.

If the visualization is illustrative, label it as simulation.

---

# 21. Petal Human-in-the-Loop Checkpoints

## Purpose

Surface moments where the user must make an intervention.

### Bloom behavior

The affected petal enters:

**ATTENTION → NEEDS_USER**

The user can inspect:

- action proposed
- evidence available
- uncertainty
- relevant constraints
- consequence
- available choices

### Actions

- Approve
- Edit
- Reject
- Defer

The Bloom should provide a compact checkpoint view without forcing the user into the entire Home.

---

# 22. Cross-Home Context Sprouting

## Purpose

Represent actual multi-home execution paths.

Example:

**Syvax → Dharen → Tarkis → Medrus**

### Spatial mechanism

Vine paths connect participating petals.

Selecting a path may reveal structured metadata such as:

- source
- destination
- event type
- timestamp
- payload identifier
- state
- latency, if actually measured
- failure state

Do not expose arbitrary private model internals.

---

# 23. Living Portal Preview

## Purpose

Allow users to understand a Home before entering it.

### Preview may contain

- resident
- responsibility
- current state
- active task
- relevant room
- simplified activity snapshot

### Rule

A preview is not a second full application.

It is a **context-preserving spatial preview**.

---

# 24. Pollen Dust Ledger — Provenance View

## Purpose

Provide provenance access from the central nexus.

Pollen represents recorded provenance events.

### Provenance stream may include

- source
- transformation
- validation
- claim
- evidence reference
- timestamp
- responsible component
- status

### Important distinction

The provenance stream records **auditable system events and evidence lineage**, not hidden chain-of-thought.

Epistre remains responsible for evidence/verification functions.

---

# 25. Dynamic Petal Energy Allocation

## Purpose

Represent resource budgets at the Home level.

### Potential controls

- token budget
- execution budget
- iteration limit
- time budget
- tool-use limit

### Runtime requirement

A visual budget control is valid only when the backend actually enforces the selected bound.

Changing a decorative ring without changing execution constraints is not resource allocation.

---

# 26. Pollen-Dust Evaluator

## Purpose

Detect and surface anomalies during execution.

### Possible anomaly classes

- payload mismatch
- context conflict
- failed tool call
- validation failure
- unexpected state transition
- confidence/evidence degradation where such metrics are genuinely available

### Spatial response

A provenance particle or edge enters an attention state and opens a **Step Diagnostic**.

The diagnostic should show the observable event and relevant evidence, not private internal reasoning.

---

# 27. Bloom Checkpointing & Time Replay

## Purpose

Allow inspection and controlled branching from recorded workflow checkpoints.

### Checkpoint should contain

- workflow/session ID
- timestamp
- context version
- task state
- participating homes
- recorded outputs
- provenance references
- checkpoint identifier

### Replay boundary

Replay means reconstructing or reloading recorded state.

It must not be represented as magical reversal of irreversible external actions.

External side effects require explicit safeguards.

---

# 28. Non-Fatiguing Oversight Radar

## Purpose

Support graduated human oversight.

### Modes

**Guided Mode**
- explicit intervention at configured checkpoints

**Monitored Mode**
- system proceeds within preapproved boundaries
- human receives attention only when configured conditions occur

The interface may call these HITL/HOTL internally, but public-facing terminology should prioritize understandable labels.

### Rule

Oversight level must be tied to actual workflow policy, not only a visual toggle.

---

# 29. The Bloom Functional Matrix

| Bloom Capability | Human Value | Runtime Dependency |
|---|---|---|
| Petal Navigation | Spatial discoverability | Home registry |
| System Pulse | Global state comprehension | Semantic runtime state |
| Context Seeds | Handoff visibility | Event/handoff stream |
| HITL Checkpoints | Timely intervention | Suspend/checkpoint mechanism |
| Flow Vines | Workflow observability | Trace/event data |
| Portal Preview | Context-preserving navigation | Home preview state |
| Provenance Pollen | Evidence lineage | Provenance ledger |
| Energy Ring | Resource transparency | Enforced budget |
| Pollen Evaluator | Mid-run diagnosis | Evaluation/anomaly events |
| Time Replay | Debugging/branching | Durable checkpoints |
| Oversight Radar | Agency control | Workflow policy engine |

---

# 30. Data Stewardship Quarter — Sandre & Kaelen’s Data Foundation Home

## 30.1 Identity

**Residents:** Sandre + Kaelen

- **Sandre:** Data Steward
- **Kaelen:** Data Builder

### Primary Focus

- ingestion
- storage
- quality
- privacy
- metadata
- lineage
- transformation
- pipeline infrastructure
- data readiness

Home 01 is the point where raw incoming information becomes a controlled, inspectable foundation for downstream context and intelligence.

---

# 31. Home 01 Spatial Structure

### Primary Spaces

1. **Sandre’s Stewardship Hall**
   - quality
   - validation
   - privacy
   - anomaly monitoring

2. **Kaelen’s Pipeline Workshop**
   - transformation
   - schema mapping
   - DAG construction
   - streaming pipelines

3. **Lineage Archive**
   - source history
   - transformations
   - timestamps
   - hashes/references

4. **Semantic Catalog**
   - field definitions
   - metadata
   - constraints
   - machine-readable descriptions

5. **Quality Gate**
   - evaluation results
   - warnings
   - quarantine state

6. **Multimodal Ingestion Bay**
   - text
   - image
   - audio
   - structured data

---

# 32. Dynamic Data Readiness Profiling

## Purpose

Determine whether incoming data is suitable for downstream processing.

### Possible measurements

- completeness
- schema alignment
- duplicate rate
- anomaly indicators
- missing fields
- validation status

### UI

**Data Quality Indicator**

A numeric score should only be displayed when based on a defined evaluation procedure.

Avoid arbitrary thresholds such as 85% unless research and implementation explicitly establish and validate that threshold.

---

# 33. Kaelen’s Pipeline Construction Canvas

## Purpose

Expose data transformation as a visible workflow.

### UI

A visual DAG showing:

**Input → Validation → Transformation → Enrichment → Output**

### Schema change behavior

When drift is detected:

**Detect → Compare → Propose Mapping → Validate → Apply/Reject**

Automatic repair must remain reviewable.

---

# 34. Epistemic Data Lineage & Provenance Ledger

## Purpose

Preserve reconstructable history.

### Record

- origin
- timestamp
- transformation
- responsible process
- version
- integrity identifier
- destination

### UI

**Timeline Rewind**

Users inspect prior recorded states without implying that the underlying external source itself has been reversed.

---

# 35. Synthetic Data & Edge Caching

Synthetic data may support:

- privacy-preserving tests
- sparse-data testing
- pipeline validation
- failure simulation

The UI must clearly distinguish:

**REAL DATA / SYNTHETIC DATA / SIMULATED DATA**

Synthetic records must never be presented as real-world observations.

---

# 36. Context Engineering & Semantic Tagging

Sandre enriches validated data with machine-readable metadata.

### Metadata may describe

- field meaning
- temporal scope
- units
- relationships
- constraints
- provenance
- sensitivity
- confidence/validation status where defined

### UI

**Semantic Inspector**

Selecting a field exposes its machine-readable interpretation and lineage.

---

# 37. Schema Drift Interceptor & Repair

## Flow

**Observe → Detect Drift → Diff → Map → Validate → Approve/Apply → Record**

### UI

**Schema Patch Diff**

Displays:

- previous schema
- current schema
- changed fields
- proposed mapping
- unresolved fields
- validation state

Automatic remediation should not silently overwrite the source structure.

---

# 38. Multimodal Vector/Lakehouse Ingestion

The architecture may support:

- chunking
- embedding
- indexing
- retrieval metadata
- multimodal references

### UI

**Embedding / Indexing View**

The visualization should explain that clusters are representations of encoded data, not human-interpretable semantic truth by themselves.

---

# 39. Evaluation-Driven Data Quality Gates

## Purpose

Move beyond simple structural validation.

### Gate layers

1. structural validity
2. semantic validity
3. anomaly detection
4. transformation validation
5. evaluation against defined expectations

### Gate states

- PASS
- REVIEW
- FAIL
- QUARANTINED

---

# 40. Home 01 Functional Matrix

| Character | Responsibility | Main Outputs |
|---|---|---|
| Sandre | Stewardship, validation, privacy, quality | Validated payloads, quality status, lineage |
| Kaelen | Transformation, pipeline construction, schema repair | Structured datasets, transformation graphs, repaired mappings |

---

# 41. Context Quarter — Dharen & Anuka’s Context Home

## 41.1 Identity

**Residents:** Dharen + Anuka

- **Dharen:** Context Master / Scope Boundary Control
- **Anuka:** Context Adaptor / Situational Management

### Primary Focus

- context structuring
- problem framing
- scope boundaries
- context compression
- situational adaptation
- context isolation
- context conflict detection
- working-state persistence

Home 02 transforms validated information into a context structure that downstream intelligence can actually operate against.

---

# 42. Home 02 Spatial Structure

### Primary Spaces

1. **Dharen’s Context Chamber**
   - context framing
   - hierarchy
   - scope boundaries

2. **Anuka’s Adaptation Desk**
   - context changes
   - drift
   - situation changes

3. **Context Topology Room**
   - hierarchical context graph
   - dependency visualization

4. **Context Sandbox**
   - isolated transient states
   - shadow tests
   - counterfactual branches

5. **Working Memory Desk**
   - scratchpad
   - checkpoints
   - active variables

6. **Context Sanity Gate**
   - clash detection
   - poisoning detection
   - constraint validation

---

# 43. Dynamic Context Pruning & Attentive Compression

## Purpose

Reduce irrelevant context while retaining required information.

### UI

**Context Density Gauge**

Can display:

- source size
- retained content
- removed/reduced content
- critical elements retained
- compression method/version

Avoid claiming “zero information loss” unless that has been formally demonstrated for the specific operation.

---

# 44. Adaptive Context Shift Interceptor

## Purpose

Detect changes in user goals, constraints or environmental variables.

### UI

**Context Drift Alert**

Shows:

- previous value
- new value
- affected scope
- downstream impact
- required confirmation

Anuka is responsible for representing the adaptive side of context management.

---

# 45. Hierarchical Context Tree & Scope Boundary Map

## Context hierarchy

**Global Goal → Domain → Task → Constraints → Variables → Evidence/References**

### Boundary categories

- Hard constraint
- High-priority requirement
- Soft preference
- Environmental variable
- Optional background

### UI

**Context Topology Tree**

Users inspect what downstream components may access.

Access restrictions must correspond to actual backend scope controls.

---

# 46. Contextual Replay & Shadow Testing

## Purpose

Compare alternative context frames before committing one.

### Flow

**Current Frame → Fork → Modify Variable → Execute Test → Compare → Keep/Discard**

### UI

**Fork Context**

Each branch records its own:

- context version
- changed variables
- participating homes
- output
- evaluation result

---

# 47. Context Clash & Poisoning Firewall

## Purpose

Prevent contradictory or malicious information from silently becoming active context.

### Checks

- contradictory instructions
- conflicting values
- incompatible constraints
- suspicious injected instructions
- provenance conflicts
- scope violations

### UI

**Context Sanity Matrix**

States:

- CLEAR
- CLASH
- POISONING_RISK
- NEEDS_REVIEW
- BLOCKED

The interface should explain the actionable category and evidence without revealing security-sensitive detection internals.

---

# 48. Isolated Execution Sandboxes

## Purpose

Keep heavy transient variables outside the primary interaction frame.

Examples:

- large intermediate payloads
- document chunks
- code execution output
- temporary parameters

### UI

**Sandbox Pod**

Each pod displays:

- purpose
- owner
- state
- lifetime
- stored variable class
- access boundary
- cleanup state

Isolation must be implemented at the appropriate runtime/storage layer. A drawer labelled “Sandbox” is not isolation. Humanity has already invented enough fake locks.

---

# 49. Persistent Agent Scratchpad & Checkpointing

## Purpose

Maintain structured working state across multi-step workflows.

### Scratchpad may contain

- task ID
- active sub-goals
- completed sub-goals
- pending work
- current variables
- checkpoint references
- context version

### UI

**Working Memory / Scratchpad**

Sensitive internal content should be filtered according to access policy.

---

# 50. Priority-Tiered Context Budgeting

## Suggested tiers

### Critical
- system requirements
- current goal
- hard constraints

### High
- active conversation
- relevant retrieved facts
- active task state

### Medium
- summarized history
- secondary context

### Low
- distant background
- redundant metadata

### UI

**Context Allocator Bar**

Displays how available context capacity is allocated.

The exact number of tiers and allocation policy must remain configurable rather than being treated as a universal research truth.

---

# 51. Home 02 Functional Matrix

| Character | Responsibility | Main Outputs |
|---|---|---|
| Dharen | Context framing, compression, scope control | Context Frame, scope boundaries, priority map |
| Anuka | Adaptation, drift handling, sandboxing | Context diffs, adaptive state, isolated-state references |

---

# 52. Cross-Home Relationships

## Primary operational chain

**Human → Syvax → Sandre → Dharen → Intelligence Homes → Evidence/Verification → Syvax → Human**

This is a conceptual lifecycle, not a mandatory linear execution path.

Anukor may dynamically route between homes whenever the runtime architecture requires it.

---

# 53. Home-to-Home Contracts

Each handoff should carry a structured envelope rather than an informal message.

Minimum conceptual fields:

- task/session ID
- source
- destination
- payload reference
- context version
- provenance reference
- timestamp
- state
- permissions/scope
- correlation/trace ID
- expiration where applicable

---

# 54. Human Intervention Boundaries

The first four operational spaces expose different kinds of intervention:

| Location | Human Intervention |
|---|---|
| Syvax | Goal, instruction, routing, pause/redirect |
| Bloom | Navigation, oversight, checkpoint approval |
| Sandre | Data validation, quarantine, transformation approval |
| Dharen | Context boundaries, drift resolution, context branch selection |

The same intervention should not be duplicated across all locations.

---

# 55. Spatial HCI Progression

The four spaces should teach the system progressively:

### Syvax
**“Tell the system what you need.”**

### Bloom
**“See where the system is working.”**

### Sandre
**“Inspect what information the system is using.”**

### Dharen
**“Inspect how that information becomes context.”**

This creates a learning progression from **interaction → visibility → data → context**.

---

# 56. Runtime Truth Rules

Every visible feature belongs to one of four states:

| Label | Meaning |
|---|---|
| LIVE | Backed by current runtime data |
| SIMULATED | Demonstration behavior |
| HISTORICAL | Recorded prior runtime state |
| PLANNED | Design target, not yet implemented |

No visual effect should silently imply a capability that does not exist.

---

# 57. Accessibility Rules

Every important spatial interaction must have a non-spatial equivalent.

### Required

- keyboard navigation
- semantic labels
- text status
- readable contrast
- reduced-motion mode
- non-color state indicators
- screen-reader-compatible descriptions
- clear focus state
- direct navigation alternative to teleportation

Animations must communicate state or spatial relationship, not merely decorate the environment.

---

# 58. Age-Progressive Interpretation

The same spatial world supports progressive depth.

### Entry level

- character
- home
- job
- simple status

### Intermediate

- relationships
- workflows
- evidence
- data/context movement

### Advanced

- provenance
- topology
- checkpoints
- context versions
- execution traces
- evaluation

The interface should reveal complexity progressively rather than creating separate worlds for different age groups.

---

# 59. Research/HCI Value of Level 2 Part II

This level creates several testable HCI propositions without claiming them as proven results.

### 59.1 Spatial role comprehension

Can users identify what each Home is responsible for?

### 59.2 Workflow comprehension

Can users reconstruct a multi-home workflow from spatial signals?

### 59.3 Cognitive load

Does progressive spatial disclosure reduce unnecessary information exposure compared with raw multi-agent logs?

### 59.4 Human agency

Can users identify when and where they can intervene?

### 59.5 Trust and transparency

Can users distinguish actual system activity from simulation and understand provenance?

### 59.6 Context comprehension

Can users understand how raw information becomes structured context?

### 59.7 Error recovery

Can users identify, inspect and recover from failed or blocked transitions?

These are **evaluation questions**, not claims of demonstrated superiority.

---

# 60. Implementation Boundaries

Level 2 Part II defines the UX/world contract.

It does not by itself implement:

- model orchestration
- distributed tracing
- sandbox infrastructure
- vector databases
- cryptographic provenance
- checkpoint storage
- real-time telemetry
- resource enforcement
- external side effects
- automatic schema repair

Those capabilities require corresponding backend architecture, interfaces, security controls and tests.

---

# 61. Acceptance Criteria

Level 2 Part II is considered structurally complete when:

- [ ] The Gateway Quarter has a defined spatial purpose and resident responsibility.
- [ ] The Gateway Quarter has defined interaction, routing, output, telemetry, multimodal and safety surfaces.
- [ ] The Bloom has a clear distinction between navigation representation and backend network routing.
- [ ] The Bloom can represent Home activity without relying on decorative animation alone.
- [ ] The Data Stewardship Quarter clearly separates stewardship from transformation responsibilities.
- [ ] The Context Quarter clearly separates context framing from situational adaptation.
- [ ] Home-to-home handoffs have a defined conceptual envelope.
- [ ] Runtime, simulated, historical and planned states are visually distinguishable.
- [ ] Accessibility alternatives exist for spatial interactions.
- [ ] No private chain-of-thought is exposed as an interface feature.
- [ ] Resource, isolation, replay and interruption controls are only labelled as operational when backend enforcement exists.
- [ ] Each visual element can be mapped to a real responsibility, event, state or explicit simulation.
- [ ] The specification remains compatible with the Level 2 Part I supervision and network model.

---

# 62. Canonical Level 2 Part II Model

```text
                    CRITERIVOX WORLD
                           │
                 ┌─────────┴─────────┐
                 │                   │
             HOME 03              THE BLOOM
             SYVAX               CENTRAL NEXUS
                 │                   │
       ┌─────────┼─────────┐    ┌────┴────┐
       │         │         │    │         │
    RECEIVE   ROUTE     OUTPUT  HOMES   OBSERVE
       │         │         │
       └─────────┼─────────┘
                 │
          ┌──────┴──────┐
          │             │
       HOME 01       HOME 02
       SANDRE        DHAREN
          │             │
      DATA STATE    CONTEXT STATE
          │             │
          └──────┬──────┘
                 │
           INTELLIGENCE
                 │
       EVIDENCE / DECISION
                 │
               SYVAX
                 │
              HUMAN
```

Anukor remains the dynamic network layer crossing these boundaries rather than becoming another conventional Home.

---

# 63. Final Design Principle

The world map is not a fantasy layer placed on top of Criterivox.

It is an **HCI representation of the computational system**.

Therefore:

**Home = responsibility**

**Room = capability**

**Desk/workshop = operation**

**Street/vine = connection**

**Bloom = shared spatial nexus**

**Character = interaction representation of module intelligence**

**Animation = semantic state**

**Object = inspectable system concept**

**User action = real intervention or explicitly labelled simulation**

The intended result is a world that makes an otherwise invisible multi-agent architecture inspectable, navigable and challengeable by humans without requiring the human to understand the entire underlying implementation.

---

## Boundary With Level 2 Part III

Part III should proceed into the remaining operational Homes and their spatial interiors, followed by the exact city geometry, district transitions, streets, common spaces, environmental locations, camera/viewport behavior, movement model, room-to-room transitions and cross-world spatial interaction rules.

It should not duplicate the Home 03, Bloom, Home 01 or Home 02 functional specification defined here.


---

# 64. Implementation Status — Canonical Part-II Integration

**Branch:** `ui-stabilization-system-behavior`

Part II is implemented as an integration layer over existing Criterivox services rather than as replacement engines.

## Canonical runtime

- `src/criterivox/world/level2_part2.py` is the Part-II read-model/control contract.
- `src/criterivox/ui/level2_part2_routes.py` exposes the human-facing controls.
- Existing Part-I routing/tracing/event infrastructure remains authoritative.
- Existing Bloom, S5, and context runtime remain authoritative.

## Canonical presentation

- `presentation/lib/world_map_level2_part2_page.dart` is the Part-II world-map surface.
- `presentation/lib/app_shell.dart` exposes it as `civilization-part2`.
- The Part-II page presents the four canonical spaces: Gateway, Bloom, Data Stewardship, and Context.

## Implemented control surfaces

- Dynamic UI intent synthesis
- Mid-flight steering
- Human-readable status ticker
- Bounded Bloom energy allocation
- Priority-tiered context budgeting
- Capability/truth-state registry
- Part-II home/capability inspection
- Part-II navigation entry and return path

## Reuse rules

The following are intentionally **not duplicated**:

- Part-I routing
- distributed trace
- event dispatch
- BloomController state
- S5 readiness/provenance/schema-drift/semantic-tagging/quality-gate runtime
- ContextReplayService and existing context runtime
- existing Home preview and operational pages

## Truth rule

Every capability is classified as `LIVE`, `SIMULATED`, `HISTORICAL`, or `PLANNED`. Presentation must not imply a backend capability that is not represented by the runtime contract.

## Test coverage

`tests/test_world_map_level2_part2_runtime.py` covers:

- canonical Home registry
- truth model
- dynamic UI intents
- steering state transitions
- bounded energy allocation
- context budget invariants

This document is now the implementation-facing companion to the Part-II UX specification. Legacy claims that require a second engine should be interpreted as stale and must not be used to create duplicate runtime systems.
