# Criterivox S2 — Runtime Character Integration

## Status

**S2 runtime integration is complete.** The local automated validation and real manual runtime demonstration passed on the S2 integration work.

The completed proof is the live path:

```text
User action
  ↓
Flutter presentation
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
visible Dharen lifecycle
```

The demonstrated Dharen lifecycle is:

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

Flutter does not invent this sequence. Python emits the semantic character state and Flutter renders it.

## Runtime boundary

The runtime transport is a **local WebSocket boundary**. Python owns semantic character behavior; Flutter consumes the versioned presentation contract and chooses the visual representation.

## Renderer pipeline

Character artwork and motion are now implemented with a lightweight vector pipeline:

```text
Character artwork
      ↓
Glaxnimate source / SVG
      ↓
Flutter SVG rendering
      ↓
Flutter state-driven motion
      ↓
Visible animated character
```

The semantic renderer contract remains independent of the artwork format. Dharen and Syvax use SVG assets; Flutter handles responsive placement, state emphasis, transitions and reduced-motion behavior.

## Contract

`PresentationContract` remains versioned at `contract_version = 1` and carries renderer-independent semantic information:

- character identity
- semantic character state
- animation state
- activation
- prominence
- reduced-motion flag
- optional communication message
- optional originating event

The renderer receives semantic state such as `WORK`, not technology-specific commands.

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

## Validation and security

The Python boundary validates request fields, task size, data/context limits and serialized payload size. The Dart receiver validates contract version, character identity, character state, activation, prominence, message and event values.

The runtime boundary must never become an arbitrary command-execution channel.

## Verification evidence

Automated presentation/runtime coverage includes runtime contract decoding, runtime character presentation, accessibility semantics, character state mapping, reduced-motion behavior, communication, handoff, responsiveness and widget rendering.

The manual proof is:

1. Run `.\start-criterivox.ps1` from the repository root.
2. The launcher starts Python and Flutter automatically.
3. Python becomes ready through `/health`.
4. The presentation connects to the Python runtime.
5. Synthetic JSON data, context and a task are supplied.
6. **Send analysis request to Python** is invoked.
7. Dharen visibly transitions through `RECEIVE → WORK → COMMUNICATE → COMPLETE → IDLE`.
8. The visible lifecycle is driven by the Python runtime boundary.

## Known limitations carried forward

- Direct user → Dharen input is a temporary S2 source boundary.
- Syvax → Dharen orchestration is future work.
- The current analysis operation is deterministic and synthetic.
- Full 15-character runtime integration is future work.
- The vector artwork pipeline will continue to evolve as character animation assets become richer.
- The local runtime host is a development supervisor, not a production distributed process manager.

## Research position

This implementation provides engineering evidence that semantic character state can cross a Python/Flutter technology boundary and drive presentation. It does **not** establish that character-mediated interaction improves comprehension, trust, cognitive load, responsiveness, or user experience. Those remain research hypotheses for later evaluation.
