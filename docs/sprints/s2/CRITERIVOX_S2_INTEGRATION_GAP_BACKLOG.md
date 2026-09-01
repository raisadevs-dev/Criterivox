# CRITERIVOX S2 — INTEGRATION GAP & BACKLOG REPORT

## Purpose

This report records, in concrete engineering terms, **why the current Python/application side and Flutter presentation side are not yet connected at runtime**, what each side currently does, what is missing between them, and the backlog required to close the gap.

This is a recovery/handoff document. It is intentionally conservative: it records what has been demonstrated versus what has only been implemented locally.

---

# 1. Current System Split

Criterivox currently has two relevant runtime areas:

```text
F:\Rsearch Project\Criterivox\
│
├── src\
│   └── criterivox\
│       └── Python application / domain / behavior
│
└── presentation\
    ├── lib\
    │   ├── character\
    │   └── presentation\
    └── test\
        └── Flutter presentation tests
```

This separation is intentional.

The architecture does NOT require Python and Flutter to be merged into one codebase.

The intended relationship is:

```text
PYTHON APPLICATION
      │
      │  application/domain state
      ▼
PRESENTATION BOUNDARY
      │
      │  presentation-state contract
      ▼
FLUTTER
      │
      ▼
VISIBLE CHARACTER
```

The missing part is the actual runtime transport/connection represented by the middle arrow.

---

# 2. What Python Currently Provides

The Python side contains the technology-independent behavioral foundation.

Relevant concepts include:

- Character model
- Character registry
- 15 character definitions
- Event architecture
- State system
- Behavior engine
- Attention regulation
- Communication
- Handoff
- Humor rules
- Bloom/application integration
- Presentation abstraction

The Python side is intended to decide **what the system is doing and what the presentation should communicate**.

Examples:

```text
ANALYSIS_STARTED
        ↓
relevant agent selected
        ↓
agent state = WORK
        ↓
attention / communication determined
        ↓
presentation state can be derived
```

Python therefore contains the system behavior.

---

# 3. What Flutter Currently Provides

Flutter currently provides the visual presentation environment.

The Flutter project contains:

```text
presentation/lib/
```

with presentation-oriented components including:

- `PresentationState`
- `PresentationAdapter`
- activity presentation
- activation presentation
- attention presentation
- Bloom presentation
- character presentation
- communication presentation
- handoff presentation
- motion/reduced-motion presentation
- responsive presentation
- character identity
- character visual widget

Flutter can therefore take a presentation state and render a character.

Example conceptual input:

```text
agentId = Dharen
characterState = WORK
active = true
reducedMotion = false
```

The Flutter character widget can render a corresponding visual state.

---

# 4. The Critical Problem

The current Flutter demo creates its own presentation state locally.

The current application entry point initializes a state equivalent to:

```text
Dharen
IDLE
active = true
```

inside Flutter.

That means:

```text
Flutter
  ↓
creates PresentationState
  ↓
renders Dharen
```

rather than:

```text
Python
  ↓
creates/derives application state
  ↓
presentation boundary
  ↓
Flutter receives state
  ↓
renders Dharen
```

The second pipeline has NOT yet been demonstrated.

---

# 5. Why the Existing Character Does Not Prove Backend Integration

Seeing a character on screen proves:

```text
Flutter rendering works
```

It does not prove:

```text
Python behavior drives Flutter
```

The current visual path is approximately:

```text
main.dart
   ↓
PresentationAdapter
   ↓
PresentationState
   ↓
CharacterPresentation
   ↓
CharacterVisual
   ↓
screen
```

The Python behavior engine is not shown in that path.

Therefore the current character is a **working presentation prototype**, not proof of an end-to-end connected Criterivox runtime.

---

# 6. What Is Missing

The missing connection consists of several separate engineering decisions.

## 6.1 Runtime communication mechanism

There is currently no proven runtime mechanism through which the running Python application sends presentation state to the running Flutter application.

Possible future mechanisms include:

- local HTTP API
- WebSocket
- process bridge
- local IPC
- another explicitly chosen transport

No transport should be selected merely because it is familiar.

The choice must be based on Criterivox requirements.

---

## 6.2 Shared contract

Python and Dart currently have conceptually similar presentation information, but that is not the same as having a formally enforced cross-runtime contract.

The project needs a defined representation such as:

```text
PresentationState
```

with an agreed schema.

Example conceptual contract:

```text
agent_id
character_state
active
attention/prominence
communication state
handoff information
reduced_motion
```

The exact fields must be decided from the actual current architecture rather than invented casually.

---

## 6.3 Serialization

The presentation state must have a transport representation.

For example:

```text
Python object
      ↓
serialized message
      ↓
transport
      ↓
Dart decoding
      ↓
PresentationState
```

The serialization format must be explicitly documented.

---

## 6.4 Flutter receiver

Flutter needs a runtime component responsible for receiving external application state.

It should not contain the behavior engine.

Its responsibility should be approximately:

```text
receive
↓
validate
↓
convert
↓
notify presentation
```

---

## 6.5 Python sender / adapter

Python needs a boundary responsible for exposing presentation updates without coupling domain behavior directly to Flutter widgets.

Conceptually:

```text
Behavior Engine
      ↓
Presentation Adapter
      ↓
Presentation Output
      ↓
Transport
```

The domain should not import Flutter.

---

## 6.6 Lifecycle handling

The system needs defined behavior when:

- Flutter starts before Python
- Python starts before Flutter
- Flutter disconnects
- Python produces no update
- malformed state arrives
- unsupported state arrives
- application shuts down
- presentation reconnects

None of these should be left to accidental behavior.

---

# 7. Current Architecture vs Required Architecture

## CURRENT

```text
PYTHON
│
├── Domain
├── Behavior
├── Attention
├── Communication
├── Handoff
├── Humor
└── Presentation abstraction

         X

FLUTTER
│
├── PresentationState
├── PresentationAdapter
├── CharacterPresentation
└── Visual character
```

The `X` represents the unproven runtime connection.

---

## REQUIRED

```text
PYTHON
│
├── Domain
├── Behavior
├── Attention
├── Communication
├── Handoff
├── Humor
│
└── Presentation Adapter
          │
          ▼
   PRESENTATION CONTRACT
          │
          ▼
   RUNTIME TRANSPORT
          │
          ▼
   FLUTTER RECEIVER
          │
          ▼
   PresentationState
          │
          ▼
   Character Presentation
          │
          ▼
       VISUAL
```

---

# 8. First Proof We Actually Need

Do NOT begin by building the entire 15-agent visual ecosystem.

The first integration proof should use **one agent and one state transition**.

Example:

```text
Python
Dharen = IDLE
        ↓
ANALYSIS_STARTED
        ↓
Dharen = WORK
        ↓
presentation state emitted
        ↓
Flutter receives WORK
        ↓
Dharen visibly changes to WORK
```

That one chain proves dramatically more than another collection of isolated Flutter tests.

---

# 9. Second Proof

After the first state transition works:

```text
Python
WORK
 ↓
COMMUNICATE
 ↓
Flutter
 ↓
COMMUNICATE visual
```

Then:

```text
Python
COMMUNICATE
 ↓
COMPLETE
 ↓
Flutter
 ↓
COMPLETE visual
 ↓
quiet / IDLE
```

---

# 10. Third Proof: Handoff

Only after the basic connection works:

```text
Agent A
 ↓
HANDOFF
 ↓
presentation event/state
 ↓
Flutter
 ↓
Agent A visual handoff
 ↓
Agent B RECEIVE
 ↓
Agent B visual receive
```

This is where the behavioral architecture starts becoming visibly meaningful.

---

# 11. Fourth Proof: Attention

The system should prove:

```text
multiple possible agents
        ↓
attention regulation
        ↓
relevant agent prioritized
        ↓
Flutter emphasizes relevant agent
        ↓
irrelevant agents remain quiet
```

This validates the principle:

```text
MORE ACTIVITY ≠ BETTER INTERFACE
```

---

# 12. Fifth Proof: Bloom

The complete interaction should eventually become:

```text
USER
 ↓
BLOOM
 ↓
ACTION
 ↓
PYTHON EVENT
 ↓
BEHAVIOR ENGINE
 ↓
AGENT
 ↓
PRESENTATION STATE
 ↓
TRANSPORT
 ↓
FLUTTER
 ↓
VISIBLE CHARACTER RESPONSE
```

Only after this works should the project claim meaningful Bloom-to-character visual integration.

---

# 13. Backlog — Integration Recovery

The following backlog should be treated as the immediate technical backlog created by the gap.

## P0 — Must Prove

### INT-001 — Inspect actual Python presentation output

Determine exactly how the current Python application produces presentation state.

**Output:**
A documented real source of truth.

---

### INT-002 — Inspect actual Flutter state input

Determine exactly where Flutter currently receives or constructs presentation state.

**Output:**
Documented current input path.

---

### INT-003 — Define cross-runtime presentation contract

Define the minimum state that must cross the Python/Flutter boundary.

**Output:**
Versioned contract/document.

---

### INT-004 — Choose runtime transport

Evaluate and select the smallest appropriate transport.

**Constraint:**
Do not introduce unnecessary infrastructure.

---

### INT-005 — Implement Python presentation emitter

Create the application-side mechanism that publishes presentation updates.

---

### INT-006 — Implement Flutter presentation receiver

Receive and validate presentation updates.

---

### INT-007 — Connect received state to Flutter PresentationState

Ensure received state drives the existing presentation architecture rather than bypassing it.

---

### INT-008 — Prove one live state transition

Required proof:

```text
Python IDLE
→ Python WORK
→ transport
→ Flutter WORK
→ visible change
```

---

### INT-009 — Prove complete state lifecycle

```text
RECEIVE
→ WORK
→ COMMUNICATE
→ COMPLETE
→ IDLE
```

---

## P1 — Behavioral Visual Integration

### INT-010 — Connect activation

Python activation must affect Flutter visual activation.

### INT-011 — Connect attention prominence

Python attention state must affect visual prominence.

### INT-012 — Connect communication

Python communication state/message must reach Flutter presentation.

### INT-013 — Connect handoff

Sender/receiver behavior must produce corresponding visual states.

### INT-014 — Connect quiet state

Completion/recovery must return irrelevant agents to quiet presentation.

### INT-015 — Connect Bloom

Bloom action must initiate the real application event path.

---

## P1 — Robustness

### INT-016 — Define startup behavior

### INT-017 — Define disconnect behavior

### INT-018 — Define reconnect behavior

### INT-019 — Validate malformed presentation messages

### INT-020 — Reject unsupported states safely

### INT-021 — Prevent stale state from silently becoming current state

### INT-022 — Define shutdown behavior

---

# 14. Testing Backlog

## Unit

### TEST-001
Python presentation-state mapping.

### TEST-002
Serialization/deserialization.

### TEST-003
Flutter contract decoding.

### TEST-004
Invalid payload rejection.

### TEST-005
State-to-visual mapping.

### TEST-006
Reduced-motion mapping.

---

## Integration

### TEST-007
Python → transport.

### TEST-008
Transport → Flutter.

### TEST-009
Python → Flutter live state transition.

### TEST-010
Full character lifecycle.

### TEST-011
Communication transition.

### TEST-012
Handoff transition.

### TEST-013
Attention suppression.

### TEST-014
Bloom → Python event → Flutter visual.

---

## Regression

### TEST-015
Full Python test suite.

### TEST-016
Full Flutter test suite.

### TEST-017
S1 regression.

### TEST-018
End-to-end smoke test.

---

# 15. Security Backlog Created by the Connection

Before accepting arbitrary runtime input:

### SEC-001
Validate message structure.

### SEC-002
Validate allowed character IDs.

### SEC-003
Validate allowed character states.

### SEC-004
Validate payload sizes.

### SEC-005
Prevent executable content from agent messages.

### SEC-006
Prevent presentation input from modifying domain state directly.

### SEC-007
Prevent debug information leakage.

### SEC-008
Document trust boundary.

Important:

**Flutter should not be treated as an authority for Python domain truth.**

---

# 16. Accessibility Backlog

Once real state reaches Flutter:

### A11Y-001
Expose semantic agent identity.

### A11Y-002
Expose current state semantically.

### A11Y-003
Expose important communication non-visually.

### A11Y-004
Ensure animation is never required for comprehension.

### A11Y-005
Verify reduced-motion behavior.

### A11Y-006
Verify keyboard/focus behavior around Bloom.

---

# 17. Visual Backlog

The current visual foundation should be preserved as prototype material.

Do not replace it prematurely.

Future work:

### VIS-001
Finalize character visual language.

### VIS-002
Differentiate identity without relying only on text.

### VIS-003
Differentiate functional roles.

### VIS-004
Design state-specific visual behavior.

### VIS-005
Design restrained animation vocabulary.

### VIS-006
Implement communication visual treatment.

### VIS-007
Implement handoff visual treatment.

### VIS-008
Implement warning visual treatment.

### VIS-009
Implement quiet visual treatment.

### VIS-010
Generalize the proven pattern across all 15 characters.

---

# 18. Research Backlog

The integration itself is implementation evidence.

It is NOT a research finding.

Record:

### RES-001
Implementation evidence: character behavior can be represented independently from rendering.

### RES-002
Implementation evidence: presentation state can potentially cross a technology boundary.

### RES-003
Prototype observation: visual state changes correspond to behavioral states.

### RES-004
Research hypothesis: functional character behavior may improve system-status comprehension.

### RES-005
Research hypothesis: attentional regulation may reduce unnecessary visual competition.

### RES-006
Research hypothesis: contextual communication may improve perceived system transparency.

### RES-007
Research hypothesis: restrained contextual humor may improve waiting experience under appropriate conditions.

These hypotheses require future evaluation. They must not be reported as findings until evidence exists.

---

# 19. Definition of Done for the Integration Gap

Do not mark the Python/Flutter connection complete until all of these are true:

- [ ] Python produces real presentation output.
- [ ] A documented presentation contract exists.
- [ ] A documented runtime transport exists.
- [ ] Flutter receives real application-generated state.
- [ ] Flutter does not independently invent the application's behavioral truth.
- [ ] One Python state transition visibly changes Flutter.
- [ ] Full lifecycle is demonstrated.
- [ ] Communication reaches presentation.
- [ ] Handoff reaches presentation.
- [ ] Attention regulation affects presentation.
- [ ] Quiet state works.
- [ ] Bloom reaches the real application event path.
- [ ] Invalid input is rejected safely.
- [ ] Reduced motion works.
- [ ] Python tests are green.
- [ ] Flutter analyzer is green.
- [ ] Flutter tests are green.
- [ ] S1 regression is green.
- [ ] End-to-end smoke test is green.
- [ ] Architecture documentation reflects reality.

---

# 20. What Must NOT Happen Again

1. Do not build more visual features before proving the runtime boundary.
2. Do not treat a locally constructed Flutter state as backend integration.
3. Do not make Flutter contain domain behavior.
4. Do not create a huge transport architecture for one prototype transition.
5. Do not expand to all 15 visual characters before one character proves the complete path.
6. Do not mark tests green if analyzer/compiler errors remain.
7. Do not convert prototype observations into research findings.
8. Do not delete existing useful presentation code merely because it is provisional.
9. Do not silently change directory boundaries.
10. Do not declare S2 complete until the actual final checkpoint is satisfied.

---

# 21. Immediate Next Milestone

The next meaningful milestone is NOT:

> "Make all 15 characters beautiful."

It is:

> **LIVE PYTHON → PRESENTATION CONTRACT → FLUTTER STATE → VISIBLE CHARACTER TRANSITION**

One agent.
One event.
One state transition.
One verified runtime path.

Once that is proven, the architecture has a real spine instead of two well-behaved islands waving at each other from opposite shores.

---

# 22. Final Status

**Current state:**

```text
Python behavioral foundation        PRESENT
Flutter presentation foundation    PRESENT
Flutter character rendering        PRESENT
Presentation abstraction            PRESENT
Cross-runtime contract              NOT PROVEN
Runtime transport                   NOT PROVEN
Python → Flutter live connection   NOT PROVEN
Full visual behavioral integration NOT PROVEN
```

Therefore:

> **The project is not broken. It is partially integrated. The correct next step is to close the runtime boundary deliberately, prove it with one end-to-end state transition, and only then expand the visual ecosystem.**
