# Criterivox

Criterivox is a research-driven, context-aware intelligence and decision-support system.

It began as an application for analysing information with context and gradually evolved into a broader research prototype for traceable, inspectable and human-controlled decision support.

## Current Status

**Sprints 1–10 have been crossed.**

The current main branch is the integrated project baseline. Major work from the product shell, character interaction, data foundation, context intelligence, reasoning, XAI/evidence, reusable capability architecture, frontend completion and character-chat/intelligence integration has been consolidated.

**Current phase: Final Integrated Research Prototype.**

The implementation baseline now includes stabilized presentation behavior, multilingual human input handling, interpretation confirmation with a one-minute unattended continuation rule, and consent-aware research instrumentation backed by local SQLite.

## Sprint History

| Sprint | Focus | Current outcome |
|---|---|---|
| **S1** | Product shell + Bloom foundation | User-facing shell, navigation and Bloom foundation established |
| **S2** | Character-driven interaction + Flutter visual integration | Character interaction and presentation foundation established |
| **S3** | Application Bloom | Syvax/Bloom connected to the application/runtime boundary |
| **S4** | Domain Analysis Workspace | Analysis task flow, Python ↔ Flutter path and first functional Dharen runtime integration established |
| **S5** | Data Foundation + Sandre Data Stewardship | Provenance-aware data foundation, confirmation and stewardship workflow established |
| **S6** | Context Intelligence | Durable context, transfer, replay, sandboxing, budgeting and Dharen/Anuka context responsibilities established |
| **S7** | Reasoning Research Bureau | Inspectable reasoning architecture, provenance, intervention and reasoning research surface established |
| **S8** | XAI / Evidence Research Bureau | Evidence, verification, provenance, integrity and human-facing XAI evaluation boundaries established |
| **S9** | Capability & Intelligence Architecture | Reusable capabilities, pipelines, routing, execution controls, checkpoints and audit primitives established |
| **S10** | Integrated baseline + cross-sprint reconciliation | Major architecture/frontend/character-chat/intelligence work consolidated into main; regression baseline restored |

Detailed research history is recorded in:

docs/research/PROJECT-RESEARCH-JOURNEY-THROUGH-S10.md

## What Criterivox Became

Original direction:

    Human / Information → Analysis → Useful Answer

Current architecture:

    Human Goal / Problem
            ↓
    Human Residence
            ↓
    Character Interaction / Syvax
            ↓
    Data + Provenance
            ↓
    Context Intelligence
            ↓
    Inspectable Reasoning
            ↓
    Evidence / XAI
            ↓
    Verification
            ↓
    Reusable Capabilities / Pipelines
            ↓
    Authorized Execution
            ↓
    Result / Audit
            ↓
    Knowledge / Adaptation / Future Journey
            ↓
    Human Decision

The project therefore evolved from a content-analysis/application idea into an integrated research prototype for human decision support.

## What We Learned Beyond the Original Goal

1. **Data is not just input.** S5 made source identity, provenance, confirmation, missingness and transformation history part of the downstream foundation.
2. **Context is not just prompt text.** S6 introduced durable context state, transfer, isolation, replay, adaptation and budgeting boundaries.
3. **Reasoning needs inspectable artifacts.** S7 established structured reasoning records, dependency/provenance structures and intervention boundaries instead of pretending hidden chain-of-thought is an exposed product artifact.
4. **Explanations need evidence.** S8 established evidence, verification, provenance and integrity as separate research boundaries.
5. **Human authority is architectural.** Challenge, approval and consequential-action authority are represented explicitly.
6. **Characters are responsibility surfaces.** Character identities do not imply fifteen independent trained intelligence models.
7. **Capabilities should be reusable.** S9 separated reusable computational capabilities from character identities.
8. **The system became researchable.** The architecture now supports investigation of evidence traceability, explanation understanding, uncertainty comprehension, challenge quality, correction traceability, authorization awareness, context transfer and reasoning inspection.

## Current Research Position

The central research direction is:

> How can context-aware, evidence-grounded and inspectable computational support help humans make better-informed decisions while preserving human authority?

The repository contains implementation and evaluation boundaries for this question, but implementation alone does not prove that the system improves human decision-making. Empirical conclusions require appropriate experiments, participants, datasets, measurements and analysis.

## Current Verification Baseline

**Historical Flutter baseline: 107 passed, 0 failed.**

That was the pre-final-instrumentation presentation baseline. The current branch has additional runtime, localization and research-instrumentation changes; no fresh CI run is claimed until GitHub Actions reports one.

The application previously launched after clearing stale Flutter build state with flutter clean. The final integration changes should be verified in a fresh Flutter/Python environment before a release build is treated as validated.

## Final Integration Position

Known problems currently include:

- runtime messages containing an unknown character identity;
- duplicated UI surfaces/components;
- mismatched component composition;
- unbalanced visual hierarchy;
- responsive/layout overflow;
- reusable components being used where page-specific composition is required;
- conflicts between global overlays and page-local surfaces.

The final integration focuses on:

1. Human-facing localization and character-name presentation
2. Single canonical Global Chat surface
3. Natural-language interpretation and confirmation trace
4. Research instrumentation and consent boundaries
5. Outcome and improvement-feedback capture
6. Tests aligned with the final architecture
7. Documentation aligned with the final implementation

Current implementation authority is documented in `docs/FINAL-INTEGRATED-RESEARCH-PROTOTYPE.md`.

## What Is Not Being Claimed

Criterivox is not being described as:

- a fully autonomous general intelligence;
- a universally trained Criterivox model;
- a production distributed intelligence network;
- production MCP/external-tool infrastructure;
- a universal knowledge/skill-learning engine;
- a system with universal empirical confidence or explainability thresholds;
- a completely empirically validated end-to-end civilization.

The project is an implemented research prototype and evolving decision-support architecture with durable foundations for context, inspectable reasoning, evidence/XAI, verification, human challenge, reusable capabilities and controlled execution.

## Repository Principle

The repository distinguishes:

- **IMPLEMENTED** — present in the codebase/runtime boundary;
- **VERIFIED** — supported by tests or explicit verification evidence;
- **RESEARCH QUESTION** — investigated but not yet empirically settled;
- **FUTURE** — intentionally deferred;
- **UNKNOWN** — not established by current evidence.

Architecture is not automatically empirical evidence. Tests are not automatically research findings. UI is not authoritative computational state. Characters are not automatically independent models. Human decision authority remains explicit.

## Project Research Record

The consolidated research journey, including where the project started, what each sprint asked, what was established, what was learned beyond the original plan, current research questions and their evidence status, is maintained in:

docs/research/PROJECT-RESEARCH-JOURNEY-THROUGH-S10.md

## Current Position

**Sprints 1–10: crossed.**

**Current baseline: integrated main.**

**Next phase: UI Stabilization.**

The architectural foundation is now substantial enough that the next job is not to keep adding layers. The next job is to make the system we already built coherent, balanced, understandable and faithful to its actual runtime behavior.

## Research Instrumentation

Criterivox includes a consent-aware research instrumentation boundary. It records structured interaction events, optional participant identity, language/interpretation traces and optional outcome reports in a local SQLite research store. Raw human messages require a separate raw-text consent. The instrumentation boundary is designed so the SQLite implementation can later be replaced by a server-backed research repository.

See `docs/FINAL-INTEGRATED-RESEARCH-PROTOTYPE.md` for the current architecture and data boundaries.


## UI Stabilization Phase Closure

The UI stabilization phase closed the critical human-flow gaps identified during direct runtime inspection:

- Human Territory now exposes functional local-first sign-up/sign-in and session restoration.
- Decision Desk has an explicit action that runs the human-situation pipeline and presents the returned strategy/result in a dedicated human-readable result panel.
- Results Journal reads persisted decision records from the Human Residence decision store.
- Browser API calls use an explicit Python-backend origin because the managed launcher separates Flutter presentation (8080) from Python runtime (8000).
- Human situation intake accepts hybrid forms including ordinary text, structured objects/lists, pasted material, form fields, multipart material metadata and plain-text request bodies.
- JSON is treated as a transport/representation format, not as the required shape of human input.
- People photos remain contextual only and do not become appearance-based behavioral or identity evidence.
- Prototype/decorative UI pieces are intentionally retained for a later visual-design pass.

### Phase learning

The key engineering lesson is to keep human input, transport formats, computational normalization and internal capability contracts as separate layers. A human should be able to describe a problem naturally and attach heterogeneous material without learning Criterivox's internal schemas.

A second lesson is that a capability is not complete merely because a route or service exists. The human flow must expose the action, return a comprehensible result, preserve authority, and connect to the next authoritative surface.

A third lesson is that split local runtimes require an explicit browser-to-backend API boundary. Relative browser API paths are not safe when presentation and backend intentionally use different ports.

Closure details are recorded in docs/PHASE-UI-STABILIZATION-CLOSURE.md.

**Verification discipline:** implementation and tests are committed separately from claims of fresh local runtime execution. No passing Flutter/Python run is claimed unless execution evidence exists.
