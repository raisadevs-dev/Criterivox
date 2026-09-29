# Criterivox S4 — Domain Model + Living Analysis Workspace + Dharen Home

## Status

S4 establishes the first domain-backed Criterivox product workspace on top of the S3 application boundary.

## Product decision

S4 deeply implements only **Analyze**. Bloom continues to expose the broader capability vocabulary, but Compare, Explore, Plan, Insights, and Explain remain future capabilities rather than fake backend pages.

The product model is:

```text
USER
  ↓
BLOOM
  ↓
ANALYZE
  ↓
┌──────────────────────┐
│ OPEN WORKSPACE       │
│ OR CHAT WITH DHAREN  │
└──────────┬───────────┘
           ↓
      SAME ANALYSIS TASK
           ↓
      DOMAIN TASK STATE
           ↓
          DHAREN
           ↓
   WORKSPACE + INBOX
```

## Domain model

The S4 analysis aggregate is `AnalysisTask`.

### AnalysisTask

Owns one analysis request regardless of whether the user entered through Workspace or Dharen Chat.

It contains:

- stable task identifier
- task instruction
- data
- context
- source surface
- references
- lifecycle state
- result
- error state
- activity history
- timestamps

The current source values are `workspace`, `chat`, and `bloom`. Legacy `syvax` requests are mapped to the chat surface for compatibility.

### Result concepts

`AnalysisResult` contains:

- `Observation` — an observed property of the supplied material
- `Finding` — a deterministic interpretation that the current implementation can actually support
- `Evidence` — the recorded basis associated with an observation/finding

These are intentionally small domain concepts. They are not claims that Criterivox already contains a full intelligence or XAI engine.

### Task lifecycle

```text
CREATED
  ↓
RECEIVED
  ↓
VALIDATING
  ↓
PROCESSING
  ↓
ANALYZING
  ↓
RESULT_READY
  ↓
COMPLETED
```

Failure and waiting states exist only as explicit domain states and are not used to manufacture visual progress.

Invalid transitions are rejected by the aggregate.

## Application boundary

S4 preserves S3's application boundary and permanent Python ↔ Flutter runtime.

```text
Flutter / Bloom / Chat
        ↓
ApplicationRequest
        ↓
AnalysisTaskService
        ↓
AnalysisTask
        ↓
Deterministic analysis procedure
        ↓
Application/runtime event
        ↓
Dharen runtime mapping
        ↓
PresentationContract
        ↓
Flutter
```

The domain owns task meaning and lifecycle. The application layer coordinates. Dharen does not own the analysis task.

## One task, two surfaces

Workspace and chat are views of the same process-local `AnalysisTaskStore` during this sprint.

If Workspace creates `AN-XXXXXXXX`, the task identifier is carried through the runtime state. Dharen Inbox can query that same identifier and report the current authoritative task state.

If Chat creates the task, the resulting task state is also published through the same runtime contract, so the Workspace can represent it.

The runtime does not create a second analysis task merely because the user changes surface.

## Dharen Home

Dharen is embedded in the Analysis Workspace rather than being a decorative side panel.

The existing Character Bible identity and shared character state vocabulary remain in use:

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
WARNING
```

S4 maps authoritative analysis task state to Dharen state:

| Analysis task state | Dharen state |
|---|---|
| CREATED | IDLE |
| RECEIVED | RECEIVE |
| VALIDATING | WORK |
| PROCESSING | WORK |
| ANALYZING | WORK |
| RESULT_READY | COMMUNICATE |
| COMPLETED | COMPLETE → IDLE |
| WAITING | WARNING |
| FAILED | WARNING |
| CANCELLED | IDLE |

Flutter receives the semantic state. It does not invent the lifecycle.

## Character animation stack

The character presentation stack is intentionally lightweight and vector-first:

```text
Python semantic character state
        ↓
WebSocket runtime contract
        ↓
Dart PresentationState
        ↓
Flutter character renderer
        ↓
SVG artwork
        ↓
Visible character motion
```

Character artwork is authored/animated as vector source in **Glaxnimate**, exported as SVG assets, and rendered in Flutter. Flutter owns state-driven presentation motion, responsive layout and reduced-motion behavior. SVG artwork remains presentation data and does not own application behavior.

Dharen and Syvax are the first characters on this vector pipeline. The surrounding workspace, Bloom, chat, task state and runtime contract remain unchanged.

## Chat status behavior

A status question such as `What's the current state?` is answered from the stored task state. The response does not invent progress percentages, completion times, or unsupported internal operations.

## Runtime contract

The existing `/runtime/characters` WebSocket remains the permanent runtime boundary.

S4 enriches its renderer-independent presentation contract with task information including:

- task id
- task state
- source
- task instruction
- data/context field counts
- observations
- findings
- evidence
- activity history
- error state

This allows Workspace, Inbox, notification, and character rendering to consume the same authoritative state.

## Visual product direction

The supplied reference images were used as UX quality references for:

- deep-work information hierarchy
- dark professional visual language
- workspace density
- persistent Dharen presence
- task lifecycle visibility
- observations/results areas
- integrated inbox/chat
- responsive composition

Criterivox content is intentionally not copied from the reference's social-media-specific dashboard. The workspace uses Criterivox concepts: task, data, context, observations, findings, evidence, activity, and Dharen.

## Accessibility

The character renderer remains semantic and state-labelled. The workspace uses readable labels and controls rather than making animation the sole state channel. The existing reduced-motion character path remains preserved through the presentation state contract.

## Security and validation

The S4 boundary continues to reject unknown application request fields, enforces payload limits, bounds task/reference sizes, validates task source values, rejects malformed chat messages, and does not expose command execution through chat.

## Testing

S4 adds tests for:

- task creation and identity
- lifecycle invariants
- invalid transitions
- empty tasks and reference limits
- deterministic task execution
- publish/state synchronization
- application request compatibility
- character presentation state rendering

Existing S2/S3 tests remain part of the regression suite.

## Explicit non-goals

S4 does not implement:

- full 15-character orchestration
- LLM intelligence
- full XAI
- social-media API integrations
- production database persistence
- authentication
- complete experiment/evidence/knowledge engine
- all Bloom capabilities

The deterministic analysis procedure is implementation evidence for the domain/runtime architecture only.
