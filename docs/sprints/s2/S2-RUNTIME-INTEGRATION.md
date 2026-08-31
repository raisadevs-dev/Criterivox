# Criterivox S2 — Runtime Character Integration

## Status

This document records the runtime integration on `s2-integration-hardening`. S2 is complete only after the local test suites and the real manual demonstration pass.

## Runtime boundary

```text
Flutter
  ↓ WebSocket command
Python application
  ↓
validated AnalysisRequest
  ↓
DharenRuntime
  ↓
CharacterActivityManager
  ↓
PresentationContract
  ↓
WebSocket broadcast
  ↓
Dart PresentationState
  ↓
CharacterVisualState
  ↓
CharacterPresentation
  ↓
visible Dharen
```

The runtime transport is a **local WebSocket boundary**. Python owns semantic character behavior; Flutter consumes the versioned presentation contract and chooses the visual representation.

## Runtime host

Normal local development uses the repository-level launcher:

```powershell
.\start-criterivox.ps1
```

The launcher is the local Criterivox runtime host. It validates the environment, starts the project `.venv` Python runtime, waits for `/health`, starts Flutter Web, supervises both processes, and stops the managed processes together.

This replaces the normal need to manually start `server.py`, Uvicorn, and Flutter in separate terminals. Low-level commands remain valid troubleshooting tools, but they are not the canonical startup path.

### Readiness

Python exposes:

```text
GET /health
```

The launcher does not start Flutter until the Python runtime reports readiness. This prevents the presentation from being opened into an avoidable `WAITING_FOR_PYTHON_CONNECTION` state during normal startup.

## Developer diagnostics

Critical launcher/runtime failures produce a local incident directory:

```text
diagnostics/
└── incident-CVX-YYYYMMDD-HHMMSS/
    ├── incident.md
    └── incident.json
```

The Markdown report explains the failure story, expected versus observed behavior, affected boundary, evidence and recommended investigation. The JSON report provides structured incident data for developer tooling or AI-assisted diagnosis. Runtime stdout/stderr logs are referenced from the incident and remain local.

Generated diagnostics are intentionally ignored by Git.

## End-user error boundary

The technical incident artifact is developer-facing. The presentation should expose only a concise runtime error and an incident identifier when appropriate. It should not expose stack traces, local filesystem paths, credentials, or internal transport details.

A future user-facing `Copy diagnostics` action may package the safe incident identifier and approved diagnostic information without exposing internal secrets.

## Contract

`PresentationContract` is versioned at `contract_version = 1` and carries renderer-independent semantic information:

- character identity
- semantic character state
- animation state
- activation
- prominence
- reduced-motion flag
- optional communication message
- optional originating event

The renderer receives semantic state such as `work`, not technology-specific commands.

## Current Dharen slice

The first runtime capability is intentionally deterministic. It is **not an intelligence model** and makes no ML/XAI claim.

Input:

```text
data
+
context
+
task
```

The current operation performs a real deterministic application calculation over the supplied data/context. Its purpose is to prove the runtime lifecycle, not to simulate sophisticated intelligence.

Lifecycle:

```text
IDLE
 ↓
RECEIVE
 ↓
WORK
 ↓
COMMUNICATE
 ↓
COMPLETE
 ↓
IDLE
```

Flutter does not create this sequence. Python emits each state over the runtime boundary.

## Renderer independence

```text
PresentationContract
        ↓
Dart presentation state
        ↓
CharacterRenderer
       / \
     Rive   3D/WebGL/Spline
```

The current Flutter renderer is a functional S2 renderer. Production Rive and 3D assets remain future work.

## Validation and security

The Python boundary validates request fields, task size, data/context limits and serialized payload size. The Dart receiver validates contract version, character identity, character state, activation, prominence, message and event values.

The runtime boundary must never become an arbitrary command-execution channel.

## Manual proof

1. From the repository root, run `.\start-criterivox.ps1`.
2. Let the launcher start Python and Flutter automatically.
3. Wait until the Criterivox presentation is connected to the Python runtime.
4. Enter synthetic JSON data.
5. Enter synthetic JSON context.
6. Enter the task.
7. Select **Send analysis request to Python**.
8. Observe Dharen transition through `RECEIVE → WORK → COMMUNICATE → COMPLETE → IDLE`.
9. Confirm the status originates from Python.
10. Confirm Flutter changes only in response to the received semantic presentation state.
11. If startup or a critical runtime failure occurs, inspect the newest `diagnostics/incident-*` directory.

## Known limitations

- Direct user → Dharen input is a temporary S2 source boundary.
- Syvax → Dharen orchestration is future work.
- The current analysis operation is deterministic and synthetic.
- Full 15-character runtime integration is future work.
- Production Rive/3D/WebGL/Spline assets are future work.
- The local runtime host is a development supervisor, not a production distributed process manager.

## Research position

This implementation provides engineering evidence that semantic character state can cross a Python/Flutter technology boundary and drive presentation. It does **not** establish that character-mediated interaction improves comprehension, trust, cognitive load, responsiveness, or user experience. Those remain research hypotheses for later evaluation.
