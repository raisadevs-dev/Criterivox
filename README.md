# Criterivox

Criterivox is a **research-driven, context-aware intelligence and decision-support system**. It originated from the problem of understanding social-media content through platform data, creator-provided context, and system-derived analysis, and is being engineered so that the underlying intelligence architecture is not permanently coupled to one platform or deployment model.

## Project Status

**S3 — Application Contracts + Syvax/Bloom Interaction Gateway is complete.** The current baseline preserves the permanent S2 Python ↔ Flutter runtime and adds a real application boundary through which Syvax and Bloom can initiate application work. The first functional vertical slice remains Dharen.

## Current Sprint

**S4 — Domain Analysis Workspace**

S4 builds a living, research-oriented analysis workspace around the existing Python application boundary and Flutter presentation layer. The implemented path is:

```text
USER
  ↓
SYVAX OR BLOOM
  ↓
APPLICATION INTENT
  ↓
ANALYSIS TASK
  ↓
PYTHON APPLICATION / DOMAIN
  ↓
APPLICATION EVENT
  ↓
DHAREN SEMANTIC STATE
  ↓
WEBSOCKET RUNTIME
  ↓
DART PRESENTATION STATE
  ↓
FLUTTER SVG CHARACTER RENDERING
  ↓
VISIBLE CHARACTER RESPONSE
```

Python remains authoritative for semantic character state. Flutter presents that state and does not invent the lifecycle.

## Character Animation Stack

Criterivox uses a vector-first character presentation pipeline:

- **Flutter / Dart** — application presentation, state-driven motion, responsive layout and accessibility.
- **SVG** — portable vector artwork for characters and interface animation assets.
- **Glaxnimate** — authoring workflow for vector character artwork and animation source.

The practical pipeline is:

```text
Character design
      ↓
Glaxnimate
      ↓
SVG assets
      ↓
Flutter SVG rendering
      ↓
Flutter state-driven animation
      ↓
Visible character
```

Dharen and Syvax use this same vector approach. The animation implementation remains downstream of the semantic character contract, so artwork technology cannot become the owner of application behavior.

## Character State Vocabulary

The shared character state vocabulary remains:

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

The Python/domain/application layers emit semantic state. Flutter maps that state to visual motion, emphasis and accessibility semantics.

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

## Architecture Direction

```text
Presentation
→ Character / Interaction Experience
→ Application Services
→ Domain
→ Intelligence
→ Infrastructure / Data
```

S4 preserves the application interaction gateway and permanent runtime boundary:

```text
Syvax ───────┐
             ├──> Application Request → Analysis Task → Event
Bloom ───────┘                                      │
                                                    ↓
                                              Dharen Runtime
                                                    │
                                                    ↓
                                          Python → WebSocket → Dart
                                                    │
                                                    ↓
                                         Flutter + SVG Characters
```

The character contract remains renderer-independent and suitable for vector-based character presentation.

## Application Boundary

`src/criterivox/application/` contains the application layer:

- `contracts.py` — versioned application intent, request, payload, result, event, and structured error representations.
- `service.py` — application service boundary connecting requests to application behavior.
- `provider.py` — provider abstraction and the current deterministic provider.

Syvax is the human/system dialogue host. Bloom is the capability gateway. Neither owns character state transitions or domain intelligence.

Only `Analyze` is currently implemented as the application vertical slice. Other Bloom capabilities are explicitly reserved rather than presented as fake backend functionality.

## Development Environment

- Python 3.13+
- Flutter / Dart
- SVG vector assets
- Glaxnimate for vector animation authoring
- Chrome for Flutter web development
- VS Code
- Git
- Jupyter / IPython for research experimentation

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

## Project Structure

- `src/criterivox/` — Python application source
- `src/criterivox/application/` — application contracts, service, and provider boundary
- `presentation/` — Flutter presentation source and vector character assets
- `tests/` — automated Python tests
- `experiments/` — research experimentation
- `docs/research/` — research records and hypotheses
- `docs/` — architecture, security, UX, research, sprint, and engineering documentation
- `start-criterivox.ps1` — canonical local runtime host
- `diagnostics/` — local generated runtime evidence; ignored by Git

## Deferred Product / Engineering Backlog

The following items remain product hardening and evolution work:

- Fix Bloom and character overflow across constrained layouts.
- Resolve overlay/layering issues between interface elements.
- Improve responsive resizing behavior across viewport sizes.
- Investigate and reduce long application startup/loading time.
- Replace remaining decorative/placeholder visuals with real functional components as their underlying capabilities become available.
- Evolve Bloom so capability nodes such as **Analyze can bloom into sub-capabilities**.
- Provide dedicated capability pages/routes where a capability requires a deeper workflow.
- Continue enriching vector character artwork and state-specific motion in Glaxnimate/SVG.

## Scope Boundary

S4 does not claim full intelligence, XAI, all 15 characters, production databases, authentication, social-media APIs, or completion of the broader research loop. The deterministic provider exists to prove the application boundary and runtime vertical slice. Future intelligence providers and richer character workflows must connect through the established boundaries rather than being embedded into Bloom or Syvax.
