# Criterivox UI Stabilization Phase Closure

Branch: ui-stabilization-system-behavior
Phase: UI stabilization and human situation decision support
Status: implementation closed on this branch, pending normal repository verification/merge

## Problems closed

### 1. Human authentication entry
Human Territory now has a local-first sign-up/sign-in surface. Successful authentication creates or restores a private Human Residence session and routes directly into the human workspace.
Authentication remains local-first. It is not presented as production identity infrastructure.

### 2. Decision Desk action and result flow
Decision Desk now has an explicit human action: Help me think this through.
The response is surfaced in the same Decision Desk through a dedicated result panel containing the human-readable synthesis, saved decision identity when authenticated, strategy options, next actions, uncertainty and human-authority controls.
The Results Journal is connected to the persisted decision store rather than relying only on page-local decorative journal entries.

### 3. Backend 404 boundary
The managed launcher runs Flutter on port 8080 and Python on port 8000. Browser pages previously resolved /api/... against the Flutter origin, producing avoidable 404s.
A single CriterivoxApi resolver now targets the Python backend. The affected Human Territory and related browser pages use that resolver.

### 4. Hybrid input
Human situation intake is no longer conceptually shaped as JSON-only data.
The application boundary accepts ordinary text, structured maps/objects, lists, pasted material, form-encoded fields, multipart material/file metadata, and plain-text request bodies.
These forms are normalized into the existing situation/data capability boundary. JSON remains a supported transport, not a required human representation.

### 5. Safety and people-photo boundary
Photos of people remain contextual metadata. The system does not use appearance to identify people or infer personality, intent, morality, dangerousness, relationships, mental state or bullying behavior. Interpersonal support is grounded in reported behavior and safety context.

### 6. Prototype decorations
Existing decorative/prototype pieces are deliberately not deleted in this closure pass. Their purpose can be reconciled in a later visual-design pass. This phase closes functional wiring and human usability problems first.

## Architecture learning

The most important lesson from this phase is that human input, computational transport and internal representations are different layers.
A human may provide a sentence, a pasted table, a list of facts, a screenshot, a document, or a mixture. The system should normalize those forms at the input boundary and then reuse the existing capabilities. The UI should not force the human to think in internal schemas.

The second lesson is that a visible capability is not a completed user flow. A button, route or backend service is only complete when the human can reach it, trigger it, see the result, inspect it, and continue into the next authoritative surface.

The third lesson is that browser and backend origins must be explicit in a split local runtime. Relative browser API paths are unsafe when Flutter and Python intentionally run on different ports.

## Verification status

Repository tests and source checks were added for the changed boundaries. Fresh local Flutter/Python execution is still environment-dependent when a local toolchain is not available to the repository connector. This closure document therefore distinguishes implementation evidence from runtime verification and does not invent a passing test run.

## Intentionally deferred

- visual redesign of prototype/decorative components;
- production remote authentication;
- production distributed persistence;
- empirical claims about decision quality;
- new computational capabilities that were not already present in Criterivox.