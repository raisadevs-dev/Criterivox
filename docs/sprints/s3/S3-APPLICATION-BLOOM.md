# Criterivox S3 — Application Contracts + Syvax/Bloom Interaction Gateway

## Implementation status

S3 implementation is present on `s3-application-bloom` and preserves the permanent S2 Python ↔ Flutter WebSocket runtime.

## Runtime policy

The local WebSocket runtime is a project-wide runtime boundary, not an S2 disposable mechanism. S3 routes new application requests through that boundary while keeping the S2 legacy request path compatible.

The canonical local host remains:

```powershell
.\start-criterivox.ps1
```

The launcher already captures Python/Flutter stdout and stderr and creates `diagnostics/incident-CVX-*` artifacts when managed startup or runtime supervision fails. Generated diagnostics remain local and are intentionally ignored by Git.

S3 adds a repeatable verification command:

```powershell
.\scripts\verify-s3.ps1
```

The verification script stores each check's stdout/stderr under `diagnostics/verification-*`. On failure it creates a structured `incident-CVX-VERIFY-*` report with the failure and evidence location.

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

Syvax and Bloom are two presentation-side entry paths into the same application boundary. They do not own character state transitions.

## Contracts

`src/criterivox/application/contracts.py` defines versioned representations for:

- application intent
- request
- data/context payload
- application result
- application event
- structured application errors

The S3 request rejects unknown fields and enforces payload limits. The existing S2 runtime validation remains in place for legacy requests.

## Provider boundary

`src/criterivox/application/provider.py` contains the provider abstraction and the current deterministic implementation. S3 does not implement an intelligence engine. A future provider can replace the deterministic provider without requiring Bloom or Syvax to know how the work is performed.

## Syvax

Syvax is the human/system dialogue host. The S3 presentation provides:

- visible Syvax presence
- task input
- suggested synthetic requests
- submission into the application intent path
- status communication

## Bloom

Bloom is an interactive capability gateway rather than a static radial decoration. S3 provides six capability nodes. `Analyze` is the implemented vertical-slice capability. Other nodes remain explicitly reserved for future implementation and do not claim backend functionality.

## Vertical slice

Implemented path:

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
```

Python remains authoritative for the semantic Dharen lifecycle. Flutter renders the received presentation state.

## Regression policy

No S2 runtime is intentionally removed. The legacy S2 payload remains accepted at `/runtime/characters`, while S3 application requests are recognized by the `intent` field and routed through the new application boundary.

If future work identifies an existing component that appears obsolete or conflicts with the intended architecture, it must not be silently deleted. The architectural options should be presented for a project decision before removal.

## Research position

S3 provides engineering implementation evidence for the interaction architecture. It does not establish research claims about comprehension, trust, cognitive load, attention regulation, humor, or the effectiveness of character-mediated interaction.
