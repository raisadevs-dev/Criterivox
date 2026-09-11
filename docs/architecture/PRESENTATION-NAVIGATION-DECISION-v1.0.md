# Criterivox Presentation Navigation Architecture — v1.0

**Status: LOCKED**  
**Decision type:** Presentation / navigation architecture  
**Scope:** Global Criterivox presentation navigation

## Decision

Criterivox's global navigation bar is intentionally limited to **four top-level options**. The navigation should expose the major destinations without turning the application into a wall of menus, because apparently humans occasionally need to know where they are.

### The four top-level options

1. **Introduction Page**
   - Entry/orientation point for Criterivox.
   - Introduces what Criterivox is and how the two sides of the system relate.
   - Provides a clear route into the Criterivox Workers/Civilization side and the human side.

2. **Criterivox Workers / Civilians — Bloom**
   - Opens the Criterivox internal civilization experience.
   - Bloom is the gateway for meeting and exploring the internal Criterivox civilians/workers.
   - Expands into the available internal-civilian meeting and exploration options, including their homes and interaction spaces.
   - This is the primary route for observing and interacting with the AI civilization and its explainability-oriented environment.

3. **Human Civilians / Profile**
   - Opens the human user's own Criterivox residence/profile area.
   - Expands into the user's available rooms and human-side workspace options.
   - Includes the user's private/personal room and, when created or available, collaboration-room options.
   - Supports the human decision-work lifecycle: providing goals/data/context, receiving decisions/options, challenging or accepting them, taking action, and recording outcomes.

4. **Go Further / Come Back**
   - A persistent navigation principle for moving deeper into a selected area and returning without losing orientation.
   - Every major navigation level should provide an obvious way to **go further** into the selected space and **come back** to its parent level.
   - This is not intended to create additional permanent top-level navigation items. It is the movement model within the four-option navigation architecture.

## Navigation model

```text
GLOBAL NAVIGATION BAR
│
├── 1. Introduction
│      └── orient → enter either world
│
├── 2. Criterivox Workers / Civilians — Bloom
│      └── expand → internal civilians → homes → interaction/exploration
│
├── 3. Human Civilians / Profile
│      └── expand → own residence → private room / collaboration room
│
└── 4. Go Further / Come Back
       └── move deeper ↔ return to parent level
```

## Two-world relationship

The navigation must preserve the architectural distinction between:

- **Criterivox Civilization:** the internal AI-worker/civilian world where humans can meet, inspect, question, challenge, and understand the system.
- **Human Residence:** the human-owned world where people actually bring goals, data, and context; receive and challenge decisions; collaborate; act; and record real-world outcomes.

These are two experiential sides of the **same Criterivox system**, not two separate products.

## Presentation principles

- Keep the global navigation bar to **four top-level choices only**.
- Use expansion/drill-down for deeper destinations instead of adding more top-level navigation items.
- Preserve user orientation at every depth.
- Every deeper navigation state must have a clear **come back** path.
- Every parent destination should expose an intentional **go further** path when deeper content exists.
- Bloom remains the gateway into the Criterivox internal civilization rather than becoming a generic collection of unrelated pages.
- Human Profile remains the gateway into the individual human residence and its rooms.
- Navigation should reveal the architecture of Criterivox rather than obscure it.

## Locked terminology

Use these presentation concepts consistently unless a later architectural decision explicitly changes them:

- **Introduction Page**
- **Criterivox Workers / Civilians**
- **Bloom** as the internal-civilization gateway
- **Human Civilians / Profile**
- **Human Residence**
- **Private Room**
- **Collaboration Room**
- **Go Further**
- **Come Back**

## Relationship to existing architecture

This decision complements the existing Character Society and Human Residence architecture. The Criterivox character homes remain internal civilization spaces, while the human profile/residence is the human-side workspace. The navigation architecture provides the presentation-level doors into those spaces without changing the underlying character, domain, intelligence, or runtime responsibilities.

## Architectural invariant

> **Four doors at the top. Deeper rooms behind them. Every room knows how to go further and how to come back.**

This is the locked presentation-navigation rule for Criterivox v1.0.
