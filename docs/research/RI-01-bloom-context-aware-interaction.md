# RI-01: Context-Aware Bloom Interaction

## Status
Design hypothesis / early research direction

## Observation

Conventional dashboard navigation exposes the same navigation structure
regardless of the user's current context.

Criterivox explores a navigation model in which the primary exploration
interface can adapt to the user's current component, workspace, or task.

## Problem

A static navigation structure may expose capabilities that are irrelevant
to the user's current context while hiding capabilities that are more
relevant to the task being performed.

## Design Opportunity

Investigate whether a context-aware Bloom interface can progressively expose
relevant capabilities while preserving conventional navigation as an
accessible fallback.

## Proposed Solution

Criterivox uses three complementary navigation layers:

1. Bloom
   - Primary exploration
   - Context-aware capability discovery

2. Top-level utility navigation
   - Persistent access to global functions

3. Accessible fallback navigation
   - Conventional semantic navigation
   - Independent of Bloom

The Bloom is intended to change its available capabilities according to
the current application context.

## Why It Matters

The goal is to reduce irrelevant navigation and make available actions more
closely related to the user's current task.

This may be particularly useful in an intelligent analytical system where
different contexts can require different capabilities.

## Research Question

Does context-aware progressive disclosure through a Bloom-style interaction
improve capability discoverability and task efficiency without reducing
predictability or accessibility?

## Hypothesis

Context-aware capability presentation may improve task relevance and
discoverability compared with a static navigation structure, provided that
conventional navigation remains available as a fallback.

## Design Mechanism

CURRENT CONTEXT
        ↓
AVAILABLE CAPABILITIES
        ↓
RELEVANT CAPABILITIES
        ↓
BLOOM
        ↓
CONTEXTUAL ACTION
        ↓
RESULT / AGENT INTERACTION

## Current Prototype Finding

The current prototype demonstrates the basic Bloom interaction and
context-aware capability filtering mechanism.

However, the Bloom currently remains visually and functionally limited
compared with the intended future interaction model.

The current prototype should therefore be treated as an architectural
prototype rather than evidence of usability superiority.

## Evaluation Method

Future evaluation should compare:

A. Static navigation / static Bloom

against

B. Context-aware Bloom

Potential measures:

- task completion time
- capability discoverability
- incorrect selections
- navigation steps
- perceived cognitive load
- user preference
- accessibility performance

## Open Questions

- How much contextual change is useful before the interface becomes
  unpredictable?
- How should contextual capabilities be prioritized?
- How should users understand why an option appeared?
- How should Bloom behave when many capabilities are relevant?
- Does the interaction remain usable across desktop, tablet, and mobile?
- How does the system interact with intelligent agents?
- Does contextual adaptation actually improve task performance?

## Scope Boundary

This research item does not claim that Bloom is superior to conventional
navigation.

It establishes a testable design hypothesis for future evaluation.

## S1 Status

Prototype demonstrated.
Formal comparative evaluation remains future work.