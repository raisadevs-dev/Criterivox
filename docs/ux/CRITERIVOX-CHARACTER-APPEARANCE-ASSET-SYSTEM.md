# CRITERIVOX — CHARACTER APPEARANCE & ASSET SYSTEM

## Canonical Presentation Specification v1.0

**Status:** LOCKED DESIGN DECISION  
**Purpose:** Define how all Criterivox civilian appearances are prepared, stored, reused, and animated in the Flutter application.

---

## 1. Core Decision

All Criterivox civilians will use a **PNG/SVG asset + Flutter-driven presentation approach**.

No character will depend on Rive, a paid animation/export workflow, or a separate character-animation studio as a foundational requirement.

The character artwork provides **identity**. Flutter provides **composition, motion, transitions, effects, state presentation, and interaction**.

> **Artwork defines who the character is. Flutter defines how the character behaves visually.**

This approach applies consistently across all 15 Criterivox civilians.

---

## 2. Source Artwork Model

The primary source may be a character reference sheet containing:

- full-body views
- portraits
- facial expressions
- activity/state poses
- clothing/accessory details
- in-action scenes
- character symbols/emblems
- presentation text or background elements

Reference sheets are treated as **source material**, not as application-ready UI assets.

The useful character artwork is extracted and cleaned from the sheet.

---

## 3. Asset Preparation

For each character, source PNG sheets should be processed into clean reusable assets.

### Required preparation

- remove unwanted/background pixels where appropriate
- isolate the character or required visual component
- crop unnecessary canvas
- preserve transparency
- normalize asset dimensions and framing
- preserve the canonical visual identity
- separate useful expressions, poses, and accessories where possible
- remove presentation-board text, borders, labels, and unrelated UI
- retain sufficient resolution for the largest intended display

### Important limitation

A flattened PNG cannot automatically become a set of independently movable body parts.

If the source contains one flattened character image:

- whole-character movement is possible
- scaling, rotation, fading, translation, and other Flutter animation are possible
- independent arm/hair/face/accessory animation requires separately available or manually separated layers

We therefore do not require artificial decomposition when it would damage the artwork.

---

## 4. Canonical Character Asset Family

Every character should follow the same logical asset model.

```text
CHARACTER/
├── portrait/
│   ├── neutral
│   ├── smiling
│   ├── thinking
│   ├── focused
│   └── surprised
│
├── full_body/
│   ├── front
│   ├── side
│   └── back
│
├── states/
│   ├── idle
│   ├── receive
│   ├── work
│   ├── communicate
│   ├── handoff
│   └── complete
│
├── accessories/
│   └── character-specific details
│
└── identity/
    └── emblem / signature visual where applicable
```

Not every character must have every source asset immediately. Missing assets are documented rather than fabricated.

---

## 5. Canonical Identity Rule

A character is one persistent visual identity throughout Criterivox.

The same canonical character must be used in:

- Bloom / civilization
- character profile
- home
- collaboration environments
- research rooms
- handoff visualizations
- activity indicators
- contextual interactions
- future modules

The rendering context may change.

**The character identity must not.**

Conceptually:

```text
CharacterDefinition
    ├── identity
    ├── visual palette
    ├── portrait assets
    ├── expression assets
    ├── full-body assets
    ├── activity assets
    └── accessory assets
```

---

## 6. Shared Expression System

Where source artwork supports it, characters use five common expression categories:

```text
NEUTRAL
SMILING
THINKING
FOCUSED
SURPRISED
```

These categories provide a consistent presentation API while allowing each character's expression style to remain unique.

Expression changes must not imply a computational event unless tied to an authoritative activity/state.

---

## 7. Shared Activity-State System

The common activity vocabulary is:

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
```

The state mapping is presentation-level:

| State | Presentation intent |
|---|---|
| IDLE | relaxed, low activity |
| RECEIVE | attentive, incoming information |
| WORK | active analysis/work representation |
| COMMUNICATE | presenting or communicating an output |
| HANDOFF | transfer-oriented visual relationship |
| COMPLETE | finished artifact/result, reduced activity |

The authoritative state must come from the underlying system/module.

The avatar does not create computational truth.

---

## 8. Animation Principle

Animation is divided into two categories.

### A. State-grounded animation

Animation corresponds to actual system activity.

Examples:

- incoming artifact movement
- character attention shift
- work-state transition
- artifact handoff
- completion transition
- reasoning graph update

### B. Ambient animation

Purely decorative motion.

Examples:

- subtle breathing
- hair movement
- environmental lighting
- restrained particles
- holographic ambience

Ambient animation must **never claim that computation is occurring**.

---

## 9. Flutter Presentation Stack

The application should primarily use native Flutter capabilities.

```text
PNG / SVG artwork
        ↓
Flutter image composition
        ↓
Transform / opacity / scale / position
        ↓
Flutter animation controllers
        ↓
CustomPaint / graphs / lines / effects
        ↓
state-driven presentation
        ↓
interactive character environment
```

Useful categories include:

- `Image` / `AssetImage` for PNG
- SVG rendering for vector assets
- `AnimationController`
- `Tween`
- `Transform`
- opacity/position transitions
- `CustomPainter` for graphs, lines and visual structures
- Flutter shader capabilities where genuinely useful

External libraries may be introduced when they are free to use and materially simplify a task, but the character system must not depend on a paid proprietary animation pipeline.

---

## 10. Character Visual Responsibility

Characters are **human-facing representations of system activity**.

They are not computational engines.

The architecture is:

```text
Authoritative system state
        ↓
character activity/state
        ↓
visual representation
        ↓
Flutter presentation
```

For example:

```text
Reasoning mechanism performs reasoning
        ↓
Tarkis presents the corresponding activity

Critical evaluation occurs
        ↓
Vivren presents the corresponding activity
```

This preserves the existing many-to-many relationship between characters, capabilities, and computational mechanisms.

---

# 11. Character-Specific Canonical Appearance

## Vivren

**Role:** Context Specialist / Analyst  
**Visual concept:** connecting scattered information into meaningful understanding.

### Visual language

- cool visual temperature
- violet / lavender / cool blue accents
- fluid, layered silhouette
- calm futuristic analytical appearance
- transparent/luminous contextual technology

### Identity anchors

1. silver/lavender hair
2. long pale coat
3. dark inner clothing
4. violet geometric pendant
5. slim layered silhouette

### Hair

- silver-gray base
- lavender/violet undertones
- medium-to-long layered form
- lightweight, slightly tousled
- asymmetric strands
- side-swept fringe
- subtle technological hair attachments

### Clothing

- long pale futuristic coat
- off-white / pale gray
- black structural sections
- layered/asymmetrical panels
- dark high-neck inner garment
- understated technological straps/hardware
- fluid rather than armored silhouette

### Accessories

- dark chain with geometric violet crystal pendant
- small asymmetrical futuristic earrings
- dark compact wrist device
- dark shoulder/back strap system

### Visual effects

- violet ambient illumination
- connected information lines
- contextual highlights
- translucent analytical interfaces

---

## Tarkis

**Role:** Reasoning Specialist / Analyst  
**Visual concept:** logic, alternatives, branching possibilities, structured reasoning.

### Visual language

- warm visual temperature
- amber / orange / warm gold accents
- structured tactical silhouette
- analytical, strategic appearance
- geometric/structured technology

### Identity anchors

1. dark messy hair
2. black tactical clothing
3. pale tactical panels
4. amber accents
5. geometric amber pendant
6. structured silhouette

### Hair

- very dark brown / near-black
- warm brown highlights
- short-to-medium messy textured style
- layered and tousled
- irregular fringe
- volume around crown

### Clothing

- dark futuristic tactical coat/jacket
- black / charcoal dominant
- off-white / pale gray secondary panels
- amber/orange accents
- structured shoulders
- tactical straps and utility details
- segmented layered construction
- dark high-neck technical inner layer

### Accessories

- dark chain with geometric amber/gold pendant
- subtle dark/silver rings
- functional dark wrist device
- consistent amber/orange clothing insignia

### Visual effects

- amber geometric highlights
- branching lines
- path emphasis
- structured node transitions
- logical graph animations

---

## Manis

**Role:** Human Challenge Specialist / Research Companion.

The supplied reference establishes the following appearance direction:

- young adult
- expressive eyes
- natural, artistic style
- comfortable and practical clothing
- modern + traditional elements

Canonical detailed facial, hair, clothing, accessory, pose, and expression specifications are **not yet established in the reviewed source material** and must not be invented in this document.

---

# 12. Remaining Characters

The same canonical asset system applies to:

- Sandre
- Kaelen
- Dharen
- Anuka
- Syvax
- Pramon
- Bodhex
- Medrus
- Epistre
- Veridat
- Viveda
- Anukor

Their detailed visual specifications will be added from their approved character references before asset preparation.

The appearance system itself is already fixed.

---

## 13. Character-Specific Visual Identity Must Remain Distinct

Characters must not become recolored copies of one another.

Each character should have its own combination of:

- silhouette
- face
- hair
- clothing
- accessories
- visual palette
- technological language
- signature object/emblem
- expression character
- role-relevant visual metaphor

The shared system standardizes **asset structure**, not character appearance.

---

## 14. Visual Truth Rule

Functional visualizations must correspond to real system information.

If the UI shows:

- a reasoning branch
- a hypothesis
- an evidence relationship
- an artifact
- a handoff
- a completion state
- a disagreement

then that representation must derive from actual authoritative state/artifacts/events where applicable.

Do not use animation merely to make the application appear intelligent.

> **The UI may dramatize real activity. It must not fabricate activity.**

---

## 15. Asset Naming and Reuse

Asset naming should be semantic and stable.

Examples:

```text
vivren_portrait_neutral
vivren_fullbody_front
vivren_state_work
vivren_accessory_pendant

tarkis_portrait_thinking
tarkis_fullbody_side
tarkis_state_handoff
tarkis_accessory_pendant
```

The final implementation directory may adapt naming to the repository's conventions, but the semantic identity must remain stable.

---

## 16. Final Locked Decision

### Character appearance pipeline

```text
APPROVED CHARACTER REFERENCE
          ↓
clean / extract artwork
          ↓
canonical PNG/SVG assets
          ↓
shared CharacterDefinition
          ↓
Flutter composition
          ↓
state-driven animation
          ↓
environment-specific presentation
```

### What is deliberately NOT required

- Rive
- paid character-animation export
- separate animation studio
- mandatory Blender workflow
- mandatory Figma workflow
- rebuilding characters from scratch for every screen
- independent character redraws for different rooms

### Final principle

> **One canonical character identity, many presentation contexts, Flutter-driven motion.**

This decision applies to the entire Criterivox civilian system.
