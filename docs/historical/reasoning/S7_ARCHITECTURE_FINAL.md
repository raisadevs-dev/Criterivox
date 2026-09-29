# Criterivox S7 — Final Architecture

## Architectural position

S7 is the **Reasoning Research Bureau** inside the Intelligence Bureau. Its presentation layer is organized around three distinct workspaces and a shared analytical infrastructure.

```text
Intelligence Bureau
└── Reasoning Research Bureau (S7)
    ├── Collaboration Room
    ├── Critical Intelligence Chamber
    │   └── Vivren
    └── Hypothesis Exploration Chamber
        └── Tarkis
```

## Processing architecture

The S7 interaction path separates deterministic interpretation, context resolution, character policy and presentation:

```text
User input
   ↓
Debate Arena
   ↓
S7ConversationEngine
   ├── S7LocalNlp
   │    └── deterministic intent + target classification
   ├── S7ContextResolver
   │    └── follow-up/reference resolution
   ├── S7CharacterResponsePolicy
   │    └── Vivren/Tarkis-specific response behavior
   └── S7ConversationState
        └── bounded conversational context
   ↓
Character response / presentation event
```

This layer is deliberately offline. The conversation UI does not depend on a remote LLM.

## Character responsibility model

| Character | Primary analytical responsibility | Typical interaction vocabulary |
|---|---|---|
| Vivren | Critical inspection | evidence, assumptions, contradictions, provenance, limitations, reasoning integrity |
| Tarkis | Hypothesis exploration | hypotheses, alternatives, branches, counterfactuals, comparison, testing, refinement |

The distinction is architectural, not merely cosmetic.

## Visualization architecture

Analytical presentation follows the principle:

```text
Authoritative S7 artifact/state
        ↓
VisualizationFactory
        ↓
Semantic visualization type
        ↓
FloatingVisualization
        ↓
User inspection / collapse / reopen
```

Supported semantic forms include:

- Reasoning Graph
- Hypothesis Tree
- Evidence Matrix
- Contradiction Graph
- Timeline
- Confidence Chart
- Branch Map
- Comparison Chart
- Provenance Graph

A visualization should only represent information supported by the underlying artifact. Decorative motion is not evidence and must not be treated as computation.

## Room architecture

### Collaboration Room

Shared intelligence, human participation, Debate Arena and collaborative analytical objects form the center of S7.

### Critical Intelligence Chamber

The chamber is organized around Vivren's inspection role. Critical findings, evidence, assumptions, contradictions, provenance and reasoning integrity are its primary analytical surfaces.

### Hypothesis Exploration Chamber

The chamber is organized around Tarkis's exploratory role. Hypothesis fields, alternatives, branches, comparison, counterfactuals and refinement are its primary analytical surfaces.

## State boundary

Presentation state may control visibility, focus, collapse/reopen behavior, animation and UI selection. It must not become the authority for reasoning truth.

Authoritative analytical state remains responsible for:

- reasoning results;
- artifacts;
- evidence and provenance;
- hypotheses and branches;
- interventions;
- revisions;
- limitations and uncertainty.

## Character state model

Vivren's semantic states are oriented around inspection and critical analysis, including observing, inspecting, thinking, critiquing, flagging, explaining, resolving and completion.

Tarkis's semantic states are oriented around exploration, including receiving, exploring, generating, branching, comparing, testing, reflecting, refining and presenting.

Ambient animation is separate from these computationally meaningful states.

## Architectural constraints carried forward

1. No S7 Home screen.
2. No online LLM dependency for Debate Arena conversation handling.
3. Human Attention is not reused as Debate Arena.
4. Vivren and Tarkis must not be collapsed into one generic analytical persona.
5. UI animation must not fabricate analytical results.
6. Visualization objects must retain a traceable relationship to their source artifacts.
7. Future cross-bureau work belongs outside the closed S7 branch.
