# Criterivox

Criterivox is a research-driven, context-aware intelligence and decision-support system.

## Project Status

S2 runtime integration is being hardened on `s2-integration-hardening`.

## Current Sprint

**S2 — Runtime Character Integration**

The current S2 foundation connects Python application behavior to Flutter/Dart presentation through a versioned local WebSocket presentation contract. The first functional character slice is Dharen. The Python side owns semantic character state; Flutter renders that state without inventing the lifecycle.

## Runtime Host

Criterivox now has a single development entry point:

```powershell
.\start-criterivox.ps1
```

The runtime host:

1. validates the local development environment;
2. starts the project's `.venv` Python runtime;
3. waits for Python readiness at `/health`;
4. starts the Flutter web presentation;
5. keeps both processes supervised;
6. stops managed processes together when the host exits;
7. records critical runtime failures as developer diagnostics.

Normal development should not require manually starting `server.py`, Uvicorn, or a second Flutter command.

### Developer diagnostics

Critical launcher/runtime failures are recorded under the local `diagnostics/` directory as:

```text
diagnostics/
└── incident-CVX-YYYYMMDD-HHMMSS/
    ├── incident.md
    └── incident.json
```

`incident.md` provides the failure story for a developer. `incident.json` provides structured evidence suitable for automated or AI-assisted diagnosis. Runtime logs are kept locally and are not committed.

## Architecture Direction

```text
Presentation
→ Character / Interaction Experience
→ Application Services
→ Domain
→ Intelligence
→ Infrastructure / Data
```

For S2:

```text
User
→ Flutter
→ Python application
→ Character behavior
→ Semantic presentation state
→ WebSocket runtime boundary
→ Dart
→ Character renderer
```

The character contract remains renderer-independent and is suitable for future Rive and 3D/WebGL/Spline presentation adapters.

## Research Workflow

Research experimentation remains separate from product implementation.

- `src/` contains product code.
- `presentation/` contains the Flutter presentation application.
- `tests/` contains automated tests.
- `experiments/` contains research experimentation.
- `docs/` contains engineering and research documentation.

## Development Environment

- Python 3.13+
- Flutter / Dart
- Chrome for Flutter web development
- VS Code
- Git
- Jupyter / IPython for research experimentation

Create the project environment and install dependencies:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

For the presentation application:

```powershell
cd presentation
flutter pub get
```

Then return to the repository root and use the runtime host:

```powershell
cd ..
.\start-criterivox.ps1
```

See `docs/sprints/s2/S2-RUNTIME-INTEGRATION.md` for the runtime contract and S2 demonstration details.

## Project Structure

- `src/criterivox/` — Python application source
- `presentation/` — Flutter presentation source
- `tests/` — automated Python tests
- `docs/` — architecture, security, research and sprint documentation
- `start-criterivox.ps1` — canonical local runtime host
- `diagnostics/` — local generated runtime evidence; ignored by Git

## Scope Boundary

S2 does not claim full intelligence, XAI, production Rive/3D assets, all 15 characters, production databases, authentication, social-media APIs, or the complete research loop. Those remain future roadmap work. The S2 proof is the real runtime connection and Dharen lifecycle.
