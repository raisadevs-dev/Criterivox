# Criterivox

Criterivox is a research-driven, context-aware, evidence-grounded and inspectable decision-support research prototype.

It is designed around a simple principle: computational support should help a human understand a situation, inspect the relevant evidence and reasoning, challenge or confirm interpretations, and retain explicit authority over consequential decisions.

## Live Application

Criterivox has a hosted web deployment:

- **Web app:** [Open Criterivox](https://criterivox-web-production.up.railway.app)
- **API health endpoint:** [Check API health](https://criterivox-api-production.up.railway.app/health)

The web application and API are hosted on Railway. The Railway-provided domains are deployment URLs; a custom domain can be configured separately. Deployment availability and feature behavior may change as the research prototype evolves. A live URL does not imply release-readiness or empirical validation.

For deployment notes and configuration boundaries, see [Deployment](docs/DEPLOYMENT.md).

## Current Status

**Current baseline: integrated main.**

The main branch now contains the consolidated character-capability architecture, semantic architecture refactor, presentation/runtime integration, research instrumentation boundary, and dependency cleanup.

The repository should be understood as an **implemented research prototype**, not as a claim of general intelligence or universal empirical validation.

For current implementation authority, see:

- `docs/FINAL-INTEGRATED-RESEARCH-PROTOTYPE.md`
- `docs/PHASE-UI-STABILIZATION-CLOSURE.md`

Historical sprint plans and exploratory architecture documents remain useful as research records, but they are not the authority for current implementation behavior.

## System Architecture

```
Human Goal / Problem
        ↓
Human Residence
        ↓
Natural Human Input
        ↓
Language + Meaning Intake
        ↓
Data / Context / Evidence
        ↓
Inspectable Reasoning
        ↓
Human Challenge / Confirmation
        ↓
Decision / Authorized Action
        ↓
Real-world Result
        ↓
Outcome / Knowledge / Future Context
```

The architecture separates human-facing interaction from computational capabilities and keeps authorization, evidence, provenance and verification explicit.

## Character & Capability Architecture

Characters are responsibility and interaction surfaces. They are **not** assumed to be independent trained intelligence models.

Reusable capabilities are separated from character identity so computational work can be routed, inspected, tested and reused without coupling every capability to a particular character.

The integrated main branch includes the character capability bundle together with the semantic runtime architecture and presentation contracts.

## Human Interaction

Criterivox supports natural human input rather than requiring users to learn internal schemas.

The current implementation includes:

- human-facing localization and character-name presentation;
- natural-language interpretation and confirmation traces;
- multilingual input handling;
- heterogeneous material intake;
- explicit human challenge and confirmation boundaries;
- a one-minute unattended interpretation continuation rule;
- human-readable result surfaces;
- explicit authorization before consequential execution.

When interpretation confirmation receives no response for 60 seconds, the system may continue with the recorded interpretation while marking it `UNCONFIRMED_TIMEOUT`. This preserves both continuity and the fact that the interpretation was not confirmed.

## Data, Context, Evidence & Reasoning

The system treats these as separate architectural concerns:

1. **Data and provenance** preserve source identity, confirmation and transformation history.
2. **Context intelligence** provides durable context, transfer, isolation, replay and budgeting boundaries.
3. **Inspectable reasoning** represents reasoning artifacts without exposing or pretending to expose hidden chain-of-thought.
4. **Evidence and XAI** provide evidence, verification, provenance and integrity boundaries.
5. **Reusable capabilities** provide computational primitives that can be composed into controlled pipelines.
6. **Authorized execution** keeps consequential action behind explicit authority boundaries.

Architecture and telemetry are not automatically empirical findings.

## Research Instrumentation

Criterivox contains a dedicated consent-aware research instrumentation boundary.

```
Criterivox interaction
        ↓
Research Instrumentation
        ├── participant identity
        ├── consent record
        ├── session
        ├── structured interaction events
        └── optional outcomes
                 ↓
        SQLite V1 research store
```

Research participation, identifiable participant information, and raw human text use separate consent boundaries. Raw human messages are not retained by default merely because structured interpretation is retained.

The current implementation uses separate Human Residence and Research Instrumentation SQLite stores. The repository boundary is designed so a future authenticated server-backed research store can replace the local implementation without changing the research event vocabulary.

## Technology Stack

### Python runtime

- Python `3.13`
- FastAPI
- Pydantic / Pydantic Settings
- NumPy
- scikit-learn
- joblib
- Hugging Face `datasets` for the ML/data tooling boundary
- pytest for development and verification

Python dependencies are declared in `pyproject.toml`. The repository-level installation entrypoint is:

```bash
python -m pip install -r requirements.txt
```

The requirements file delegates to the project metadata rather than maintaining a second package-version list.

### Flutter presentation

The presentation layer uses Flutter with:

- `web_socket_channel` for WebSocket communication;
- `http` for HTTP API communication;
- `file_picker` for material selection;
- `shared_preferences` and `sqflite` for local persistence;
- `idb_shim` for browser-compatible local storage;
- `path` and `crypto` for supporting runtime operations;
- Flutter's testing and linting tooling.

The Python runtime does not directly depend on `websocket-client` or Python `websockets`; WebSocket transport is provided through the FastAPI/Starlette runtime boundary, while the Flutter client uses `web_socket_channel`.

## Verification Discipline

Criterivox distinguishes:

- **IMPLEMENTED** — present in the codebase/runtime boundary;
- **VERIFIED** — supported by tests or explicit verification evidence;
- **RESEARCH QUESTION** — investigated but not empirically settled;
- **FUTURE** — intentionally deferred;
- **UNKNOWN** — not established by current evidence.

A test passing does not automatically constitute a research finding. Architecture does not automatically constitute empirical evidence. UI state is not authoritative computational state.

Fresh CI/runtime claims are made only when execution evidence exists.

## What Criterivox Is Not

Criterivox is not being presented as:

- a fully autonomous general intelligence;
- a universally trained Criterivox model;
- a production distributed intelligence network;
- production MCP/external-tool infrastructure;
- a universal knowledge or skill-learning engine;
- a system with universal empirical confidence or explainability thresholds;
- a completely empirically validated end-to-end civilization.

It is an evolving, implemented research prototype for context-aware, evidence-grounded, inspectable and human-controlled decision support.

## Research Position

The central research direction is:

> How can context-aware, evidence-grounded and inspectable computational support help humans make better-informed decisions while preserving human authority?

Answering that question empirically requires appropriate experiments, participants, datasets, measurements and analysis. The repository therefore separates implementation evidence from research conclusions.

## Project Research Record

The research journey, including the project's evolution, research questions, implementation boundaries and historical decisions, is maintained in the repository's research documentation.

The most current implementation authority is:

`docs/FINAL-INTEGRATED-RESEARCH-PROTOTYPE.md`

Historical research records should be read as historical records rather than as guarantees that every planned capability was implemented.

## Main Branch Position

**Integrated main baseline.**

The character capability bundle and semantic architecture refactor have been merged into main. The repository is now positioned for fresh end-to-end verification of the integrated baseline and subsequent research/runtime work.

No release-readiness claim is implied by the merge itself. Software, in its natural habitat, still needs to be run before anyone is allowed to become confident.
