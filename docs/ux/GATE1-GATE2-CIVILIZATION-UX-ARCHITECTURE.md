# Criterivox Gate 1 / Gate 2 Civilization UX Architecture

**Status:** LOCKED UX ARCHITECTURE BASELINE  
**Branch:** `main`  
**Date:** 2026-09-17  
**Scope:** Human-facing civilization, character, Bloom, Syvax, and Human Residence experience

## 1. Purpose

This document establishes the locked UX architecture for the next Criterivox interface layer. It extends the earlier character-introduction and information-architecture work into a coherent two-gate experience.

The central distinction is:

- **Gate 1 — Criterivox Civilization:** understand the AI system.
- **Gate 2 — Human Residence:** work with the AI system on a real human problem.

The civilization layer is not a replacement for the S1–S9 architecture. It is its human-facing representation and interaction surface.

## 2. Foundational UX Model

```text
                         CRITERIVOX
                              |
                 +------------+------------+
                 |                         |
             GATE 1                    GATE 2
       CRITERIVOX CIVILIZATION     HUMAN RESIDENCE
                 |                         |
          Understand AI              Work with AI
                 |                         |
      Characters / Homes          Goal / Data / Context
      Relationships              Decisions / Options
      Evidence                   Challenge / Action
      Reasoning                  Real Result
      Collaboration             Results Journal
```

### Core statement

> **Gate 1:** Meet the people who make the decision.  
> **Gate 2:** This is where your actual problem lives.

Gate 1 establishes transparency and system understanding. Gate 2 establishes human agency and the real-world decision lifecycle.

## 3. Gate 1 — Criterivox Civilization

### Purpose

Gate 1 is the AI-side world of Criterivox. A human can enter the civilization, meet characters, visit specialized Homes, understand relationships, observe collaboration, inspect evidence and explanations, see information movement, challenge reasoning, and observe how decisions are formed.

The objective is not to ask the user to trust a machine. The objective is to let the user inspect how the machine arrived at an output.

### Roster & Convergence

The introductory roster is an active **Supervision Briefing Control Plane**, not a static character directory.

It should expose four dimensions:

1. **Agent identity and transparency** — role, responsibility, domain authority, boundaries, and current state.
2. **Spatial relationship mapping** — Homes, character residency, network movement, and meaningful system relationships.
3. **Live observability** — current activity and relevant operational state where supported by the runtime.
4. **Interactive briefing and sandboxing** — a safe way to inspect character behavior and cross-home routing before entering a production workflow.

## 4. Living Household Map

The primary Gate 1 surface is an interactive spatial roster.

The map represents the Criterivox ecosystem rather than a linear grid of character cards. Selecting a Home focuses the user on its household and exposes its resident characters, responsibilities, relationships, and current operational state.

### Spatial rules

- Homes are stable spatial anchors.
- Characters belong to their defined Homes unless explicitly modeled otherwise.
- **Anukor is a roaming network resident and does not receive a conventional permanent Home node.**
- Active system movement may be represented through paths, edges, seeds, vines, or equivalent visual telemetry.
- Spatial relationships must correspond to meaningful system relationships rather than decorative connections.

## 5. Character Diagnostic Introductions

Character introductions are behavioral and operational rather than encyclopedic.

A character introduction should answer:

- Who are you?
- What do you do?
- When does your role become important?
- What boundaries do you enforce?
- Who or what do you work with?
- What are you doing now?

The interface may provide dynamic text/audio introductions and state indicators such as `READY`, `IDLE`, or `ACTIVE` where those states are backed by actual application/runtime state.

Character animation remains functional UI feedback. It must communicate semantic system state rather than exist only as decoration.

## 6. Cross-Home Handshake Sandbox

Gate 1 includes a zero-risk demonstration/inspection area for observing how a request could move through Criterivox capabilities and Homes.

The sandbox should make routing understandable by showing:

```text
User input
   -> Syvax
   -> relevant capability / Home
   -> evidence / reasoning / challenge stages
   -> result
```

Where real runtime telemetry is available, the UI may animate actual events. Where it is not available, the interface must label the experience as a simulation or demonstration rather than implying live execution.

The goal is to expose meaningful transformations, not merely animate packets.

## 7. Relational Topology

Character relationships are represented as observable system relationships, not as an arbitrary social-network score.

Supported relationship concepts may include:

| Relationship | Meaning |
|---|---|
| Residency | Character belongs to a Home |
| Communication | Character-to-character interaction |
| Data flow | Context or artifact movement |
| Evidence flow | Claim or result moves toward verification |
| Reasoning dependency | One reasoning stage depends on another |
| Challenge | A proposal is challenged or stress-tested |
| Human intervention | Human input modifies or interrupts work |
| Routing | Network/control-plane movement |

Affinity visualization should therefore communicate **interaction, dependency, frequency, or flow** where measured, rather than fictional interpersonal sentiment.

## 8. Gate 2 — Human Residence

Gate 2 is the human-side workspace. Each account may have a Human Residence distinct from all AI character Homes.

The Human Residence contains two primary spaces:

### Private Room

The user's personal decision space for:

- Goal definition
- Data and context submission
- Decision options
- Human challenge
- Acceptance/rejection/modification
- Action recording
- Real-world outcome recording
- Results Journal

### Collaboration Room

A shared workspace for multi-human decision work.

Roles:

| Role | Meaning |
|---|---|
| House Owner | Owns the residence/workspace and its governance |
| Resident | Participating member with assigned permissions |
| Guest | Temporary participant with limited access |

The collaboration model must preserve context boundaries and human authority.

## 9. Human Decision Loop

The central Gate 2 lifecycle is:

```text
HUMAN RESIDENCE
      |
     GOAL
      |
 DATA + CONTEXT
      |
      v
 CRITERIVOX
      |
 DECISIONS + OPTIONS
      |
 HUMAN CHALLENGE
    /       \
 REJECT    MODIFY / ACCEPT
    \       /
      ACTION
        |
   REAL RESULT
        |
  RESULTS JOURNAL
        |
 FUTURE DECISIONS
```

The human remains an active epistemic participant. Criterivox does not treat acceptance as the only meaningful human action.

## 10. Guest Pass

The Guest Pass provides zero-commitment access to a temporary decision-support experience.

```text
GUEST
  |
Goal + Data + Context
  |
Ephemeral Session
  |
Decision Support
  |
Inspect Result
  |
Session Ends / Convert to Residence
```

The intended architecture is isolated and temporary. Product implementation must be explicit about what data is retained, discarded, or transferred when a guest converts to an account.

## 11. Gate 2 Research-Oriented Features

These are UX requirements and research-facing directions, not claims that every mechanism already exists in the current backend.

### 11.1 Results Journal and Outcome Comparison

A decision receipt should preserve:

- Original goal
- Context used
- Accepted/selected option
- Expected outcome
- Observed real result
- Difference between expected and observed result
- Relevant contributing factors
- Evidence and uncertainty
- Candidate follow-up or retest

Avoid presenting a single outcome difference as proof of causal accuracy. Observed deviations should remain qualified and interpretable.

### 11.2 Socratic Challenge Matrix

Before action, the human can challenge a decision through a structured interface that may expose:

- alternative scenarios
- unstated assumptions
- trade-offs
- constraints
- risk tolerance
- time horizon
- budget or resource limits

Dynamic re-ranking must only be presented as live behavior when backed by an implemented decision engine.

### 11.3 Role-Based Shared Context

Collaboration UX should expose role badges and context visibility boundaries. Owner, Resident, and Guest permissions must map to actual authorization rules rather than presentation-only labels.

### 11.4 Ephemeral Guest Sandbox

The Guest experience should isolate temporary work from persistent residence state until an explicit conversion or persistence action occurs.

## 12. Home 03 — Syvax Interaction & Gateway Home

Syvax is the sole resident of Home 03 and the primary human-machine interaction boundary.

Primary responsibilities represented in the UX:

- Human-machine dialogue
- Intent reception and clarification
- Human-facing task framing
- Adaptive output presentation
- Multimodal input reception
- Human steering and interruption
- Human-readable execution status
- Interface-level safety/guardrail feedback

### Architectural boundary

**Syvax is not a monolithic orchestrator.**

The UI may make Syvax appear as the receptionist, guide, or voice of the system, but actual reusable capabilities, pipelines, permissions, events, state, provenance, checkpoints, budgets, and execution controls remain in the underlying architecture.

## 13. Syvax UX Features

### Intent Dispatcher / Routing View

Visualize an explicit task plan or routing path when the runtime provides it.

### Syvax's Lens

Allow results to be presented in task-appropriate views such as:

- Executive summary
- Detailed reasoning/explanation
- Structured data
- Visual comparison
- Raw structured payload where appropriate

### Mid-Flight Human Steering

Expose pause, correction, constraint injection, or other intervention controls only where supported by the underlying human-authority/execution contracts.

### Silence Translator

Translate relevant technical execution state into concise human-readable progress information. Do not fabricate activity when no corresponding runtime event exists.

### Conversation Branches

Support non-linear exploration where the underlying state/checkpoint model can safely represent branches.

### Multimodal Reception

Provide a unified input surface for supported text, files, images, voice, or other modalities. Assets must flow through the actual ingestion/validation boundaries rather than bypassing them.

### Dynamic UI Workbench

Render structured UI components when task context calls for them. Generated UI remains presentation; domain computation remains in the underlying system.

### Safety / Guardrail Inspector

Expose safety or boundary decisions to the human at the interaction layer while keeping enforcement in the appropriate application/runtime boundaries.

## 14. The Bloom — Spatial and Operational Visualization Hub

The Bloom is the organic spatial nexus of the Criterivox civilization. It is visually represented as a living flower/portal structure and provides navigation plus system-state visualization.

### Critical architectural rule

> **The Bloom is not an agent and is not an orchestration engine.**

It is a **presentation/read-model layer** over underlying system state.

It may visualize:

- Home activity
- routing
- execution flow
- provenance
- checkpoints
- human intervention state
- system telemetry
- navigation topology

It must not independently own:

- orchestration authority
- provenance authority
- checkpoint authority
- execution budgets
- permission enforcement
- human authority
- routing logic

Those responsibilities remain in the appropriate S1–S9 application, capability, event, execution, persistence, and human-authority boundaries.

## 15. Bloom Features

### 15.1 Petal Teleportation Matrix

Each petal represents a Home and provides direct spatial navigation into that Home.

### 15.2 Bioluminescent Civilization Pulse

Bloom appearance may reflect actual system activity, uncertainty, or state where such telemetry exists. Visual metaphors must not imply measurements that are not available.

### 15.3 Context Flow / Seed Distribution

Context or artifact movement may be represented visually as seeds, vines, or similar organic metaphors. The actual movement is performed by the underlying system; Bloom visualizes it.

### 15.4 Petal HITL Checkpoints

When an actual human-intervention checkpoint is raised, Bloom can focus attention on the affected Home and expose the available intervention surface.

### 15.5 Cross-Home Subgraph Lineage

Active execution paths can be visualized as vines or edges connecting participating Homes when supported by execution/event telemetry.

### 15.6 Living Portal Preview

A Home petal may reveal a preview of its current workspace/read model. Preview content must follow the same privacy and authorization rules as the destination Home.

### 15.7 Pollen Provenance Stream

The Bloom may visualize provenance records and evidence lineage exposed by the underlying artifact/event/provenance layer. It does not maintain a second provenance database.

### 15.8 Petal Energy / Budget Visualization

Budget state may be displayed when the runtime exposes resource budgets. Any control that changes a budget must invoke the real execution-policy boundary rather than modifying a visual value only.

### 15.9 Trace-Level Diagnostics

Anomalies, failed handoffs, or trace-level warnings may be surfaced through Bloom particles/edges when actual evaluator or execution telemetry exists.

### 15.10 Checkpoint and Time Replay Visualization

Bloom may expose durable checkpoint history and replay navigation. The actual checkpoint and replay authority remains in the underlying persistence/runtime architecture.

### 15.11 Oversight Mode Visualization

HITL/HOTL or other graduated-oversight states may be visualized where the execution policy supports them. A visual toggle must not imply a control mode that the backend cannot enforce.

## 16. Information Architecture

```text
CRITERIVOX
│
├── Gate 1 — Civilization
│   ├── Roster & Convergence
│   ├── Living Household Map
│   ├── Character Briefings
│   ├── Relationship Topology
│   ├── Cross-Home Handshake Sandbox
│   ├── Bloom
│   └── Character Homes
│
├── Gate 2 — Human Residence
│   ├── Private Room
│   │   ├── Goal
│   │   ├── Data
│   │   ├── Context
│   │   ├── Decisions / Options
│   │   ├── Challenge
│   │   ├── Action
│   │   └── Results Journal
│   ├── Collaboration Room
│   │   ├── Owner
│   │   ├── Residents
│   │   ├── Guests
│   │   └── Shared Decision Canvas
│   └── Guest Pass
│       └── Ephemeral Decision Session
│
└── Syvax / Home 03
    ├── Dialogue
    ├── Intent / Routing
    ├── Multimodal Input
    ├── Output Lens
    ├── Steering
    ├── Conversation Branches
    ├── UI Workbench
    └── Safety / Guardrails
```

## 17. Progressive Disclosure

The interface must not expose every telemetry field at once.

### Level 1 — Civilization

Identity, activity, Home, relationships, and system pulse.

### Level 2 — Character / Home

Role, responsibility, current work, connections, recent events, and available actions.

### Level 3 — Operational Inspection

Execution trace, evidence, provenance, pipeline, checkpoints, permissions, budgets, and intervention details where authorized and supported.

This preserves the existing Criterivox UX principle of progressive disclosure and avoids dashboard noise.

## 18. Architectural Separation

The locked separation is:

```text
UI / Civilization
       |
       v
Characters + Homes + Bloom + Syvax
       |
       v
Presentation / Read Models
       |
       v
S1–S9 Architecture
       |
       +-- Capabilities
       +-- Pipelines
       +-- Events
       +-- State
       +-- Provenance / Artifacts
       +-- Checkpoints / Replay
       +-- Permissions
       +-- Budgets / Execution Policy
       +-- Human Authority
```

### Responsibilities

- **Characters:** explain and embody system roles.
- **Homes:** organize specialized work.
- **Anukor:** represents network/control-plane movement and remains spatially fluid.
- **Bloom:** visualizes civilization/system state and provides spatial navigation.
- **Syvax:** mediates the human-machine interaction boundary.
- **Human Residence:** contains the human's decision lifecycle.
- **Underlying capability architecture:** remains independent of all characters, Homes, and visual metaphors.

## 19. Research Alignment

The UI layer supports the research lifecycle by making the human interaction observable and structured without confusing UI telemetry with research conclusions.

```text
Question
  -> Context
  -> Evidence
  -> Reasoning
  -> Human Challenge
  -> Alternative Hypothesis
  -> Test / Action
  -> Observed Outcome
  -> Knowledge Update
```

Gate 1 can support investigation of transparency, explanation, system understanding, and visibility of evidence/reasoning.

Gate 2 can support investigation of human agency, challenge behavior, decision utility, hypothesis formation, outcome tracking, and context-conditioned reuse.

Any collection of user interaction or outcome data for research must follow appropriate consent, privacy, data-minimization, retention, anonymization/pseudonymization, and applicable research-ethics requirements.

## 20. Implementation Truthfulness Rule

The UX may reserve interfaces for future capabilities, but the product must clearly distinguish:

- **Implemented:** backed by actual application/runtime behavior.
- **Visualized:** derived from actual state but presented through a metaphor.
- **Simulated:** intentionally demonstrative and not live execution.
- **Planned:** reserved for a future implementation.

No animation, status pill, telemetry number, provenance particle, checkpoint, budget value, or routing path should be presented as live evidence unless the underlying system supplies it.

## 21. Locked Design Principles

1. **Gate 1 = Understand AI.**
2. **Gate 2 = Work with AI.**
3. **Transparency replaces blind trust.**
4. **Characters are functional cognitive/social interfaces, not computational owners.**
5. **Homes organize roles, not independent AI brains.**
6. **Anukor is a network resident, not another fixed Home.**
7. **Syvax is the interaction boundary, not a monolithic orchestrator.**
8. **Bloom is a visualization/read-model layer, not an authority layer.**
9. **Human Residence preserves human agency and real-world outcome feedback.**
10. **Observable relationships must correspond to meaningful system behavior.**
11. **Progressive disclosure prevents telemetry overload.**
12. **Research telemetry must be structured and privacy-conscious.**
13. **UI claims must remain faithful to implemented backend capabilities.**
14. **The underlying S1–S9 capability architecture remains independent of the civilization presentation layer.**

## 22. Implementation Priority

The intended implementation progression is:

```text
UI FOUNDATION
      -> Gate 1 Civilization
      -> Human Residence
      -> Decision Workflow
      -> Observability
      -> Advanced Control
```

The first usable UI should prioritize the actual human experience over speculative control surfaces. Advanced telemetry, replay, dynamic budgets, graduated oversight, and collaboration governance should be connected only as their corresponding backend contracts become available.

## 23. Relationship to Earlier UX Documentation

This document supersedes the earlier **App Introduction** framing where the newer Gate 1 / Gate 2 model conflicts with it, while retaining the existing character visual-direction principles.

The earlier S4 character direction remains the visual source of truth for established character identities and states. The current document defines the larger civilization and human-residence information architecture around those characters.
