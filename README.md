# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S2 — Runtime Character Integration is complete.** The current baseline includes a managed local runtime host, a Python-to-Flutter runtime boundary, and the first functional character slice, Dharen.

## Current Sprint

**S2 — Runtime Character Integration — COMPLETE**

S2 establishes the engineering foundation for character-driven interaction. Python owns semantic character state; Flutter receives and renders that state without inventing the lifecycle.

## Research Foundation

Research remains a first-class part of Criterivox. Engineering prototypes are used to test feasibility and architecture, while research claims are kept separate from implementation evidence.

### Research direction

The broader research direction investigates how **context-aware intelligence and explanation can support human decision-making** rather than merely producing automated outputs.

The intended product/research loop is:

```text
DATA
  ↓
CONTEXT
  ↓
INTELLIGENCE
  ↓
EXPLANATION
  ↓
HUMAN CHALLENGE
  ↓
HYPOTHESIS
  ↓
EXPERIMENT
  ↓
EVIDENCE
  ↓
KNOWLEDGE
  ↓
CONTEXT-CONDITIONED REUSE / TRANSFER
```

This is a research and product direction, not a claim that every stage has already been implemented.

### Active research item: Context-Aware Bloom Interaction

Criterivox currently investigates whether a context-aware Bloom-style interaction can improve capability discoverability and task efficiency without reducing predictability or accessibility.

The research hypothesis is that progressively exposing capabilities relevant to the user's current context **may** improve task relevance and discoverability when conventional navigation remains available as an accessible fallback.

The current prototype demonstrates the basic Bloom interaction and context-aware capability filtering. It is an architectural prototype, **not evidence that Bloom is superior to conventional navigation**. Formal comparative evaluation remains future work.

Potential future evaluation measures include task completion time, capability discoverability, incorrect selections, navigation steps, perceived cognitive load, user preference, and accessibility performance.

Research record: `docs/research/RI-01-bloom-context-aware-interaction.md`

## Runtime Host

Criterivox has a single development entry point:

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

Critical runtime failures are recorded locally under `diagnostics/`. These reports are developer-facing evidence for investigating failures and are intentionally ignored by Git. They are not part of the end-user product experience.

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

Research experimentation remains separate from production implementation.

- `src/` contains product code.
- `presentation/` contains the Flutter presentation application.
- `tests/` contains automated tests.
- `experiments/` contains research experimentation.
- `docs/research/` contains research records and hypotheses.
- `docs/` contains engineering, architecture, security, sprint, UX, and research documentation.

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

See `docs/sprints/s2/S2-RUNTIME-INTEGRATION.md` for the runtime contract and verified S2 demonstration.

## Project Structure

- `src/criterivox/` — Python application source
- `presentation/` — Flutter presentation source
- `tests/` — automated Python tests
- `experiments/` — research experimentation
- `docs/research/` — research records and hypotheses
- `docs/` — architecture, security, UX, research, and sprint documentation
- `start-criterivox.ps1` — canonical local runtime host
- `diagnostics/` — local generated runtime evidence; ignored by Git

## Scope Boundary

S2 does not claim full intelligence, XAI, production Rive/3D assets, all 15 characters, production databases, authentication, social-media APIs, or completion of the broader research loop. Those remain future roadmap work. S2 proves the managed runtime connection and Dharen lifecycle that the next research/product iterations can build upon.
