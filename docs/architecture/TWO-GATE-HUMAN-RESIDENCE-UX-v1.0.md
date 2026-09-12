# Criterivox Two-Gate Experience — v1.0

## Purpose

The presentation now opens as an orientation experience with two architectural gates rather than dropping a first-time human directly into an internal work console.

## Gate 1 — Criterivox Civilization

**Message:** “Meet the people who assist you make the decision.”

This is the AI side of Criterivox. A human can enter the internal civilization to:

- meet characters;
- visit character homes;
- understand roles and responsibilities;
- inspect relationships and collaboration;
- observe information movement;
- inspect evidence and provenance;
- challenge reasoning;
- inspect explanations; and
- observe decisions being formed.

Character homes remain the architectural spaces already defined for the society, including Sandre + Kaelen (Data Foundation / Data Stewardship), Dharen + Anuka (Context), Vivren + Tarkis (Intelligence / Reasoning), Medrus + Epistre + Veridat (Evidence / Experimentation / Verification), Pramon + Bodhex (Planning / Decision), Manis (Human Challenge), Viveda (Knowledge), and Anukor (cross-home network roaming).

The purpose is transparency: the human is invited to see how the system arrived at a result instead of being asked to trust an opaque answer.

## Gate 2 — Human Residence

**Message:** “This is where your actual problem lives.”

The human side is separate from character homes. A signed-in human owns a Human Residence. The residence is the workspace for personal decision work and collaboration.

### Entry modes

- **Private house:** personal residence created by login/sign-up.
- **Club / building:** collaboration-oriented space for shared work.
- **Guest Pass:** temporary experience using Goal + Data + Context without a permanent residence.

### Private Room

The intended decision lifecycle is:

`GOAL → DATA + CONTEXT → CRITERIVOX → DECISIONS + OPTIONS → HUMAN CHALLENGE → REJECT / ACCEPT → ACTION → REAL RESULT → RESULTS JOURNAL → FUTURE DECISIONS`

### Collaboration Room

Human roles:

| Role | Meaning |
| --- | --- |
| House Owner | Owns the residence/workspace |
| Resident | Teammate/member who works there |
| Guest | Temporary visitor with limited access |

## Portable Bloom + Syvax Companion

A persistent floating Bloom/Syvax companion is available across the presentation. It is intentionally separate from the permanent navigation bar.

Primary behavior:

- starts as a compact floating icon;
- expands into a lightweight control surface;
- routes to Bloom;
- opens independent character chat with Syvax;
- provides a direct path into steering/work inspection;
- remains available while navigating rooms; and
- is intended to be movable so the human can place it away from content.

The companion is a presentation control, not a replacement for the underlying runtime routing or character system.

## Navigation rule

The existing locked navigation architecture remains the source of truth: four top-level navigation concepts, with deeper destinations reached through expansion/drill-down. The two gates are presentation destinations inside that model, not a new fifth navigation system.

## Implementation

The Flutter presentation shell now exposes:

- Introduction / two-gate landing;
- Gate 1 civilization overview;
- Gate 2 human residence overview;
- Guest Pass entry;
- independent character chat;
- Bloom global nexus;
- existing Home 03 Syvax gateway;
- existing data/context workspaces; and
- persistent Bloom/Syvax companion.

The implementation uses the existing Criterivox theme, runtime client, character animation layer, Bloom page, and character chat page rather than creating a parallel presentation stack.
