# Criterivox

Criterivox is a research-driven, context-aware social-media content intelligence and decision-support system.

## Project Status

S2 runtime integration work is in progress on the `s2-integration-hardening` branch.

## Current Sprint

S2 — Runtime Character Integration

## Development Environment

- Python 3.13
- Flutter / Dart
- VS Code
- Git
- Jupyter / IPython for research experimentation

## Architecture Direction

Criterivox is being developed as a modular, deployment-agnostic system.

```text
Presentation
→ Character / Interaction
→ Application
→ Domain
→ Intelligence
→ Infrastructure
```

The Python application/domain behavior remains independent of Flutter rendering. The S2 runtime proof uses a versioned presentation contract over a local WebSocket boundary.

## Research Workflow

Research experimentation is kept separate from production implementation.

- `src/` contains product code.
- `presentation/` contains the Flutter presentation application.
- `tests/` contains automated tests.
- `experiments/` contains research experimentation.
- `docs/` contains engineering and research documentation.

## Development

The project uses an isolated Python virtual environment.

Create/activate the environment before installing project dependencies.

For the S2 runtime demonstration, start the Python ASGI application and the Flutter Web presentation separately. See `docs/sprints/s2/S2-RUNTIME-INTEGRATION.md` for the runtime boundary and demonstration procedure.

## Status

This repository is under active development. S2 completion requires successful local test execution and a reproducible Python → WebSocket → Dart → Dharen demonstration.

## Project Structure

- `src/criterivox/` - application source
- `presentation/` - Flutter presentation source
- `tests/` - automated tests
- `docs/` - architecture and research documentation

## Requirements

- Python 3.13+
- Flutter / Dart
- Git

## Setup

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```
