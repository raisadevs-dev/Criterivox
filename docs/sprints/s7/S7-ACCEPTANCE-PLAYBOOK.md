# Criterivox S7 — Reasoning Research Bureau End-to-End Acceptance Playbook

## Purpose

This document defines the concrete inputs, datasets, interaction scenarios, expected observations, and evidence to collect when accepting the standalone S7 Reasoning Research Bureau.

It is an acceptance playbook, not a claim that a dataset proves reasoning quality. External datasets are fixtures for exercising the computational boundary. Any scientific or empirical claim requires appropriate evidence and is not inferred from a successful UI run.

## Runtime contract

Start from the repository root on `reasoning-research-bureau` with:

```powershell
.\start-s7-reasoning-research-bureau.ps1
```

Expected default endpoints:

- Presentation: `http://127.0.0.1:8018`
- Backend health: `http://127.0.0.1:8017/health`
- S7 API: `http://127.0.0.1:8017/api/s7`
- WebSocket control preflight: `ws://127.0.0.1:8017/api/s7/ws`

The launcher is the runtime supervisor. The S7 backend remains authoritative for analytical state.

## 1. What the Bureau expects as input

### Minimum accepted task

A non-empty analytical task/question. Examples:

- `Compare these two hypotheses and identify what evidence would distinguish them.`
- `Evaluate whether the supplied observations support the proposed conclusion.`
- `Explore alternative explanations for the observed pattern.`

### Context

The current S7 implementation expects structured context as a JSON object. For acceptance, provide context containing explicit facts, observations, constraints, or source records. Do not rely on hidden application state.

Example:

```json
{
  "facts": [
    "The observed value increased for three consecutive periods.",
    "The intervention occurred before the increase."
  ],
  "constraints": [
    "Do not infer causation from temporal order alone."
  ],
  "sources": [
    {"id": "fixture-01", "type": "synthetic", "location": "local"}
  ]
}
```

### Supported fixture forms

Use small, controlled fixtures first:

- JSON: preferred for structured facts, hypotheses, constraints, provenance, and event fixtures.
- CSV: preferred for tabular observations that can be transformed into structured context.
- Excel/XLSX: useful for multi-sheet observational fixtures; convert or load into the S7 input contract before analysis.
- Kaggle datasets: acceptable as external source material only after selecting a bounded, documented subset. Record dataset name/version, source URL, selected rows/columns, preprocessing, and license/usage notes.

S7 must not pretend that a raw CSV/XLSX/Kaggle file is automatically understood. The acceptance fixture must show the transformation from source data into the explicit context consumed by S7.

## 2. Recommended acceptance fixture pack

Create a local, reproducible fixture pack with:

```text
acceptance/fixtures/s7/
├── 01_minimal_context.json
├── 02_competing_hypotheses.json
├── 03_missing_context.json
├── 04_contradictory_context.json
├── 05_branch_challenge.json
├── 06_tabular_observations.csv
├── 07_multisheet_observations.xlsx
└── README.md
```

The fixture pack should remain small enough to inspect manually. Large Kaggle datasets are for research experiments, not for proving that the S7 boundary works.

## 3. Scenario matrix

| ID | Scenario | Input | Component/room | Expected response/evidence |
|---|---|---|---|---|
| S7-E01 | Minimal complete analysis | Task + structured facts | Collaboration | Session reaches `COMPLETED`; capability plan, reasoning, evaluation and result artifacts exist. |
| S7-E02 | Hypothesis exploration | Task asks for alternatives + context | Tarkis | Hypothesis artifacts/branches are visible; alternatives are bounded by supplied material. |
| S7-E03 | Critical evaluation | Claim + constraints/context | Vivren | Evaluation artifact exposes consistency/insufficiency findings and limitations. |
| S7-E04 | Insufficient information | Task with empty/absent context | Collaboration/Vivren | Session stops at `WAITING_FOR_INFORMATION`; missing information is explicit; no fabricated result exists. |
| S7-E05 | Human challenge | Completed session + challenge against an artifact | Collaboration | HUMAN_INTERVENTION/HUMAN_CHALLENGE event exists; a new branch is created; affected analysis is traceable. |
| S7-E06 | Competing hypotheses | Context containing multiple candidate explanations | Tarkis/Collaboration | Alternatives remain distinguishable and comparable; disagreement is not silently collapsed. |
| S7-E07 | Contradictory observations | Context containing explicit conflicting facts | Vivren | Conflict is surfaced as an evaluation finding/limitation; S7 does not manufacture a resolution. |
| S7-E08 | Provenance inspection | Context with source IDs | All rooms | Artifact lineage and source references remain inspectable. |
| S7-E09 | Version/branch inspection | Challenge/revision sequence | Tarkis/Collaboration | Original and challenged branch artifacts remain distinct; no overwrite. |
| S7-E10 | Standalone independence | Start S7 without Syvax/main shell | Standalone launcher | Backend and presentation start without importing/starting Syvax; `/health` reports standalone status. |

## 4. Exact interaction examples

### E01 — Complete analytical cycle

**Input**

Task:
`Evaluate whether the supplied observations justify the conclusion that the intervention caused the observed increase.`

Context:

```json
{
  "observations": [
    {"period": "P1", "value": 10},
    {"period": "P2", "value": 12},
    {"period": "P3", "value": 15}
  ],
  "intervention": {"period": "P2"},
  "constraints": ["Temporal ordering alone is insufficient to establish causation."],
  "sources": ["fixture-causal-01"]
}
```

**Interaction**

1. Open Collaboration.
2. Submit the task/context.
3. Inspect the capability plan.
4. Open the reasoning artifact.
5. Open evaluation and limitation artifacts.
6. Inspect the final result and provenance.

**Expected**

The result must preserve the distinction between observed temporal association and established causation. The acceptance criterion is inspectable computation and bounded claims, not a predetermined scientific answer.

### E02 — Hypothesis exploration

**Input**

Task:
`Explore alternative explanations for why the observed value increased after the intervention.`

Context:

```json
{
  "observations": ["value increased after intervention"],
  "known_factors": ["seasonality not measured", "measurement procedure changed"],
  "sources": ["fixture-hypothesis-01"]
}
```

**Interaction**

1. Enter Tarkis Room.
2. Run the task from Collaboration or the S7 entry surface.
3. Inspect hypothesis artifacts.
4. Compare alternative paths.
5. Return to Collaboration and inspect shared artifacts.

**Expected**

Alternative hypotheses must be represented as explicit artifacts, not as decorative graph nodes. Their bounded nature and missing evidence remain visible.

### E03 — Critical evaluation

**Input**

Task:
`Check the supplied argument for unsupported assumptions and contradictions.`

Context:

```json
{
  "argument": "The value increased after the intervention, therefore the intervention caused the increase.",
  "constraints": ["Identify assumptions before accepting causation."],
  "sources": ["fixture-critical-01"]
}
```

**Interaction**

1. Open Vivren Room.
2. Inspect the evaluation artifact.
3. Open limitations.
4. Challenge the relevant artifact.

**Expected**

The system should expose the unsupported causal leap/insufficient evidence as an evaluation limitation. A challenge should alter the analytical history rather than only produce a toast message.

### E04 — Insufficient information

**Input**

Task:
`Determine whether the proposed conclusion is externally true.`

Context:

```json
{}
```

**Expected**

`WAITING_FOR_INFORMATION`, explicit missing-information state, no final result. The correct behavior is to stop rather than fabricate evidence.

### E05 — Human challenge and branch

**Input**

Start with E01. Then challenge the evaluation artifact:
`The analysis ignored the measurement-method change. Re-evaluate the conclusion with that context.`

**Expected**

A HUMAN_INTERVENTION artifact and challenge event are recorded. A new branch is created and the continuation references the challenged artifact. The updated computation must remain distinguishable from the original branch.

## 5. Dataset guidance

### Small controlled datasets

For initial acceptance, use datasets with obvious semantics:

1. **Synthetic causal/time-series CSV**: period, intervention flag, observed value, measurement method.
2. **Survey/response JSON**: question, response, source, category, timestamp.
3. **Classification CSV**: record ID, features, label, source.
4. **Evidence comparison JSON**: claim, evidence item, source, support/contradiction metadata.
5. **Multi-sheet XLSX**: observations, metadata, source registry.

### Kaggle

Kaggle is optional and should be used only for bounded research fixtures. Do not select a dataset merely because it is large. For every imported dataset, preserve:

- dataset title and version/date
- source URL
- selected files/columns/rows
- transformation script or documented transformation
- license/usage information
- missing-value handling
- known limitations
- provenance identifier inside the S7 context

The acceptance question is: **Can S7 truthfully trace what was supplied to what it produced?** It is not: **Can S7 consume every Kaggle dataset automatically?**

## 6. Room-by-room interaction map

### Collaboration Room

Use for:
- submit task/context
- inspect active session
- inspect shared artifacts
- compare perspectives
- challenge an artifact
- inspect limitations and results

Expected observable outputs:
- session status
- capability plan
- artifacts/events
- branch information
- human intervention history
- result/limitations

### Vivren Room

Use for:
- inspect evaluations
- inspect assumptions/defects
- inspect insufficient-context findings
- challenge critical findings

Expected observable outputs:
- evaluation artifacts
- limitations
- objections/challenges
- provenance and lineage

### Tarkis Room

Use for:
- inspect hypotheses
- inspect alternatives
- inspect reasoning paths
- inspect branches/refinement

Expected observable outputs:
- hypothesis artifacts
- reasoning artifacts
- branch/version relationships
- comparison/refinement history

Characters are presentation identities. They are not the computational engines.

## 7. Evidence checklist

For each acceptance run, capture:

1. Input fixture file and exact task.
2. Runtime launcher log.
3. Backend stdout/stderr logs.
4. Flutter stdout/stderr logs.
5. `/health` response.
6. Session response/snapshot.
7. Artifact IDs and kinds.
8. Event IDs and event types.
9. Branch/version identifiers.
10. Provenance/source identifiers.
11. Screenshot or screen recording of Collaboration.
12. Screenshot of Vivren inspection.
13. Screenshot of Tarkis exploration.
14. Screenshot before and after human challenge.
15. Evidence that insufficient information produced no result.
16. Any incident directory created by the launcher.

## 8. Acceptance report template

For every scenario record:

```text
Scenario ID:
Date/time:
Commit:
Branch:
Input fixture:
Task:
Context:
Expected behavior:
Observed behavior:
Artifacts produced:
Events produced:
Branch/version changes:
Human intervention:
Provenance evidence:
Limitations:
PASS / PARTIAL / FAIL:
Notes:
```

## 9. What counts as PASS

S7 passes an end-to-end scenario only when the observed behavior matches the architectural contract: computation produces inspectable artifacts/events/state; the UI derives from that state; uncertainty/insufficient information is preserved; human intervention changes analytical history; branches do not overwrite prior truth; and the standalone runtime operates without Syvax.

A visually impressive screen without corresponding authoritative computational evidence is not a pass.

A successful HTTP request without inspectable artifacts/events is not a pass.

A generated answer unsupported by supplied information is a failure, even if the answer sounds plausible.

## 10. Current implementation limitation to resolve

The launcher verifies `ws://127.0.0.1:<port>/api/s7/ws`, while the S7 API must actually expose that WebSocket endpoint for the launcher to pass its control-channel preflight. This playbook therefore treats WebSocket reachability as a mandatory runtime acceptance condition rather than silently weakening the launcher.
