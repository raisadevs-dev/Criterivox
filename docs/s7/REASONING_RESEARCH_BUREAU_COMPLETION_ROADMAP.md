# Criterivox S7 — Reasoning Research Bureau Completion Roadmap

## Scope boundary

S7 is the **Reasoning Research Bureau** under the Intelligence Bureau. It contains exactly three user-facing work spaces:

1. **Collaboration Room** — primary S7 landing environment and shared intelligence workspace.
2. **Critical Intelligence Chamber** — Vivren's critical reasoning workspace: assumptions, evidence quality, objections, defects, limitations and epistemic assessment.
3. **Hypothesis Exploration Chamber** — Tarkis's hypothesis workspace: alternatives, branches, counterfactuals, scenarios and refinement.

There is **no S7 Home/Intelligence Home room**. Global Intelligence Home is deliberately deferred until after S8.

## Completion target

The target is 97–99% of the requirements that belong to S7. A percentage is not counted as complete merely because a screen exists. A requirement is complete only when its computation/state, persistence where applicable, user interaction and presentation are connected end-to-end.

## Implementation sequence

### 1. Reasoning engine
- Execute the ten public reasoning stages.
- Preserve events and inspectable artifacts without exposing hidden chain-of-thought.
- Detect insufficient information and stop rather than fabricate.
- Prefer existing methods; adapt/compose when adequate; design new mechanisms only where necessary.

### 2. Analytical domain model
- Reasoning nodes and dependencies.
- Hypothesis identity, origin, basis, evidence, objections, evaluation, branch, version and limitations.
- Branch identity, parent/divergence, assumptions and outcome.
- Explicit evaluation and uncertainty states.

### 3. Persistence and provenance
- SQLite is the authoritative local history.
- Preserve sessions, artifacts, versions, parent/lineage relationships, branches, events, interventions, limitations and provenance.
- Browser IndexedDB remains a cache/snapshot, never the authority.
- Restore sessions and reconstruct inspectable history.

### 4. Flutter intelligence environment
- Collaboration is the S7 landing environment.
- Layered environmental background and translucent functional surfaces.
- Progressive overview → detail → deep inspection.
- Independent panel focus/collapse/reopen behavior.
- Real reasoning graph rendered from S7 state.

### 5. Critical Intelligence Chamber
- Critical findings are visually distinct.
- Inspect assumptions, evidence, contradictions, objections, limitations and provenance.
- Trace findings back to supporting artifacts.
- Human challenge must create a recorded computational consequence.

### 6. Hypothesis Exploration Chamber
- Inspect hypotheses as analytical objects.
- Show competing hypotheses and their evidence/objections/evaluation.
- Visualize real branches and branch identity.
- Distinguish observed reasoning from counterfactual/scenario exploration.
- Support compare, challenge, revise, reject and continue actions where implemented by the authoritative S7 state.

### 7. Human control
- Observe, inspect, trace, compare, challenge and intervene.
- Human intervention becomes an event/artifact.
- Intervention creates a preserved branch/version and causes recomputation.
- Insufficient information requests context instead of inventing it.

### 8. Character cinematics
- Canonical Vivren/Tarkis identity across all S7 spaces.
- Semantic animation derives from authoritative S7 state.
- Ambient animation is visually separate from computation state.
- Characters represent the bureau's work; mechanisms and orchestration perform the computation.

### 9. Fixture Laboratory
- `reasoning/`, `hypothesis/`, `contradiction/`, `provenance/`, `intervention/`, `insufficient_context/`, `cross_component/` scenario families.
- JSON, CSV and XLSX outputs plus manifests.
- Interactive questionnaire and deterministic seed.
- Optional AI-assisted generation must not become a production dependency.

### 10. Validation
- Unit tests for reasoning and state transitions.
- Persistence/restore tests.
- Human intervention and branch tests.
- Flutter navigation, inspection, graph and interaction tests.
- Adversarial fixtures for contradictions, sparse context, competing hypotheses, deep branching, repeated intervention and unresolved outcomes.

## Release gate

S7 is release-candidate quality when the full path works without mocked UI-only state:

`Receive → Interpret → prerequisites → capabilities → mechanisms → reasoning → alternatives → evaluation → artifacts/provenance → human inspection → challenge/intervention → branch/revision → recomputation → updated analysis or unresolved state`.

## Explicitly deferred

- Intelligence Home / global Home control.
- Post-S8 cross-bureau navigation and orchestration.
- Future S8 functionality.
- Global UX work that depends on the completed S8 bureau.
