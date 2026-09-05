# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S3 — Application Contracts + Syvax/Bloom Interaction Gateway is complete.** The current baseline preserves the permanent S2 Python ↔ Flutter runtime and adds a real application boundary through which Syvax and Bloom can initiate application work. The first functional vertical slice remains Dharen.

## Current Sprint

**S3 — Application Contracts + Syvax/Bloom Interaction Gateway — COMPLETE**

S3 connects the human-facing interaction layer to application services through explicit contracts. Syvax and Bloom enter the same application boundary; Python owns application behavior and semantic character state; Flutter presents the resulting state.

The implemented S3 path is:

```text
USER
  ↓
SYVAX OR BLOOM
  ↓
APPLICATION INTENT
  ↓
APPLICATION REQUEST
  ↓
APPLICATION SERVICE
  ↓
DETERMINISTIC PROVIDER
  ↓
APPLICATION EVENT
  ↓
DHAREN RUNTIME
  ↓
PRESENTATION CONTRACT
  ↓
FLUTTER
  ↓
VISIBLE DHAREN RESPONSE
```

The demonstrated Dharen lifecycle remains:

```text
RECEIVE → WORK → COMMUNICATE → COMPLETE → IDLE
```

Flutter does not invent this lifecycle. Python remains authoritative for semantic character state.

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

S3 adds the application interaction gateway while preserving the permanent runtime boundary:

```text
Syvax ───────┐
             ├──> Application Request → Application Service → Event
Bloom ───────┘                                      │
                                                    ↓
                                              Dharen Runtime
                                                    │
                                                    ↓
                                          Python → WebSocket → Dart
                                                    │
                                                    ↓
                                               Flutter UI
```

The character contract remains renderer-independent and is suitable for future Rive and 3D/WebGL/Spline presentation adapters.

## S3 Application Boundary

`src/criterivox/application/` contains the S3 application layer:

- `contracts.py` — versioned application intent, request, payload, result, event, and structured error representations.
- `service.py` — application service boundary connecting requests to application behavior.
- `provider.py` — provider abstraction and the current deterministic provider.

Syvax is the human/system dialogue host. Bloom is the capability gateway. Neither owns character state transitions or domain intelligence.

Only `Analyze` is currently implemented as the S3 vertical slice. Other Bloom capabilities are explicitly reserved rather than presented as fake backend functionality.

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

For S3 verification:

```powershell
.\scripts\verify-s3.ps1
```

See `docs/sprints/s3/S3-APPLICATION-BLOOM.md` for the S3 application boundary, runtime integration, verification and known limitations. The earlier S2 runtime contract remains documented in `docs/sprints/s2/S2-RUNTIME-INTEGRATION.md`.

## Project Structure

- `src/criterivox/` — Python application source
- `src/criterivox/application/` — application contracts, service, and provider boundary
- `presentation/` — Flutter presentation source
- `tests/` — automated Python tests
- `experiments/` — research experimentation
- `docs/research/` — research records and hypotheses
- `docs/` — architecture, security, UX, research, and sprint documentation
- `start-criterivox.ps1` — canonical local runtime host
- `diagnostics/` — local generated runtime evidence; ignored by Git

## Deferred Product / Engineering Backlog

The following items are intentionally carried into the next sprint rather than being treated as S3 completion blockers:

- Fix Bloom and character **overflow** across constrained layouts.
- Resolve **overlay/layering** issues between interface elements.
- Improve **responsive resizing** behavior across viewport sizes.
- Investigate and reduce **long application startup/loading time**.
- Replace remaining decorative/placeholder visuals with real functional components as their underlying capabilities become available.
- Evolve Bloom so capability nodes such as **Analyze can bloom into sub-capabilities**.
- Provide dedicated capability pages/routes where a capability requires a deeper workflow.

These are product hardening and evolution tasks, not evidence that the S3 application boundary is missing.

## Scope Boundary

S3 does not claim full intelligence, XAI, production Rive/3D assets, all 15 characters, production databases, authentication, social-media APIs, or completion of the broader research loop. The current deterministic provider exists to prove the application boundary and runtime vertical slice. Future intelligence providers and richer character workflows must connect through the established boundaries rather than being embedded into Bloom or Syvax.
