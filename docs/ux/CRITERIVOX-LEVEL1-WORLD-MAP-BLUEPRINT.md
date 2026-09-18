# Criterivox Level-1 World Map Blueprint — HCI Civilization

**Status:** UX BLUEPRINT — LEVEL 1  
**Version:** 1.0  
**Date:** 2026-09-18  
**Scope:** Criterivox world geography, spatial hierarchy, character placement, public-facing place naming, and Level-1 HCI behavior  
**Audience:** UX/design, Flutter presentation, architecture, research, mentor review  
**Script status:** Intentionally excluded. Dialogue, quests, narration, missions, and character scripts are outside this document.

---

## 1. Purpose

Criterivox is being represented as an explorable, game-like world to improve human-computer interaction.

The world is not a separate game layered on top of Criterivox. It is a spatial representation of the existing system.

> **Every important place, route, resident, object, and visible activity must correspond to a meaningful system concept.**

The world turns invisible computational structures into an environment that people can explore.

The Level-1 map defines **where things are and why they exist**. It does not define detailed dialogue, quests, animations, or implementation contracts.

---

# 2. HCI World Model

Criterivox uses one shared world with progressive depth rather than separate worlds for different ages.

```text
                         CRITERIVOX WORLD
                                |
                +---------------+---------------+
                |                               |
        GATE 1 — AI CIVILIZATION        GATE 2 — HUMAN TERRITORY
                |                               |
        Understand the system             Work with the system
                |                               |
        Homes + roles + network          Residence + collaboration
                |                               |
                +---------------+---------------+
                                |
                         OUTER WORLD
                 Countryside + Coast + Commons
```

### Level-1 experience

At Level 1, a person should be able to understand:

- where they are
- who lives or works there
- what that place is responsible for
- how places connect
- where information moves
- where a human enters the process
- where decisions and outcomes return

Technical detail is progressively disclosed later.

---

# 3. World Hierarchy

```text
CRITERIVOX WORLD
│
├── GATE 1 — CRITERIVOX CIVILIZATION
│   │
│   ├── CIVIC CENTRE
│   │   ├── Town Hall
│   │   ├── Civilization Registry
│   │   └── World Map Office
│   │
│   ├── BLOOM NEXUS
│   │   └── The Bloom
│   │
│   ├── CHARACTER DISTRICTS
│   │   ├── Context & Data District
│   │   │   ├── Context House
│   │   │   │   ├── Dharen
│   │   │   │   └── Anuka
│   │   │   └── Data Stewardship House
│   │   │       ├── Sandre
│   │   │       └── Kaelen
│   │   │
│   │   ├── Interaction District
│   │   │   └── Gateway House
│   │   │       └── Syvax
│   │   │
│   │   ├── Intelligence District
│   │   │   └── Reasoning House
│   │   │       ├── Vivren
│   │   │       └── Tarkis
│   │   │
│   │   ├── Decision & Insight District
│   │   │   └── Decision House
│   │   │       ├── Pramon
│   │   │       ├── Bodhex
│   │   │       └── Manis
│   │   │
│   │   ├── Evidence & Verification District
│   │   │   └── Evidence House
│   │   │       ├── Medrus
│   │   │       ├── Epistre
│   │   │       └── Veridat
│   │   │
│   │   └── Knowledge District
│   │       └── Knowledge House
│   │           └── Viveda
│   │
│   ├── NETWORK TERRITORY
│   │   └── Anukor
│   │       ├── Routing Junctions
│   │       ├── Network Streets
│   │       ├── Bridges
│   │       └── Signal Towers
│   │
│   └── CIVIC COMMONS
│       ├── Discovery Playground
│       ├── Observation Treehouses
│       ├── Gardens
│       ├── Parks
│       └── Civic Streets
│
├── OUTER CRITERIVOX WORLD
│   ├── Countryside Village
│   ├── Fields
│   ├── Streams
│   └── Criterivox Coast
│       ├── Information Harbour
│       ├── Transfer Pier
│       └── Beach
│
└── GATE 2 — HUMAN TERRITORY
    ├── Human Residence District
    │   └── Human Residence
    │       ├── Private Room
    │       ├── Collaboration Room
    │       ├── Decision Desk
    │       └── Results Journal
    │
    ├── Collaboration Commons
    │   ├── Meeting Hall
    │   ├── Project Rooms
    │   └── Shared Workspaces
    │
    └── Guest District
        └── Guest Camp
            ├── Welcome Pavilion
            ├── Goal Desk
            ├── Context Table
            └── Temporary Decision Space
```

---

# 4. Gate 1 — Criterivox Civilization

## 4.1 Civic Centre

The Civic Centre is the public orientation area of the AI civilization.

### Town Hall
**Function:** Civilization-level orientation and system overview.

The Town Hall answers:

- What is Criterivox?
- What parts exist?
- What is currently active?
- How do the districts relate?

It is an orientation surface, not an AI agent.

### Civilization Registry
**Function:** Roster and identity.

It presents character identity, role, responsibility, residency, current state, and meaningful relationships.

### World Map Office
**Function:** Spatial navigation and topology.

It provides the explorable map of districts, Homes, routes, and major system boundaries.

---

# 5. The Bloom — Central Nexus

The Bloom is the spatial heart of the civilization.

```text
                    CHARACTER DISTRICTS
                    /   |   |   |   \\
                   /    |   |   |    \\
                  /     |   |   |     \\
                 +------ BLOOM --------+
                        |
                 NETWORK MOVEMENT
                        |
                  HUMAN CONNECTION
```

### HCI purpose

The Bloom provides:

- spatial navigation
- civilization overview
- Home discovery
- visible system activity
- cross-home relationship visualization
- human-intervention visibility
- return point to the larger world

### Architectural boundary

The Bloom **visualizes** system state. It does not become:

- an agent
- an orchestration engine
- a routing authority
- a provenance database
- a permission authority
- a decision authority

The underlying backend remains authoritative.

---

# 6. Character Districts and Jobs

Character placement uses responsibility as the primary geographic organizing principle.

## 6.1 Data Stewardship House

**District:** Context & Data District

**Residents:**

- **Sandre — Contextual Weaving**
  - Connects information across contexts and platforms.
- **Kaelen — Temporal & Environmental Context**
  - Accounts for time and environmental conditions affecting interpretation.

### Place structure

```text
Data Stewardship House
├── Intake Desk
├── Data Stewardship Room
├── Context Connection Room
├── Temporal Context Room
└── Data Archive
```

**HCI meaning:** Data is not merely dumped into a system. It is received, understood, connected, and qualified.

---

## 6.2 Context House

**District:** Context & Data District

**Residents:**

- **Dharen — Structural Context**
  - Organizes the problem and establishes surrounding context.
- **Anuka — Adaptive Context**
  - Adjusts interpretation as contextual conditions change.

### Place structure

```text
Context House
├── Situation Room
├── Context Observatory
├── Framing Desk
├── Change Garden
└── Context Workshop
```

**HCI meaning:** The same information can mean different things under different conditions. Context therefore becomes a place users can inspect rather than an invisible parameter.

---

## 6.3 Gateway House

**District:** Interaction District

**Resident:**

- **Syvax — Human-Machine Dialogue**
  - Facilitates communication between the user and the system.

### Place structure

```text
Gateway House
├── Reception Hall
├── Intent Desk
├── Dialogue Room
├── Input Studio
├── Output Gallery
└── Human Steering Room
```

**HCI meaning:** This is the primary human-machine interaction boundary.

Syvax may feel like a guide or receptionist, but the underlying computational responsibilities remain distributed across Criterivox.

---

## 6.4 Reasoning House

**District:** Intelligence District

**Residents:**

- **Vivren — Critical Reasoning**
  - Examines assumptions and evaluates reasoning strength.
- **Tarkis — Hypothesis & Evidence**
  - Forms and evaluates hypotheses using available evidence.

### Place structure

```text
Reasoning House
├── Analysis Chamber
├── Assumption Desk
├── Hypothesis Workshop
├── Alternative Room
└── Reasoning Gallery
```

**HCI meaning:** Users can see that reasoning is a process involving assumptions, alternatives, hypotheses, and evidence rather than a mysterious answer generator.

---

## 6.5 Decision House

**District:** Decision & Insight District

**Residents:**

- **Pramon — Empirical Proof**
  - Examines whether conclusions are supported by empirical evidence.
- **Bodhex — Perception & Insight**
  - Transforms analyzed information into meaningful insights.
- **Manis — Deliberative Reasoning**
  - Considers alternatives, implications, and decisions.

### Place structure

```text
Decision House
├── Evidence Desk
├── Insight Room
├── Alternatives Chamber
├── Trade-off Room
└── Decision Desk
```

**HCI meaning:** A decision is presented as an inspectable synthesis of evidence, insight, alternatives, and implications.

---

## 6.6 Evidence House

**District:** Evidence & Verification District

**Residents:**

- **Medrus — Knowledge Retention**
  - Maintains historical knowledge, previous findings, and patterns.
- **Epistre — Knowledge & Explanation Transfer**
  - Communicates how knowledge and findings were obtained.
- **Veridat — Verification**
  - Checks reliability and verification of findings.

### Place structure

```text
Evidence House
├── Knowledge Archive
├── Evidence Library
├── Explanation Chamber
├── Verification Bureau
└── Review Room
```

**HCI meaning:** Evidence can be inspected, retained, explained, and verified instead of appearing as an unexplained citation layer.

---

## 6.7 Knowledge House

**District:** Knowledge District

**Resident:**

- **Viveda — Knowledge Base & Knowledge Support**
  - Connects findings with established knowledge and resources.

### Place structure

```text
Knowledge House
├── Knowledge Hall
├── Reference Library
├── Learning Desk
├── Transfer Workshop
└── Knowledge Garden
```

**HCI meaning:** Findings become reusable knowledge while remaining sensitive to context.

---

# 7. Anukor — The Network Resident

Anukor does not have a conventional permanent Home.

**Role:** Adaptive Transfer

Anukor represents system-level adaptation and transfer between contexts.

### Geographic representation

```text
                 Signal Tower
                      |
        Bridge ---- Junction ---- Bridge
          |             |            |
   Network Street   Anukor Path   Network Street
          |             |            |
       District ---- Bloom ---- District
```

### Network entities

- **Routing Junction:** decision/routing intersection
- **Network Street:** normal information movement
- **Bridge:** connection between otherwise separated areas
- **Signal Tower:** visible network/system status point
- **Anukor Path:** dynamic route through the civilization

Anukor's movement should represent meaningful routing or transfer activity, not random wandering.

---

# 8. Civic Commons

The civilization also needs non-work spaces so users can understand the world without entering technical rooms immediately.

## Discovery Playground

**Purpose:** Low-pressure exploration.

For younger users, this is where basic concepts such as people, places, movement, connections, and simple cause-and-effect can be discovered.

It is not a points, coins, combat, or reward system.

## Observation Treehouses

**Purpose:** Overview and relationship inspection.

A treehouse provides a higher-level spatial view of districts and active connections.

## Gardens and Parks

**Purpose:** Reflection, learning, and non-operational orientation.

They provide breathing space between dense information environments.

## Civic Streets

**Purpose:** Navigation.

Streets make movement between functional locations understandable.

---

# 9. Outer Criterivox World

The outer world provides contextual, non-office environments.

## Countryside Village

Represents ordinary contextual life and simple real-world situations.

It provides an accessible environment for understanding that decisions happen within circumstances rather than inside isolated data tables.

## Fields and Streams

These are contextual landscape elements.

They should remain semantically lightweight at Level 1 and can later become richer representations of changing conditions, flows, or examples.

## Criterivox Coast

The coast represents outward movement and transfer.

### Information Harbour
Arrival and exchange point for information.

### Transfer Pier
Represents information or knowledge moving toward another context.

### Beach
A low-density exploration area for introductory interaction.

The coast is not another computational department.

---

# 10. Gate 2 — Human Territory

Gate 2 is intentionally different from the AI civilization.

The human does not receive another character Home.

The human receives a **Residence**.

## Human Residence

### Private Room

The user's personal decision workspace.

```text
Private Room
├── Goal Area
├── Data Area
├── Context Area
├── Options Area
├── Challenge Area
├── Action Area
└── Results Journal
```

### Collaboration Room

A shared human workspace.

```text
Collaboration Room
├── Meeting Area
├── Project Area
├── Shared Context
└── Decision Area
```

### Decision Desk

The human-facing point for reviewing and acting on decision support.

### Results Journal

The persistent reflection point for:

- expected outcomes
- actual outcomes
- differences
- relevant context
- evidence
- uncertainty
- follow-up learning

The journal closes the loop between system output and real-world experience.

---

# 11. Collaboration Commons

The Collaboration Commons is a shared human territory.

### Meeting Hall
For group-level discussion and coordination.

### Project Rooms
For focused collaborative work.

### Shared Workspaces
For multi-person decision preparation.

Human roles remain:

| Role | Meaning |
|---|---|
| House Owner | Owns the residence/workspace and governance |
| Resident | Participating member with assigned permissions |
| Guest | Temporary participant with limited access |

The visual role must correspond to actual authorization rules.

---

# 12. Guest District

## Guest Camp

The Guest Camp is temporary territory for people who have not established a permanent Human Residence.

### Place structure

```text
Guest Camp
├── Welcome Pavilion
├── Goal Desk
├── Context Table
└── Temporary Decision Space
```

The Guest Camp represents an ephemeral session.

It must not silently imply that temporary work has become permanent data.

---

# 13. Network Relationship Model

The world has two structures.

### Spatial hierarchy

```text
World
  -> Gate
    -> District
      -> House
        -> Room
          -> Desk / Object
```

### Operational network

```text
Human
  |
  v
Syvax
  |
  v
Anukor
  |
  +--> Data / Context
  |
  +--> Intelligence / Reasoning
  |
  +--> Evidence / Verification
  |
  +--> Decision / Insight
  |
  v
Knowledge / Explanation
  |
  v
Human Decision
  |
  v
Real-World Outcome
  |
  v
Results Journal
  |
  v
Future Context / Knowledge
```

This is a conceptual lifecycle, not a claim that every runtime operation follows one fixed sequence.

Anukor provides dynamic network movement rather than forcing the backend into a rigid linear pipeline.

---

# 14. Naming System

Public-facing names follow a consistent semantic vocabulary.

| Place type | Meaning |
|---|---|
| Gate | Major boundary between human/system territories |
| District | Related group of responsibilities |
| House | Character workplace/residence |
| Town Hall | Civilization-level orientation |
| Hall | Public/shared area |
| Chamber | Deeper inspection or deliberation |
| Workshop | Transformation or active work |
| Bureau | Specialized institutional function |
| Archive | Retained historical information |
| Library | Organized knowledge/evidence |
| Desk | Focused task or interaction point |
| Observatory | Context/state observation |
| Garden | Reflection/learning |
| Street | Normal spatial connection |
| Junction | Routing intersection |
| Bridge | Cross-area connection |
| Tower | Elevated system/network status point |
| Camp | Temporary participation |
| Residence | Human-owned personal workspace |
| Playground | Accessible exploration |
| Harbour/Pier | Transfer or arrival metaphor |
| Beach | Low-density exploration area |
| Bloom | Central spatial nexus |

The names are semantic UI language, not backend service names.

---

# 15. Living and Non-Living Entities

## Living entities

### Humans
- Human visitor
- House Owner
- Resident
- Guest

### Criterivox characters
- Dharen
- Vivren
- Tarkis
- Sandre
- Pramon
- Syvax
- Bodhex
- Medrus
- Epistre
- Manis
- Anuka
- Veridat
- Viveda
- Kaelen
- Anukor

Characters represent computational responsibilities through interaction.

They are not independent backend owners of those capabilities.

## Non-living entities

### Functional
- Desks
- Chambers
- Workshops
- Archives
- Libraries
- Bureaus
- Rooms
- Halls
- Tables
- Towers
- Gates

### Spatial
- Streets
- Bridges
- Junctions
- Piers
- Harbours
- Paths
- Fields
- Streams
- Parks
- Gardens
- Beach

### System-visual
- Bloom
- Routes
- Context flows
- Activity indicators
- Provenance visualizations
- Checkpoint markers

System-visual entities must only represent data that actually exists in the underlying system.

---

# 16. Level-1 Progressive Disclosure for Ages 5–30

The world remains the same while interpretation depth changes.

| Age/depth | Primary understanding |
|---|---|
| 5–8 | People, places, movement, simple responsibilities |
| 9–12 | Jobs, cooperation, information moving between places |
| 13–17 | Context, reasoning, evidence, alternatives, human intervention |
| 18–24 | Decision support, uncertainty, provenance, outcomes |
| 25–30 | Operational topology, evidence lineage, checkpoints, context transfer |

These are UX depth targets, not rigid age restrictions.

The same Town Hall, Bloom, Houses, Streets, and Residence can serve all users.

---

# 17. Game-Like HCI Rules

The game-like quality comes from **exploration and interaction**, not competition.

### Allowed interaction metaphors

- exploration
- discovery
- movement
- spatial navigation
- visiting Homes
- observing system activity
- inspecting relationships
- unlocking deeper information through understanding
- temporary exploration spaces
- visual state changes backed by runtime events

### Explicitly not required

- coins
- points
- combat
- leaderboards
- artificial rewards
- character battles
- random wandering
- meaningless collectibles
- childish gamification

The objective is better HCI, not turning decision support into an arcade cabinet.

---

# 18. World-to-Backend Mapping Rule

The presentation layer must preserve architectural separation.

```text
                    WORLD / HCI
                         |
          +--------------+--------------+
          |              |              |
       Places        Characters       Routes
          |              |              |
          +--------------+--------------+
                         |
                  Read / interaction
                         |
                         v
                Presentation Layer
                         |
                         v
                  Application Layer
                         |
                         v
                  Domain / Intelligence
                         |
                         v
               Infrastructure / Data
```

### Principle

A visible place is a **representation of responsibility**.

A visible character is a **representation of responsibility**.

A visible route is a **representation of meaningful information or control movement**.

The backend remains authoritative.

---

# 19. Research and HCI Gain

The world-map approach provides several research and product gains.

## 19.1 Cognitive gain

Spatial organization gives users a persistent mental model.

Instead of remembering abstract modules, the user can remember:

> “That responsibility lives in that place.”

## 19.2 Explainability gain

Explanation becomes spatially inspectable.

A user can move from:

**result → responsible role → evidence → reasoning → context**

rather than receiving one opaque answer.

## 19.3 Transparency gain

Characters expose responsibility boundaries.

The interface can communicate:

- who is responsible
- what they do
- what they receive
- what they produce
- where they hand work
- what state they are in

## 19.4 Human-agency gain

Gate 2 physically separates human ownership from AI responsibilities.

The Human Residence makes the user's:

**goal → challenge → decision → action → outcome**

visible as a human-controlled lifecycle.

## 19.5 Navigation gain

The world itself becomes an information architecture.

Users can navigate by:

- location
- role
- relationship
- workflow
- system state

rather than only through menus.

## 19.6 Progressive-disclosure gain

The same world can serve different comprehension levels without exposing every technical detail simultaneously.

## 19.7 Collaboration gain

Shared spaces make human-human collaboration and AI-human collaboration visibly distinct.

## 19.8 Observability gain

The Bloom, streets, junctions, towers, and routes can expose actual runtime activity without pretending that visual effects are backend truth.

## 19.9 Research gain

The world creates a testable HCI layer for investigating questions such as:

- Does spatial representation improve system understanding?
- Does role-based navigation improve explainability?
- Does visible information flow improve comprehension?
- Does human-residence separation improve perceived agency?
- Does progressive disclosure reduce cognitive load?
- Does character-mediated presentation improve understanding of complex AI responsibilities?

These are research questions, not pre-claimed results.

## 19.10 Architectural gain

The world can evolve independently of the underlying computational architecture because the mapping is based on responsibilities and read models rather than hard-coded fantasy mechanics.

---

# 20. Level-1 Acceptance Criteria

The Level-1 world map is structurally complete when:

- [ ] Gate 1 and Gate 2 are clearly separated.
- [ ] The Bloom is positioned as the central nexus.
- [ ] All 15 Criterivox characters have a defined spatial presence.
- [ ] Anukor remains a roaming network resident without a conventional Home.
- [ ] Every character is associated with a meaningful responsibility area.
- [ ] Human Residence is distinct from AI Homes.
- [ ] Guest Camp is distinct from permanent residence.
- [ ] Major streets, bridges, junctions, and routes can express system relationships.
- [ ] Civic, functional, natural, and residential spaces are distinguishable.
- [ ] Place names are semantic and consistent.
- [ ] The map can be understood before technical telemetry is exposed.
- [ ] No Level-1 element requires character dialogue or scripted quests.
- [ ] Visualized system activity is backed by actual runtime state when presented as live.
- [ ] Planned/simulated behavior is explicitly distinguished from implemented behavior.

---

# 21. Future Levels

This document intentionally stops at Level 1.

### Level 2 — Spatial Interaction Specification
Will define:

- exact map layout
- paths
- navigation transitions
- Home entrances
- room adjacency
- Bloom-to-Home transitions
- interaction points
- camera/viewport behavior

### Level 3 — HCI Interaction Specification
Will define:

- user actions
- inspection behavior
- hover/tap/click states
- accessibility
- progressive disclosure behavior
- character interaction states
- intervention points

### Level 4 — Runtime Mapping
Will define:

- backend event → visual state
- route event → route visualization
- character state → animation state
- provenance → visual lineage
- checkpoint → intervention visualization

### Level 5 — Character Scripts
Dialogue, introductions, guided exploration, quests, missions, and narrative behavior belong here.

**No scripts are defined in this Level-1 blueprint.**

---

# 22. Canonical Summary

```text
CRITERIVOX WORLD
│
├── GATE 1 — AI CIVILIZATION
│   │
│   ├── Civic Centre
│   ├── Bloom Nexus
│   ├── Context & Data District
│   │   ├── Context House
│   │   └── Data Stewardship House
│   ├── Interaction District
│   │   └── Gateway House
│   ├── Intelligence District
│   │   └── Reasoning House
│   ├── Decision & Insight District
│   │   └── Decision House
│   ├── Evidence & Verification District
│   │   └── Evidence House
│   ├── Knowledge District
│   │   └── Knowledge House
│   ├── Network Territory
│   │   └── Anukor
│   └── Civic Commons
│
├── OUTER WORLD
│   ├── Countryside Village
│   ├── Fields & Streams
│   └── Criterivox Coast
│
└── GATE 2 — HUMAN TERRITORY
    ├── Human Residence District
    ├── Collaboration Commons
    └── Guest District
```

**Core HCI proposition:**

> **Criterivox becomes an explorable representation of its own intelligence architecture: people meet responsibilities as characters, responsibilities occupy meaningful places, information travels through a visible network, evidence and reasoning can be inspected spatially, and humans retain a distinct territory for challenging, deciding, acting, and learning from outcomes.**
