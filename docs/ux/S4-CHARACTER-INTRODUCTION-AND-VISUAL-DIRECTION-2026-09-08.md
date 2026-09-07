# S4 Character Visual Direction and App Introduction

**Date:** 2026-09-08  
**Branch:** `s4-domain-analysis-workspace`

## 1. Visual Source of Truth

The supplied Dharen and Syvax character boards are the visual reference for the current character experience.

The boards establish:

- character identity and differentiation
- clothing and visual language
- environment/background treatment
- character expressions and poses
- six representative lifecycle states
- role presentation and personality cues

### Dharen

Dharen is presented as the calm, focused, empathetic, supportive and action-oriented insight guide. His visual language is warm, grounded and technologically capable without making him look like a generic robot or floating assistant.

### Syvax

Syvax is presented as the analytical, curious, calm, thoughtful and supportive insight specialist. His visual language is cooler, analytical and technology-oriented, with the distinctive glasses and blue/cyan environment.

The two characters must remain visually distinct. They are collaborators, not alternate skins of the same character.

## 2. Character State Vocabulary

The initial visual state vocabulary is:

| Semantic state | Visual role |
|---|---|
| IDLE | Available / waiting |
| RECEIVE | Receiving user input or task |
| WORK | Actively processing/analyzing |
| COMMUNICATE | Explaining or communicating |
| HANDOFF | Passing responsibility/context |
| COMPLETE | Completing a task or result |

The visual state is downstream of the application state.

## 3. Character Interaction Principle

Character animation is functional UI feedback.

It communicates what the system is doing without requiring the user to infer state from arbitrary decoration.

```text
User intent
   ↓
Application task
   ↓
Semantic state
   ↓
Character state
   ↓
Visual state
   ↓
User feedback
```

## 4. App Introduction UX

A new **App Introduction** surface has been added to explain CRITERIVOX through the characters themselves.

The introduction should answer three questions visually:

1. **Who are these characters?**
2. **What does each character do?**
3. **What can CRITERIVOX do for the user?**

The introduction introduces Syvax and Dharen as functional members of the system rather than mascots.

### Intended narrative

```text
Welcome to CRITERIVOX
        ↓
Meet Syvax
        ↓
Understand input, context, patterns and routing
        ↓
Meet Dharen
        ↓
Understand analysis, findings, evidence and action
        ↓
Understand the shared Analysis Task
        ↓
Explore implemented capabilities
        ↓
Enter Bloom / Workspace / Character Chat
```

## 5. Capability Honesty

The introduction distinguishes capabilities that are implemented from capabilities planned for future sprints.

Implemented in the current S4 experience:

- Bloom entry point
- Analysis Workspace
- Character Chat
- shared task context
- runtime character state propagation
- references/file attachment flow where supported
- Dharen and Syvax character interaction

Future capability placeholders remain visibly reserved rather than being presented as working functionality.

## 6. Relationship to Bloom

Bloom remains the primary application entry point.

The App Introduction is an explanatory surface and does not replace Bloom as the normal first screen.

```text
Application launch
       ↓
     Bloom
       ├── Analyze → Workspace
       └── Analyze → Character Chat

App Introduction
       └── Understand the system before entering the workflow
```

## 7. Visual Fidelity Rule

The supplied character boards take precedence over generic placeholder character artwork.

When an implementation detail conflicts with the supplied character identity, preserve the character identity and solve the implementation constraint around it where technically reasonable.

Do not remove the visual environments merely to make the character easier to render. Responsive cropping, framing and asset optimization should be used instead.
