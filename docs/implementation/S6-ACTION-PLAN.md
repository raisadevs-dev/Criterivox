# Criterivox S6 Action Plan

**Purpose:** operational plan for validating, demonstrating and carrying S6 Context Intelligence forward after the S6 implementation branch is merged.

## Phase A — Merge and baseline verification

1. Merge `s6-context-engine` into `main` using a normal merge commit.
2. Confirm `main` contains the S6 closure document and action plan.
3. Run Python tests, Flutter analysis/tests/build and the S6-specific regression suite.
4. Record the resulting commit SHA and CI run as the S6 baseline.

**Exit condition:** merged `main` is green and the merge commit is traceable to the S6 branch head.

## Phase B — Browser residency and recovery proof

1. Populate a DataFoundation through the S5 flow.
2. Confirm the serialized foundation is stored in browser residency.
3. Build the S6 ContextFrame from the authoritative foundation.
4. Persist ContextFrame, AdaptiveContextState, checkpoint and scratchpad.
5. Restart the Python runtime.
6. Reconnect the browser and send `foundation_sync`.
7. Verify stale/equal/conflicting revision protection.
8. Verify that the recovered browser foundation becomes authoritative only when its revision is valid.

**Exit condition:** a Python restart does not destroy or silently downgrade the authoritative browser foundation.

## Phase C — Dharen baseline proof

1. Feed Dharen the complete DataFoundation plus user/task context, constraints, guidelines, environment and relevant history.
2. Verify the complete foundation remains available as a critical binding.
3. Verify framing, scope boundaries, clash/firewall decisions, tiering and token allocation.
4. Verify the compact `PresentationContract` is only a projection of authoritative state.
5. Verify provenance/reference IDs survive the context transformation.

**Exit condition:** Dharen's output is reproducible, traceable and grounded in the S5 foundation.

## Phase D — Anuka adaptive proof

Run one test per trigger:

- new context;
- requirements changed;
- evidence changed;
- hypothesis changed;
- constraint changed;
- context drift detected;
- counterfactual requested;
- downstream incompatibility.

For each case verify:

```text
baseline ContextFrame
        ↓
trigger
        ↓
Anuka activation
        ↓
ContextDiff
        ↓
adaptive state
        ↓
checkpoint
        ↓
stateful handoff
```

Also verify the no-trigger case does not perform unnecessary adaptive mutation.

## Phase E — Sandbox and shadow execution proof

The acceptance path is:

```text
CREATE
  ↓
POPULATE ISOLATED VARIABLES
  ↓
RUN / REPLAY
  ↓
INSPECT RAW VARIABLES + RESULT
  ↓
COMPARE WITH ACTIVE STATE
  ↓
PROMOTE / DISCARD
```

Required tests:

1. Create a sandbox from the active state.
2. Modify only sandbox variables.
3. Run the fork through the complete downstream context/task pipeline.
4. Prove active state is unchanged while the fork runs.
5. Inspect raw fork variables and result.
6. Compare fork and active state.
7. Promote a selected fork and verify the active revision changes exactly once.
8. Repeat with discard and verify the active state remains unchanged.
9. Run concurrent forks and prove their variables do not leak into one another.

## Phase F — Dynamic token allocator evaluation

Measure the allocator with contexts containing different combinations of:

- hard constraints;
- critical evidence;
- high-priority task context;
- medium background context;
- low-priority material;
- oversized items;
- conflicting items.

Verify that:

- mandatory material is protected;
- budget is calculated from the actual requested/available budget;
- item cost estimates affect allocation;
- priority/tier affects allocation;
- compression metadata matches the retained set;
- no lower-priority item displaces a mandatory constraint;
- telemetry exposes the allocation decision.

Record allocation fixtures as regression data.

## Phase G — Learned ML validation

Treat learned models as an augmentation layer, not as the authority for safety or scope.

### Dharen

Train/evaluate the context-priority classifier using public datasets and explicit S6-derived weak labels or curated labels. Where HotpotQA supporting facts are used, preserve the distinction between dataset evidence and S6 semantic labels.

### Anuka

Train/evaluate trigger classification using public instruction/constraint-oriented datasets plus S6-specific examples. Keep weakly supervised labels clearly marked.

### Compression

Train/evaluate the learned relevance/attention component against supporting-sentence or relevance signals. Report train, validation and held-out test metrics separately.

### Required artifact record

Every training run should record:

- dataset name/configuration/version;
- source/license information;
- preprocessing version;
- label-generation method;
- train/validation/test counts;
- random seed;
- model architecture;
- hyperparameters;
- metrics;
- artifact checksum;
- training commit SHA.

**Do not claim trained-weight completion until the CI workflow actually produces and stores the artifacts.**

## Phase H — Runtime learned-model integration

After artifacts exist:

1. Load the trained artifact through a versioned model loader.
2. Run Dharen and Anuka inference on real S6 ContextInput objects.
3. Keep deterministic firewall/scope gates authoritative.
4. Emit model version and prediction metadata into telemetry.
5. Compare learned predictions against deterministic decisions.
6. Add regression tests for model-unavailable and model-mismatch cases.

## Phase I — End-to-end browser demonstration

The final demonstration should show one continuous workflow:

```text
S5 FOUNDATION
   ↓
DHAREN BASELINE
   ↓
CONTEXT FRAME
   ↓
ANUKA TRIGGER
   ↓
ADAPTIVE STATE
   ↓
CREATE SANDBOX
   ↓
POPULATE FORK
   ↓
PARALLEL REPLAY / SHADOW RUN
   ↓
INSPECT + COMPARE
   ↓
PROMOTE OR DISCARD
   ↓
CHECKPOINT
   ↓
HANDOFF TO DOWNSTREAM CHARACTERS
```

The UI should make clear which values are authoritative state, which are fork-local variables, and which values are presentation telemetry.

## Phase J — Documentation maintenance

Maintain these documents as the source of engineering truth:

- `docs/sprints/S6-CLOSURE-2026-09-12.md` — current S6 closure and honest verification state.
- `docs/implementation/S6-ACTION-PLAN.md` — execution and validation plan.
- `docs/architecture/` — architectural contracts and boundaries.
- `docs/research/` — research-derived evidence and dataset records.
- `docs/characters/` — character society and interaction semantics.
- `docs/adr/` — durable architectural decisions.

When implementation and documentation disagree, update the documentation only after verifying the actual implementation and its tests. Never convert an intended future state into a completed-state claim merely because a UI control or code stub exists.

## Immediate next work after merge

1. Verify merged-main CI.
2. Generate and retain actual public-data ML training artifacts.
3. Verify runtime inference against those artifacts.
4. Run the complete sandbox parallelism and promote/discard acceptance suite.
5. Run the browser recovery/revision suite.
6. Capture evidence and update S6 closure checkboxes with actual results.
7. Begin S7 only after the S6 boundary is stable and its evidence is recorded.
