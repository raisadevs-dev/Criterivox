# Criterivox S3 — Application Contracts + Syvax/Bloom Interaction Gateway

## Status

**S3 is implementation-complete and documentation-complete.** The sprint establishes the application interaction boundary between the human-facing Flutter presentation and the Python application while preserving the permanent S2 Python ↔ Flutter WebSocket runtime.

S3 is ready for final validation and sprint closure.

## Objective

S3 makes Syvax and Bloom real presentation-side entry points into the application system rather than isolated visual elements.

The target architecture is:

```text
USER
  ↓
SYVAX + BLOOM
  ↓
APPLICATION INTENT
  ↓
APPLICATION SERVICE
  ↓
APPLICATION EVENT
  ↓
RELEVANT CHARACTER / WORKFLOW
  ↓
RESULT
  ↓
SYVAX / USER
```

The current implemented vertical slice uses `Analyze` and Dharen.

## Permanent runtime policy

The local WebSocket runtime established during S2 is a **permanent project runtime boundary**, not an S2 disposable mechanism.

S3 connects its application layer to that existing runtime while preserving compatibility with the S2 character request path.

The canonical local development entry point is:

```powershell
.\start-criterivox.ps1
```

The launcher validates the environment, starts the project `.venv` Python runtime, waits for `/health`, starts Flutter Web, supervises both processes, and stops managed processes together.

### Developer diagnostics

Critical runtime failures are recorded under:

```text
diagnostics/
└── incident-CVX-YYYYMMDD-HHMMSS/
    ├── incident.md
    └── incident.json
```

S3 verification also uses:

```powershell
.\scripts\verify-s3.ps1
```

Verification output is stored under `diagnostics/verification-*`. Diagnostics are developer-facing and intentionally ignored by Git.

## S3 application boundary

```text
Syvax ───────┐
             ├──> ApplicationRequest
Bloom ───────┘          │
                        ▼
                 ApplicationService
                        │
                        ▼
              DeterministicProvider
                        │
                        ▼
                ApplicationEvent
                        │
                        ▼
                 DharenRuntime
                        │
                        ▼
                PresentationContract
                        │
                        ▼
                     Flutter
```

Syvax and Bloom share the same application boundary. They do not own domain intelligence, provider execution, or character state transitions.

## Application contracts

`src/criterivox/application/contracts.py` defines versioned representations for:

- application intent
- application request
- data/context payload
- application result
- application event
- structured application errors

The S3 request boundary rejects unknown fields and enforces payload limits. Existing S2 runtime validation remains in place for legacy requests.

The contracts intentionally keep presentation concerns separate from application behavior so future providers, workflows and renderers can evolve independently.

## Application service and provider

`src/criterivox/application/service.py` provides the application service boundary.

`src/criterivox/application/provider.py` provides the provider abstraction and current deterministic implementation.

The deterministic provider is deliberately synthetic. S3 is proving the application interaction architecture, not implementing an intelligence engine or making an ML/XAI claim.

A future intelligence provider can replace the deterministic implementation without requiring Bloom or Syvax to understand how the work is performed.

## Syvax

Syvax is the **human/system dialogue host**.

S3 provides:

- visible Syvax presence
- user task input
- suggested inputs
- submission into the application intent path
- status communication

Syvax is not the domain engine, intelligence engine, or character orchestrator.

## Bloom

Bloom is the **capability gateway**.

S3 provides six capability nodes:

- Analyze
- Compare
- Explore
- Plan
- Insights
- Explain

`Analyze` is the currently implemented vertical-slice capability. The remaining capabilities are visibly reserved for future implementation and do not claim backend functionality.

This is intentional. A visual node is not considered a real application capability merely because it exists on screen.

## End-to-end vertical slice

The implemented S3 path is:

```text
USER
  ↓
SYVAX OR BLOOM
  ↓
APPLICATION INTENT: ANALYZE
  ↓
APPLICATION REQUEST
  ↓
APPLICATION SERVICE
  ↓
DETERMINISTIC PROVIDER
  ↓
ANALYSIS_STARTED / ANALYSIS_COMPLETED
  ↓
DHAREN RUNTIME
  ↓
RECEIVE → WORK → COMMUNICATE → COMPLETE → IDLE
  ↓
PRESENTATION CONTRACT
  ↓
FLUTTER CHARACTER RENDERER
  ↓
VISIBLE USER FEEDBACK
```

Python remains authoritative for semantic Dharen state. Flutter renders the received state and does not invent the lifecycle sequence.

## Dharen responsibility in S3

Dharen remains the first functional character slice established in S2.

For S3, the application layer can activate the existing Dharen runtime as part of the Analyze vertical slice. The character remains a functional interaction entity rather than a decorative mascot.

The current deterministic operation accepts:

```text
data
+
context
+
task
```

and produces application events sufficient to drive the character lifecycle.

## Error and security boundary

The application boundary validates request structure, known intent values, payload size and required fields.

The runtime boundary validates character identity, allowed semantic states and presentation contract values.

The runtime must not become an arbitrary command-execution channel.

Developer diagnostics must remain separate from user-facing errors. User-facing presentation should expose concise status/error information rather than stack traces, local filesystem paths, credentials, or internal transport details.

## Regression policy

S3 does not intentionally remove the S2 runtime.

The existing legacy character payload remains accepted at `/runtime/characters`, while requests carrying the S3 application `intent` are routed through the application boundary.

The S2 runtime remains the foundation for future sprints.

If an existing component later appears obsolete or conflicts with the intended architecture, it must not be silently deleted. Architectural alternatives should be evaluated before removal.

## Validation

The S3 interaction tests cover the current presentation gateway behavior, including Bloom capability exposure/reservation and Syvax input submission.

The runtime was also manually launched through the canonical project host and confirmed operational before sprint closure work.

Final closure still requires the repository's final validation pass after documentation changes.

## Known limitations carried into the next sprint

The following are **deferred product hardening/evolution items**, not reasons to reopen the completed S3 application boundary:

1. **Overflow** — capability and character layouts need robust constrained-size behavior.
2. **Overlay** — overlapping/layering behavior needs correction.
3. **Responsive resizing** — Bloom, characters and surrounding shell need stronger viewport adaptation.
4. **Long loading time** — startup/runtime loading needs profiling and optimization.
5. **Decorative placeholders** — remaining visual-only elements should be replaced by real functional components as their underlying capabilities are implemented.
6. **Bloom sub-capabilities** — capability nodes such as Analyze should later bloom into relevant sub-capabilities.
7. **Dedicated capability pages** — capabilities requiring deeper workflows should have dedicated pages/routes.

These items are recorded here so they are not mistaken for completed functionality.

## Research position

S3 provides engineering evidence that a human-facing interaction gateway can enter an application service and activate the existing character/runtime boundary.

It does **not** establish research claims about comprehension, trust, cognitive load, attention regulation, discoverability, task efficiency, or the effectiveness of character-mediated interaction.

The Bloom interaction remains an architectural research prototype. Formal comparative evaluation remains future work.

## Closure criteria

S3 may be marked closed when the final validation confirms:

- application contracts remain valid;
- Syvax and Bloom reach the same application boundary;
- Analyze activates the existing runtime vertical slice;
- Python remains authoritative for Dharen semantic state;
- Flutter renders the resulting state;
- S2 regression remains intact;
- documentation and README describe the actual current state;
- known limitations are carried into the next sprint backlog.
