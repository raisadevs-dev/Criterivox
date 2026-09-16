# ADR-010 — S7 Domain-Bounded Local NLP and Conversation Architecture

- **Status:** Accepted for S7 implementation
- **Scope:** Intelligence Bureau → Reasoning Research Bureau
- **Sprint:** S7
- **Decision date:** 2026-09-16

## Context

S7 requires a human-facing Debate Arena in which Human, Vivren, and Tarkis can interact. The first implementation used deterministic keyword classification. That was sufficient for direct commands but did not preserve conversational context across short follow-ups such as `Why?`, `What about alternatives?`, and `Compare them.`

S7 also requires a strict separation between presentation behavior and computational truth. Vivren and Tarkis are character-mediated reasoning roles, not sources of truth. Authoritative S7 artifacts, events, results, and provenance remain the basis for analytical claims and visualizations.

## Decision

Evolve S7's local NLP into a deterministic, offline **Intent + Target + Context + Conversation-State Engine**.

The pipeline is:

```text
Human input
  → local NLP parsing
  → intent classification
  → target extraction
  → conversational reference resolution
  → conversation state
  → character-specific policy
  → structured S7 action
  → authoritative artifact/event
  → character/UI/visualization
```

The NLP layer interprets language. It does not perform the underlying reasoning and does not establish computational truth.

## Local and deterministic constraints

The S7 engine:

- runs locally inside the S7 presentation/application boundary;
- does not call an online LLM;
- does not require network inference;
- uses an explicit, auditable intent vocabulary and phrase registry;
- produces deterministic classifications for the same input/state;
- carries confidence and preserves ambiguity;
- must not invent a target when conversational context is insufficient;
- remains independently testable.

## Intent model

S7 intents are divided into three broad groups.

### Critical / inspection

`ASK_EVIDENCE`, `ASK_CONTEXT`, `ASK_REASONING`, `ASK_PROVENANCE`, `ASK_LIMITATIONS`, `CHALLENGE_CLAIM`, `INSPECT_REASONING`, `INSPECT_ASSUMPTION`, `INSPECT_CONTRADICTION`.

### Exploration

`EXPLORE_HYPOTHESIS`, `FIND_ALTERNATIVES`, `COMPARE_HYPOTHESES`, `EXPAND_BRANCH`, `TEST_HYPOTHESIS`, `REFINE_HYPOTHESIS`, `EXPLORE_COUNTERFACTUAL`.

### Conversation control

`CONFIRM`, `REJECT`, `CONTINUE`, `BACK`, `EXPAND`, `CLARIFY`, `GENERAL`.

The vocabulary is intentionally domain-bounded rather than a general-purpose chatbot ontology.

## Target and context model

Intent and target are separate values. For example:

```text
COMPARE_HYPOTHESES + target=hypotheses
ASK_EVIDENCE       + target=claim
```

Short references such as `it`, `this`, `that`, `them`, `these`, `those`, and `previous` are resolved against explicit S7 conversation state. If no compatible target is available, the engine reports ambiguity instead of fabricating a referent.

## Conversation state

One S7 conversation session maintains:

- active intent;
- active target;
- active artifact ID;
- active hypothesis ID;
- active claim ID;
- pending clarification/confirmation state;
- bounded conversation history.

Conversation state is interaction context only. It is not a replacement for authoritative artifacts or results.

## Character policy separation

The same interpreted intent may produce different character actions.

### Vivren

Vivren's policy emphasizes critical inspection: evidence, assumptions, contradictions, context, provenance, limitations, and reasoning integrity.

### Tarkis

Tarkis's policy emphasizes hypothesis exploration: alternatives, branches, counterfactuals, comparison, testing, and refinement.

This preserves the S7 architectural distinction between critical inspection and hypothesis exploration.

## Structured action boundary

The conversation engine should produce a structured action rather than treating generated prose as the result of reasoning.

Conceptually:

```text
S7ConversationAction(
  intent,
  target,
  actor,
  confidence,
  requiresClarification,
)
```

The action may then be dispatched to an authoritative S7 mechanism that creates or selects an artifact/event. Presentation can subsequently expose the result through the character state machine, Critical Findings/Hypothesis Field, Debate Arena, or a traceable floating visualization.

## Example flow

```text
Human: "Find alternatives for H1."
  → FIND_ALTERNATIVES
  → target=H1
  → Tarkis policy

Human: "Compare them."
  → COMPARE_HYPOTHESES
  → "them" resolves to alternatives associated with H1
  → Tarkis policy
  → comparison action/artifact
  → comparison visualization
```

Another example:

```text
Human: "This conclusion seems weak."
  → CHALLENGE_CLAIM
  → active claim context
  → Vivren policy

Human: "Why?"
  → ASK_REASONING
  → context resolves to the active claim
  → Vivren inspection path
```

## Debate Arena integration

Message chips remain supported as deterministic structured entry points. Free-form messages and chips must converge on the same NLP/conversation pipeline rather than maintaining separate conversational logic.

The Debate Arena therefore becomes a client of the S7 conversation engine, not an independent response generator.

## Visualization integration

NLP should never fabricate visualization data. It can request an analytical action, after which the authoritative artifact/result determines whether a visualization is valid.

Examples:

```text
ASK_EVIDENCE
  → evidence artifact
  → Evidence Matrix

INSPECT_CONTRADICTION
  → contradiction artifact
  → Contradiction Graph

FIND_ALTERNATIVES
  → hypothesis artifacts
  → Hypothesis Tree

COMPARE_HYPOTHESES
  → comparison artifact
  → Comparison Map
```

Source artifact identity and provenance remain attached to the visualization.

## Future compatibility

S7 does not implement a Criterivox-wide NLP network. However, the bureau-level boundary must avoid exposing internal parser details. Future bureaus may independently implement their own local NLP engines and later communicate through a shared Criterivox bureau contract.

S7 therefore establishes a **future compatibility boundary**, not a dependency on future bureaus.

## Consequences

### Positive

- Multi-turn Debate Arena interaction becomes possible without an online LLM.
- Intent, target, context, and ambiguity are inspectable and testable.
- Vivren and Tarkis remain meaningfully distinct.
- NLP can drive actual S7 actions rather than decorative text.
- Future parser implementations can change behind the bureau boundary.
- Offline operation and reproducibility are preserved.

### Trade-offs

- The engine will not have general semantic understanding.
- Vocabulary and reference rules require deliberate maintenance.
- Ambiguous natural language will sometimes require clarification.
- A future semantic model may eventually be useful, but it is not justified merely by the existence of the capability.

## Non-goals

This ADR does not introduce:

- online LLM inference;
- autonomous general reasoning;
- cross-bureau networking;
- a global Criterivox NLP engine;
- replacement of S7's authoritative reasoning/artifact systems.

## Implementation mapping

Current S7 modules establish these boundaries:

```text
presentation/lib/s7/s7_local_nlp.dart
presentation/lib/s7/s7_nlp_intents.dart
presentation/lib/s7/s7_conversation_state.dart
presentation/lib/s7/s7_context_resolver.dart
presentation/lib/s7/s7_conversation_engine.dart
presentation/lib/s7/s7_nlp_debate_arena.dart
```

The implementation should continue to preserve existing S7 API/session/intervention behavior while adding this interaction layer.
