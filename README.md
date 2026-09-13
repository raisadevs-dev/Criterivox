# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S5 — Data Foundation + Sandre Data Stewardship is complete.** S5 established the provenance-aware data foundation, confirmation-gated stewardship workflow, Sandre working surface, and runtime integration required to carry validated material toward Dharen analysis. The Python ↔ WebSocket ↔ Flutter architecture remains intact.

**S6 — Context Intelligence is NOT YET COMPLETE.** The implementation/handoff foundation exists, including Dharen/Anuka context responsibilities, durable context state, browser-first residency, sandbox/replay, dynamic budgeting and reproducible learned-model code. The remaining S6 phase is deliberate backlog cleaning through testing, verification, ML artifact/inference evidence, evidence collection, modular/SOLID refinement and UI verification.

## S6 Direction

S6 adds an operational context layer above the S5 foundation. It structures, protects, adapts, persists, replays and hands off context while preserving S5 provenance and browser-first residency.

```text
Human Residence
      ↓
Syvax — dialogue / gateway / orchestration
      ↓
S5 DataFoundation
      ↓
S6 Context Intelligence
      ↓
Dharen — Context Master
      ↓
ContextFrame
      ├── normal flow
      └── trigger → Anuka — Context Adaptor
                    ↓
             adaptive state / fork
                    ↓
       Criterivox computational workers
                    ↓
        result / evidence / options
                    ↓
             Human Residence
```

## S5 → S6 Foundation

```text
USER MATERIAL
      ↓
SOURCE / COLLECTION INTAKE
      ↓
EXTRACTION
      ↓
CANDIDATE INFORMATION
      ↓
USER CONFIRMATION
      ↓
PROFILE / QUALITY
      ↓
NORMALIZE / PREPARE
      ↓
CANONICAL DATA
      ↓
SANDRE DATA STEWARDSHIP
      ↓
DHAREN CONTEXT INTELLIGENCE
      ↓
PROVENANCE → CONTEXT → INTERPRETATION
```

S5 preserves source identity, provenance, user confirmation, explicit missingness, anomaly flags, reproducible transformations, and canonical downstream representation. S6 consumes the **complete DataFoundation** rather than a reduced summary.

## Criterivox Civilization and Human Residence

Criterivox is represented as two connected environments:

- **Criterivox Civilization** — specialised computational workers/homes and their domain interactions.
- **Human Residence** — the human-side decision environment.

The human is not another autonomous worker. The Human Residence loop is:

```text
Goal → Data + Context → Criterivox → Decision/Options
→ Challenge → Accept/Reject → Action
→ Real-world Result → new evidence/context
```

Syvax is the gateway between these environments. Bloom is the capability-discovery/world surface. Neither is the source of authoritative S5/S6 computational state.

## Character and Interaction Boundary

- **Syvax** remains the dialogue host, interaction gateway, routing/orchestration and presentation boundary.
- **Sandre** owns Data Stewardship upstream of S6.
- **Kaelen** handles build/experimentation work and short-lived scratchpad activity.
- **Dharen** owns contextual structure, baseline framing and downstream handoff.
- **Anuka** is conditionally activated for changed requirements, evidence, hypotheses, constraints, drift, counterfactuals or downstream incompatibility.
- **Bloom** remains the capability-discovery surface rather than a duplicate work area.
- Characters are representations of computational responsibilities, not the underlying ML/model itself.
- Character conversations are independent buffers while task/context/evidence state remains shared and authoritative.

## S6 Operational Capabilities

- Dynamic context pruning and attentive compression
- Hierarchical memory structuring
- Adaptive context windowing
- Stateful context transfer across agent boundaries
- Context isolation through sandboxing
- In-context scratchpad persistence
- Context clash / poisoning prevention
- Dynamic hierarchy tiering
- Priority-tiered token budgeting
- Contextual replay and shadow testing

## Character Animation Stack

Criterivox uses a local Web 2D skeletal presentation runtime:

- **Flutter / Dart** — application presentation, semantic state transport, responsive layout and accessibility.
- **HTML + standard JavaScript** — local skeletal rendering boundary embedded through `HtmlElementView`.
- **Plain JSON skeleton data** — bones, slots, character skins/signatures and animation tracks.
- **DragonBones / Spine-style concepts** — hierarchical bones, slots/skins, animation tracks and blended state transitions.

The current renderer is an original lightweight Criterivox skeletal runtime. It is deliberately renderer-independent from the Python/domain layer and leaves a future production DragonBones or Spine adapter as a separate research/licensing decision.

## Character State Vocabulary

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

Python/domain/application layers emit semantic state. Flutter carries the contract and the local Web runtime blends the corresponding skeletal pose.

## S6 Quality and Verification Phase

The current S6 exit work is intentionally verification-first:

1. clean and verify SOLID/module boundaries;
2. expand smart unit, contract, integration and regression tests;
3. verify browser/IndexedDB → WebSocket → Python recovery and revision safety;
4. verify sandbox create/run/inspect/compare/promote/discard end-to-end;
5. run reproducible ML training and retain generated artifacts;
6. verify runtime inference using generated artifacts;
7. collect and classify learned evidence, distinguishing weak/public labels from human-validated evidence;
8. refine and verify Syvax, Bloom and Human Residence UI;
9. update final documentation/ADR/backlog status only from actual evidence.

Implementation, trained artifacts, runtime inference and CI evidence are separate claims. S6 must not be marked complete until its remaining gates pass.

## Research Foundation

Research remains a first-class part of Criterivox. Engineering prototypes are used to test feasibility and architecture, while research claims are kept separate from implementation evidence.

The current S6 research boundary explicitly distinguishes **EVIDENCE, DECISION, ASSUMPTION, HYPOTHESIS, IMPLEMENTED, FUTURE, and UNKNOWN**.

### Research direction

The broader research direction investigates how **context-aware intelligence and explanation can support human decision-making** rather than merely producing automated outputs.

## Further S6 Documentation

- `docs/sprints/S6-BACKLOG.md` — consolidated remaining S6 work and exit gates.
- `docs/architecture/S6-SOLID-MODULAR-BOUNDARIES.md` — modular/SOLID boundary decisions.
- `docs/architecture/CRITERIVOX-CIVILIZATION-HUMAN-RESIDENCE-S6.md` — Bloom/Syvax/Civilization/Human Residence relationship.
- `docs/adr/ADR-009-s6-context-human-civilization-boundary.md` — accepted architectural decision.
