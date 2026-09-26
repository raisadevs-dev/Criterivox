# Criterivox World Map — Level 2, Part I
## Introduction, Supervision Briefing, Anukor Network Layer & Guest Pass

**Document type:** Internal UX / HCI specification  
**Status:** Design specification  
**Version:** 1.0  
**Date:** 2026-09-18  
**Parent:** Level-1 World Map Blueprint  
**Scope:** Introduction page, character roster interaction, Anukor network behavior, and Gate 2 Guest Pass  
**Scripts:** Excluded by design. Character dialogue, narration, quests, and scripted scenes belong to a later specification.

---

## 1. Purpose

Level 1 established the geography of the Criterivox world.

Level 2, Part I defines how that geography becomes an interactive HCI system.

The page and systems specified here must not behave as static character cards or decorative game scenery. They should expose the existing Criterivox architecture through spatial interaction.

> **The user should learn the system by exploring the world, while the world remains truthful to the underlying runtime.**

The interface combines spatial navigation, character identity, responsibility discovery, runtime state, network topology, human supervision, safe experimentation, and progressive disclosure.

---

# 2. Level-2 Scope

This part contains four connected systems.

~~~text
LEVEL 2 — PART I
│
├── A. Roster & Convergence
│   ├── Spatial Roster
│   ├── Character Focus
│   ├── Diagnostic Briefing
│   ├── State / Readiness
│   ├── Cross-Home Handshake
│   └── Relationship View
│
├── B. Anukor Network Layer
│   ├── Dynamic Routing
│   ├── Context Envelopes
│   ├── Loop Protection
│   ├── Dynamic Edges
│   ├── Protocol Translation
│   ├── Distributed Tracing
│   ├── Parallel Routing
│   └── Event Dispatch
│
└── C. Gate 2 Guest Pass
    ├── Ephemeral Session
    ├── Isolation Indicator
    ├── Logic Inspection
    ├── Trade-off Exploration
    └── Ownership Handover
~~~

---

# 3. Introduction Page — Roster & Convergence

## 3.1 Purpose

The Introduction Page is the user's first active inspection surface inside the Criterivox civilization.

It replaces a conventional roster grid with a **Supervision Briefing Control Plane**.

The user should be able to:

1. understand who the characters are
2. understand where their responsibilities live
3. inspect relationships between Homes
4. observe meaningful runtime state
5. observe network movement
6. perform a safe cross-home test
7. return to the wider civilization

The page should feel like entering a functioning civilization rather than opening a directory.

---

# 4. Introduction Page Spatial Structure

~~~text
                    ROSTER & CONVERGENCE
                             │
              ┌──────────────┴──────────────┐
              │                             │
       SPATIAL ROSTER                 SYSTEM STATUS
              │                             │
      Homes + characters              Runtime state
              │                             │
              └──────────────┬──────────────┘
                             │
                     SELECTED CHARACTER
                             │
              ┌──────────────┼──────────────┐
              │              │              │
          BRIEFING       RELATIONSHIPS   TELEMETRY
              │              │              │
              └──────────────┼──────────────┘
                             │
                    HANDSHAKE SANDBOX
                             │
                    ROUTE / TRACE VIEW
~~~

The page is a **control surface**, not a collection of independent widgets.

---

# 5. Spatial Roster — Living Household Map

## 5.1 Primary function

The Spatial Roster displays the Criterivox civilization as a connected spatial topology.

It represents:

- character Homes
- district boundaries
- Bloom location
- network streets
- active connections
- Anukor movement
- selected character
- selected Home
- current system state

## 5.2 Interaction

### Home selection

Selecting a Home:

1. focuses the camera/view
2. identifies the Home
3. identifies residents
4. shows responsibility
5. exposes relevant rooms
6. displays available relationship edges
7. opens the character briefing surface

### Character selection

Selecting a character:

1. focuses their Home
2. highlights their responsibility domain
3. displays their current semantic state
4. shows relevant collaborators
5. exposes available inspection controls

### Anukor selection

Selecting Anukor:

1. does not focus a permanent Home
2. reveals current network position
3. highlights active routes
4. exposes routing/trace information
5. shows current network activity

---

# 6. Character Diagnostic Briefing

## 6.1 Purpose

The diagnostic briefing provides dynamic identity and responsibility information without requiring a large static biography.

Each character surface should expose four levels:

~~~text
IDENTITY
   ↓
RESPONSIBILITY
   ↓
CURRENT STATE
   ↓
CURRENT CONTRIBUTION
~~~

## 6.2 Character briefing card

| Field | Purpose |
|---|---|
| Character | Identity |
| Role | Responsibility |
| Home | Spatial location |
| State | Current semantic runtime state |
| Attention | Current attention state |
| Current task | Active responsibility, when available |
| Collaborators | Relevant active relationships |
| Last meaningful event | Recent runtime event |
| Evidence/status | Verifiable state information |
| Accessibility label | Non-visual equivalent |

The card must not invent runtime metrics.

---

# 7. Voice and Text Briefing

A character may be represented through text and, where implemented, audio.

## 7.1 Text mode

Text should communicate:

- identity
- responsibility
- boundaries
- current operational state
- relevant context

## 7.2 Audio mode

Audio is an alternative presentation channel, not a separate source of truth.

~~~text
Character State Model
        │
        ├── Text briefing
        ├── Audio briefing
        ├── Visual state
        └── Accessibility label
~~~

No channel should claim information unavailable to the underlying system.

## 7.3 Context adaptation

A briefing may change according to:

- selected project
- current task
- character state
- current collaboration
- user depth level

This should be controlled contextual presentation, not uncontrolled character improvisation.

---

# 8. Character State Presentation

The world uses the existing semantic character states.

### Shared operational states

~~~text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
~~~

### Attention states

~~~text
QUIET
ATTENTIVE
FOCUSED
BUSY
WAITING
NEEDS_USER
COMPLETING
RECOVERING
~~~

The visual layer must map these states to presentation behavior.

It must not create fake "AI emotions" when the backend only reports an operational state.

---

# 9. Cross-Home Handshake Sandbox

## 9.1 Purpose

The Handshake Sandbox lets a user observe a small, controlled collaboration before launching a full production task.

It is a **safe simulation/test surface**.

## 9.2 Flow

~~~text
TEST INPUT
    │
    v
SYVAX
    │
    v
ANUKOR
    │
    ├────> TARGET HOME
    │          │
    │          v
    │      COLLABORATOR
    │          │
    └──────────┴────> RETURN / NEXT ROUTE
                         │
                         v
                    USER VIEW
~~~

The exact route must be generated by the active runtime or an explicitly declared simulation mode.

## 9.3 User-visible route

The user can inspect:

- origin
- destination
- route
- handoff
- state
- result
- next destination
- completion/failure

## 9.4 Safety boundary

Sandbox mode must be visibly distinct from production execution.

~~~text
SANDBOX
≠
PRODUCTION
~~~

The UI must not make simulated packets appear to be real production events.

---

# 10. Relational Distance & Affinity Visualizer

## 10.1 Purpose

Relationships are represented as graph edges rather than a static contact list.

The graph may communicate:

- collaboration frequency
- current activity
- route frequency
- relationship type
- current task relevance

## 10.2 Edge model

~~~text
CHARACTER A
    │
    ├── PRIMARY
    ├── SECONDARY
    ├── COLLABORATIVE
    ├── CONDITIONAL
    └── ADVERSARIAL / CHALLENGE
             │
             v
        CHARACTER B
~~~

The visualizer must distinguish **relationship semantics** from arbitrary decorative "friendship" scores.

## 10.3 Dynamic edge behavior

Edge intensity may change when backed by actual measurable signals such as:

- handoff frequency
- current task participation
- routing frequency
- verified collaboration
- active workflow state

If a numeric affinity model is not implemented, the interface should use categorical relationship types instead of inventing a score.

---

# 11. Introduction Page Functional Matrix

| Component | Primary function | User output | Runtime dependency |
|---|---|---|---|
| Spatial Roster | Civilization topology | Interactive world map | Character/Home registry |
| Character Focus | Responsibility inspection | Focused Home + character | Character model |
| Diagnostic Briefing | Identity/state explanation | Text/audio/state view | Character state |
| State Display | Operational transparency | State + attention indicators | Runtime state |
| Handshake Sandbox | Safe collaboration test | Route simulation | Sandbox runtime |
| Relationship Visualizer | Collaboration topology | Graph edges | Relationship/telemetry data |
| Anukor View | Network inspection | Live route view | Network events |
| Accessibility Layer | Equivalent non-visual access | Labels/status text | UI state model |

---

# 12. Anukor — Network Resident

Anukor has no conventional Home.

He is represented spatially through the **network itself**.

~~~text
                 SIGNAL TOWER
                      │
                 ROUTING JUNCTION
                  /          \\
             BRIDGE          BRIDGE
              /                \\
       CHARACTER HOME        CHARACTER HOME
              \\                /
               NETWORK STREET
                     │
                   BLOOM
~~~

Anukor's presence should emerge through meaningful network activity.

Random movement is not a valid substitute for network behavior.

---

# 13. Anukor Network Responsibilities

The following are Level-2 design capabilities. They must not be treated as already implemented merely because they are represented visually.

## 13.1 Intent-Based Dynamic Router

### Purpose

Select a destination according to task requirements rather than forcing every request through one fixed sequence.

### UI representation

**Packet Signal Path**

~~~text
Incoming Intent
      │
      v
   Syvax
      │
      v
   Anukor
      │
      ├──> Home A
      ├──> Home B
      └──> Home C
~~~

The selected route should be inspectable.

---

# 14. Ephemeral Context Envelope

## 14.1 Purpose

Transmit only the state required by the receiving responsibility instead of copying irrelevant conversation history.

~~~text
SOURCE OUTPUT
     │
     v
ANUKOR
     │
     ├── relevant state
     ├── required inputs
     ├── identifiers
     └── constraints
     │
     v
EPHEMERAL ENVELOPE
     │
     v
TARGET HOME
~~~

## 14.2 Envelope Inspector

The inspector may expose:

- source
- target
- request ID
- trace ID
- selected state
- required variables
- excluded content category
- delivery state
- expiration/TTL, if implemented

The UI must not expose private internal reasoning or hidden chain-of-thought.

---

# 15. Circuit Breaker & Loop Interceptor

## 15.1 Purpose

Detect repeated transitions without convergence and prevent uncontrolled execution cycles.

~~~text
HOME A
  │
  v
HOME B
  │
  v
HOME A
  │
  v
HOME B
  │
  X
CIRCUIT BREAKER
  │
  ├──> Manis / review
  └──> Human intervention
~~~

## 15.2 User-visible states

~~~text
NORMAL
   ↓
WARNING
   ↓
CIRCUIT TRIPPED
   ↓
ESCALATED
   ↓
RECOVERED / CLOSED
~~~

The threshold must be a configurable system rule, not a hard-coded visual number.

---

# 16. Dynamic Edge Weighting

Anukor can maintain dynamic network topology based on measurable runtime signals.

Potential inputs:

- traffic
- latency
- successful handoffs
- verification outcome
- active workload
- route availability

~~~text
LOW ACTIVITY      ACTIVE ROUTE       HIGH ACTIVITY
   thin               medium              strong
    ─                    ━                  ═
~~~

Visual thickness is only valid when it maps to an actual metric.

---

# 17. Protocol Bridge

If Criterivox uses multiple communication protocols, Anukor can provide a protocol-boundary representation.

~~~text
AGENT MESSAGE
     │
     v
  ANUKOR
     │
     ├── protocol identification
     ├── schema validation
     └── translation
     │
     v
TARGET INTERFACE
~~~

The interface may expose a **Protocol Bridge Inspector** showing:

- source protocol
- target protocol
- schema/version
- validation result
- translation result
- failure state

Protocol names and implementations must reflect the actual architecture.

---

# 18. Distributed Trace View

Anukor can carry trace context across network boundaries.

Conceptual representation:

~~~text
TRACE
│
├── Syvax       120 ms
├── Anukor       18 ms
├── Dharen       90 ms
├── Tarkis      210 ms
├── Veridat     150 ms
└── Pramon       80 ms
~~~

The UI may provide:

- trace ID
- span hierarchy
- timestamps
- duration
- route
- transition state
- error state

Token usage may only be displayed if it is actually measured by the runtime.

The trace interface should never imply that an unavailable metric has been measured.

---

# 19. Parallel Routing / Topological Sharding

For tasks that genuinely contain independent sub-problems, Anukor may represent parallel routing.

~~~text
                 TASK
                  │
                  v
               ANUKOR
              /      \\
             /        \\
       STREAM A      STREAM B
          │              │
       HOME A          HOME B
          │              │
          +------┬-------+
                 v
             JOIN NODE
                 │
                 v
              RESULT
~~~

Parallel execution must be based on actual task decomposition.

The visual splitter must not imply concurrency when the backend is executing sequentially.

---

# 20. Event-Driven Mesh Dispatcher

Anukor may expose event-driven communication where supported.

Example event model:

~~~text
FACT_VERIFIED
      │
      v
   ANUKOR
   /    \\
  v      v
HOME A  HOME B
~~~

The Event Bus Monitor may show:

- event type
- producer
- subscribers
- delivery state
- timestamp
- queue state
- failure/retry state

Only actual emitted events should appear as live events.

---

# 21. Anukor Functional Matrix

| Feature | Responsibility | User-visible representation | Required truth source |
|---|---|---|---|
| Intent Router | Dynamic dispatch | Packet path | Routing decision |
| Context Envelope | Context isolation | Envelope Inspector | Actual payload |
| Loop Interceptor | Failure protection | Circuit state | Transition counter |
| Edge Weighting | Topology adaptation | Edge intensity | Runtime metrics |
| Protocol Bridge | Message translation | Bridge Inspector | Protocol adapter |
| Distributed Trace | Observability | Trace/Flame view | Trace spans |
| Parallel Routing | Concurrent dispatch | Split/join graph | Execution state |
| Event Dispatcher | Async propagation | Event monitor | Event bus |

---

# 22. Gate 2 — Guest Pass Room

The Guest Pass is the temporary entry point into Human Territory.

Its central principle is:

> **Explore first, commit later.**

The guest session must be clearly separated from permanent Human Residence data.

---

# 23. Guest Pass Functional Model

~~~text
GUEST
  │
  v
WELCOME PAVILION
  │
  v
EPHEMERAL SESSION
  │
  ├── Goal
  ├── Data
  └── Context
  │
  v
CRITERIVOX PROCESSING
  │
  ├── Inspect reasoning/evidence
  ├── Explore options
  └── Challenge assumptions
  │
  +───────────────+
  │               │
  v               v
LEAVE          CLAIM SESSION
  │               │
  v               v
DISCARD       AUTHENTICATE
                  │
                  v
             HUMAN RESIDENCE
~~~

---

# 24. Guest Session Isolation

The Guest Pass should use an explicit ephemeral-session model.

### Required conceptual properties

- session-specific state
- isolation from other sessions
- no accidental access to private residence data
- clear session lifetime
- clear persistence status
- explicit ownership transition

### Important implementation distinction

A UI label such as "zero-trust" or "vaporized" is not proof of isolation or deletion.

Those claims require corresponding infrastructure guarantees and verification.

---

# 25. Sandbox Isolation Indicator

The Guest UI should continuously communicate:

~~~text
GUEST SESSION
ISOLATED
TEMPORARY
~~~

Where supported, it may also expose:

- session identifier
- remaining session lifetime
- persistence status
- storage boundary
- cleanup status

The timer is informational unless the backend actually enforces the expiration.

---

# 26. Decision Logic X-Ray

The Guest can inspect a simplified execution lineage.

Example:

~~~text
GOAL
 │
 v
SYVAX
 │
 v
ANUKOR
 │
 v
DHAREN
 │
 v
REASONING / EVIDENCE
 │
 v
PRAMON / MANIS
 │
 v
OPTIONS
~~~

The X-Ray should expose:

- contributing character
- responsibility
- input/output boundary
- evidence reference
- decision stage
- human intervention point

It should **not** expose private chain-of-thought.

The interface explains system behavior through structured evidence and decision lineage instead.

---

# 27. Ephemeral Trade-Off Exploration

The Guest can inspect how changing constraints affects available options.

Example conceptual controls:

~~~text
Constraint
   │
   ├── Budget
   ├── Speed
   └── Risk
        │
        v
   OPTION SET
        │
        v
   UPDATED TRADE-OFFS
~~~

Changes should be visibly marked as:

**guest simulation / exploratory state**

unless the underlying system actually commits them.

---

# 28. Ownership Handover

A guest may transition from temporary exploration to a permanent Human Residence.

~~~text
TEMPORARY SESSION
       │
       v
CLAIM SESSION
       │
       v
AUTHENTICATION
       │
       v
OWNERSHIP VALIDATION
       │
       v
STATE MIGRATION
       │
       v
PRIVATE ROOM
~~~

### Migration requirements

The system must define:

- what data is transferred
- what is discarded
- what becomes persistent
- who becomes owner
- how conflicts are resolved
- how migration failures are recovered

The UI must not claim successful migration until the backend confirms it.

---

# 29. Guest Pass Functional Matrix

| Stage | Guest action | System operation | Visible result |
|---|---|---|---|
| Ingress | Enter Guest Pass | Create isolated temporary session | Session status |
| Input | Provide goal/data/context | Build guest task envelope | Structured input |
| Inspect | Explore processing | Display structured decision lineage | Logic X-Ray |
| Challenge | Modify constraints/question assumptions | Recalculate or simulate | Updated options |
| Exit | Leave | End temporary session according to policy | Session closed |
| Claim | Request ownership | Authenticate + migrate eligible state | Human Residence |

---

# 30. Accessibility Requirements

The world must remain usable without relying exclusively on spatial graphics.

Every spatial interaction should have a semantic equivalent.

~~~text
Visual location
     ↓
Semantic location label
     ↓
Character / role
     ↓
Current state
     ↓
Available action
~~~

Required support includes:

- readable labels
- keyboard/controller navigation where applicable
- screen-reader-compatible descriptions
- reduced-motion mode
- state text in addition to animation
- non-color-only status indicators
- clear focus state
- predictable navigation
- accessible alternatives to graph-only interactions

---

# 31. Age-Progressive HCI

The same Level-2 world should reveal different detail depths.

### Entry depth

~~~text
Character
  ↓
Job
  ↓
Place
~~~

### Intermediate depth

~~~text
Character
  ↓
Responsibility
  ↓
Relationship
  ↓
Current activity
~~~

### Advanced depth

~~~text
Character
  ↓
Responsibility
  ↓
Context
  ↓
Evidence
  ↓
Route
  ↓
Trace
  ↓
Decision lineage
~~~

The underlying architecture remains the same.

---

# 32. Runtime Truth Rules

This is a critical Level-2 constraint.

### Live

Use only when the backend supplies current state.

### Simulated

Use only inside an explicitly marked sandbox/simulation.

### Historical

Use when displaying recorded events.

### Planned

Use for future/unimplemented architecture.

~~~text
LIVE       → actual runtime event
SIMULATED  → controlled test event
HISTORICAL → recorded event
PLANNED    → future architecture
~~~

The UX must never visually collapse these four categories into one.

---

# 33. HCI Gain of Level 2

Level 2 converts the Level-1 geography into an operational interaction model.

### Primary gains

1. **System comprehension** — Users learn responsibilities through places and characters.
2. **Role transparency** — Each character has a visible responsibility boundary.
3. **Topology comprehension** — Anukor makes cross-home movement understandable.
4. **Observability** — Runtime state can be inspected rather than inferred from decoration.
5. **Explainability** — Decision lineage can be explored through structured evidence and responsibility.
6. **Human agency** — Guest and permanent human spaces clearly separate exploration from ownership.
7. **Progressive disclosure** — A child can understand people and places while an advanced user can inspect topology and trace information.
8. **Safe experimentation** — The Handshake Sandbox and Guest Pass provide controlled exploration without confusing it with production execution.
9. **Architectural integrity** — The UX remains a representation of the backend instead of becoming an independent fantasy system.
10. **Researchability** — The resulting HCI layer creates measurable interaction surfaces for comprehension, transparency, navigation, cognitive load, and perceived agency.

---

# 34. Level-2 Part-I Acceptance Criteria

- [ ] Introduction Page is an active supervision surface, not a static roster.
- [ ] All 15 characters are discoverable.
- [ ] Home selection and character selection are distinct interactions.
- [ ] Anukor is represented through network topology rather than a conventional Home.
- [ ] Character states come from the semantic runtime state model.
- [ ] Audio/text use the same underlying character data.
- [ ] Handshake Sandbox is explicitly separated from production.
- [ ] Relationship visualization distinguishes semantic relationships from invented friendship scores.
- [ ] Network visualizations are backed by actual metrics when presented as live.
- [ ] Context envelopes expose structured handoff information without exposing private chain-of-thought.
- [ ] Loop interception has explicit warning/tripped/escalated states.
- [ ] Protocol translation is shown only where implemented.
- [ ] Distributed tracing is shown only where actual trace data exists.
- [ ] Parallel routing is visually represented as parallel only when execution is actually concurrent.
- [ ] Guest sessions have explicit persistence/isolation semantics.
- [ ] Guest-to-Residence migration requires backend confirmation.
- [ ] Live, simulated, historical, and planned states are visually distinguishable.
- [ ] Accessibility does not depend exclusively on spatial graphics.
- [ ] No character scripts are required for Level-2 Part I completion.

---

# 35. Boundary With Level-2 Part II

Level-2 Part I ends at:

**world entry → roster → supervision → network inspection → guest evaluation**

The next Level-2 part should define the deeper spatial interaction layer rather than repeating this material.

Likely areas include:

- exact city/world geometry
- district-to-district navigation
- Home exterior/interior structure
- room-level interaction
- Bloom navigation behavior
- environmental interaction objects
- camera/viewport rules
- movement states
- spatial accessibility
- human intervention checkpoints
- transition choreography

Character scripts remain outside this part until explicitly requested.

---

## Canonical Level-2 Part-I Model

~~~text
                         CRITERIVOX WORLD
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
              GATE 1                        GATE 2
                 │                             │
        ROSTER & CONVERGENCE              GUEST PASS
                 │                             │
        ┌────────┼────────┐             ┌──────┴──────┐
        │        │        │             │             │
     SPATIAL  BRIEFING  RELATION     EPHEMERAL     CLAIM
      ROSTER             GRAPH        SESSION       SESSION
        │        │        │             │             │
        └────────┼────────┘             └──────┬──────┘
                 │                             │
                 v                             v
             ANUKOR NETWORK              HUMAN RESIDENCE
                 │
        ┌────────┼───────────────┐
        │        │       │       │
      ROUTE   ENVELOPE  TRACE   EVENTS
        │        │       │       │
        └────────┴───────┴───────┘
                 │
                 v
          HUMAN SUPERVISION
                 │
                 v
             DECISION
~~~

**Level-2 Part-I principle:**

> **Criterivox is experienced as a living spatial system, but every visible behavior must remain traceable to a real responsibility, interaction state, runtime event, or explicitly labelled simulation.**

---

# 36. Current Implementation Reconciliation

This section supersedes earlier statements that described the Level-2 Part-I capabilities as purely planned or visually represented.

## Canonical implementation

The operational entry point is now `presentation/lib/world_map_level2_part1_page.dart`, mounted by `presentation/lib/app_shell.dart` at the `civilization` route. The previous `CivilizationPage` remains available as `civilization-legacy` for compatibility while consumers migrate.

The backend source of truth is `src/criterivox/world/level2_part1.py`. It owns:

- the canonical 15-character registry;
- the seven Home registry;
- semantic relationship records;
- character operational and attention states;
- explicit LIVE / SIMULATED / HISTORICAL / PLANNED truth classes;
- Context Envelopes with private-chain-of-thought exclusion;
- route records and trace spans.

`src/criterivox/ui/level2_part1_routes.py` exposes the read/inspection and controlled handshake APIs, and `src/criterivox/ui/routes.py` mounts that router.

## Phase 1–27 implementation status

The Level-2 Part-I phases are implemented as one connected surface rather than 27 unrelated screens.

- **1–11: Roster, briefing, state, relationships and handshake:** implemented through the canonical registry, operational briefing surface, semantic state model, relationship graph, and explicit simulation handshake.
- **12–21: Anukor network layer:** the canonical route/envelope/trace model and inspection APIs are implemented. Intent routing and distributed trace are live in this development runtime. Loop interception, dynamic edge weighting, protocol translation, distributed trace, event dispatch and controlled parallel routing are implemented in the development runtime. Parallel routing is truthfully labelled `LIVE_SIMULATION`; it does not claim production concurrency.
- **22–29: Guest Pass:** the existing `GuestPassManager` and Guest Pass experience remain the single implementation for ephemeral sessions, isolation, X-Ray, trade-off exploration and claim/leave. The Level-2 control plane does not duplicate that subsystem.

## Truth and presentation rules

Live data is only labelled LIVE when supplied by the runtime. Sandbox handshakes are labelled SIMULATED. Historical records remain HISTORICAL and unimplemented architecture remains PLANNED. Character visuals and navigation do not manufacture telemetry.

The Level-2 presentation may expose structured decision lineage, provenance, route metadata and evidence references, but it must not expose private chain-of-thought.

## Test coverage

`tests/test_world_map_level2_part1_runtime.py` covers the canonical 15-character/7-Home registry, Anukor's network residency, semantic state, simulated route + trace continuity, Context Envelope exclusion, and implemented mechanism and remaining truth boundaries.

The older `CivilizationPage` is retained only as a compatibility surface. New Level-2 work must use the canonical Part-I runtime and page rather than adding parallel registries or fabricated telemetry.
