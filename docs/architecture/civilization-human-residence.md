# Criterivox Civilization ↔ Human Residence — S6

## Architectural relationship

Criterivox has two related but distinct environments:

1. **Criterivox Civilization** — the computational environment of specialised workers/characters and their homes.
2. **Human Residence** — the human-side environment where goals, challenges, decisions, actions and real-world results originate and return.

The human is not another autonomous Criterivox worker. Syvax is the interaction/gateway boundary between the human and the computational environment.

## Flow

```text
HUMAN RESIDENCE
 Goal / question / data / context
             ↓
          SYVAX
 dialogue / routing / orchestration
             ↓
      DOMAIN EVENTS
             ↓
 CRITERIVOX CIVILIZATION
             ↓
 S5 Data Foundation
             ↓
 S6 Context Intelligence
             ↓
 Dharen — Context Master
             ↓
 ContextFrame
       ┌─────┴─────┐
       │           │
   normal       trigger
       │           ↓
       │         Anuka
       │      Context Adaptor
       │           ↓
       └─────┬─────┘
             ↓
   downstream workers
             ↓
 result / evidence / options
             ↓
          SYVAX
             ↓
 HUMAN RESIDENCE
 challenge → accept/reject → action
             ↓
       real-world result
             ↓
   new evidence / context
             ↓
      Criterivox again
```

## Bloom

Bloom is the capability-discovery and civilization/world surface. It exposes workers/homes and their responsibilities. It is not a second source of computational truth and must not duplicate S5/S6 state.

## Syvax

Syvax receives human intent, routes and orchestrates interaction, and translates authoritative computational state into a usable presentation. Syvax does not own S6 context state or learned-model authority.

## Human Residence

The Human Residence represents the human decision environment. Its loop is:

```text
Goal → Data + Context → Criterivox → Decision/Options
→ Challenge → Accept/Reject → Action
→ Real-world Result → Results Journal / new context
```

This preserves human decision authority while allowing outcomes to become future evidence through the normal provenance-aware data/context pipeline.

## Character/model separation

Characters are representations of computational responsibilities. A character is not itself an ML model. Dharen and Anuka are computational agents exposed through the character/presentation layer; their computational contracts remain independent of their visual representation.

## S5/S6 continuity

Completed sprints remain reusable architectural foundations. S5 DataFoundation, Sandre stewardship, browser residency and provenance are consumed by S6. Earlier Bloom and Syvax decisions are refined in S6 when integration requirements expose gaps. Sprint completion is therefore a capability milestone, not a prohibition on later integration/refinement.
