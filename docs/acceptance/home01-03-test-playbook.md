# Criterivox S6 Home 01–03 Acceptance Test Playbook

This is the practical smoke/acceptance guide for the current `s6-home03-syvax-bloom-complete` branch. It is intentionally based on Criterivox's own interaction architecture, not academic benchmark questions.

## 1. What is actually trained?

Do not treat every CSV/JSONL file in `data/s6` as an ML training dataset. The repository contains three different kinds of material:

1. **Training/validation/test fixtures** for S6 context behavior.
2. **Acceptance/unseen fixtures** for regression and generalization checks.
3. **Human-facing interaction test materials** for exercising Syvax, Sandre, Dharen, Anuka, multimodal ingestion, routing, HITL, and Bloom behavior.

The existing S6 context training package is JSONL. Its records contain a case id, label, canonical data, source ids, supplied context, optional previous context/memory information, and expected structural outcomes. CSV is used extensively for inspectable acceptance fixtures. Therefore Criterivox is not tied to one dataset format.

## 2. Dataset formats currently used

| Purpose | Format | Why |
|---|---|---|
| S6 context training | JSONL | One structured case per line; easy to stream and diff |
| S6 acceptance cases | CSV | Human-inspectable tabular fixtures |
| S6 unseen cases | CSV | Controlled schema variation, sparse context, temporal shift |
| Evaluation/failure cases | JSONL | Structured expected outcomes and failure semantics |
| Runtime task plans | JSON/JSON-like payloads | Machine-readable routing/handoff contracts |
| Uploaded user material | Multimodal files | Syvax ingestion boundary must accept different material types |

The repository's S6 acceptance README explicitly classifies the acceptance fixtures as small, inspectable synthetic fixtures rather than ML weights, and separates train, validation, test, and unseen data. See `data/s6/acceptance/README.md`.

## 3. What you should test first when running Criterivox

Run the following in order. This is the shortest path from "the app opened" to "the architecture is actually behaving".

### Test A — Gate 1 and Home 03 visual/runtime smoke test

Open the Introduction / Criterivox Civilization side and enter Home 03.

Expected:
- Syvax is visibly present.
- The character is rendered by the current procedural/session animation stack, not a placeholder artwork message.
- The Bloom is visible.
- The Home 03 controls load without requiring a separate character page.
- Character state changes are reflected visually.
- Reduced-motion mode does not break rendering.

### Test B — Intent → routing

Ask:

> I am a content creator planning next month's campaign. I have audience notes and last month's performance data. Help me decide what to test next, and show me which Criterivox workers need to be involved.

Expected:
- Syvax extracts a task/goal rather than treating this as casual chat.
- A structured route/plan is produced.
- The routing view identifies downstream work instead of dumping raw internal logs.
- Context/data work can route toward Dharen and Sandre, with downstream reasoning selected as appropriate.
- The Bloom reflects participating homes.

### Test C — Adaptive output

Ask:

> Compare these three campaign options and present the result as a decision table with assumptions and evidence gaps.

Expected:
- Syvax chooses a structured output representation.
- The response exposes the available view modes where implemented: executive summary, reasoning/detail representation, and raw payload representation.
- Missing evidence remains visibly missing instead of being silently invented.

### Test D — Mid-flight steering

Start a task that routes through more than one worker. While it is active, use **Steer Execution** and enter:

> Change the target audience from new users to existing subscribers. Keep everything else unchanged.

Expected:
- Active execution pauses or enters its intervention state.
- The correction is represented as a state change/diff rather than starting an unrelated new conversation.
- Dharen/Anuka are the contextual adaptation targets.
- The revised route reflects the new constraint.
- Resume continues from the managed state.

### Test E — Multimodal reception

Upload one material at a time from `data/s6/interaction_acceptance/materials/`.

Expected for supported text/tabular payloads:
- File is accepted through the Universal Dropzone.
- Preview/type information appears.
- Syvax ingestion forwards the payload toward the Data Foundation path.
- The system does not pretend that an unsupported binary format was semantically understood merely because it was uploaded.
- Provenance/material identity is retained.

For every format, record whether the current branch **ingests**, **normalizes**, **extracts**, **routes**, or merely **stores/identifies** the material. These are different capabilities.

### Test F — Missing/uncertain context

Ask:

> Which campaign should we choose if the audience conversion rate is not available and the platform attribution is incomplete?

Expected:
- Missing values remain UNKNOWN/missing.
- The system does not turn missing data into zero.
- The output identifies what additional evidence would reduce uncertainty.
- Downstream reasoning is not presented as established fact when the input is incomplete.

### Test G — Context shift

First ask about a campaign for Instagram. Then steer/change it to YouTube while keeping the business goal unchanged.

Expected:
- A Context Diff is produced.
- The changed platform/environment is represented as a changed context dimension.
- Unchanged context remains available.
- Replanning occurs from the changed state rather than losing the entire prior task.

### Test H — Provenance/handoff

Use `04_provenance_and_handoff.csv` and inspect the resulting context/handoff information.

Expected:
- Source identity survives the workflow.
- Provenance/handoff information is inspectable.
- A transformation is not silently treated as an original source fact.

### Test I — Schema variation

Use `unseen_01_schema_variation.csv`.

Expected:
- The system handles unfamiliar but valid field combinations without requiring the exact training schema.
- It does not silently invent absent fields.
- The case is not used to tune thresholds during the test.

### Test J — Sparse and temporal shift

Use `unseen_02_sparse_context.csv`, then `unseen_03_temporal_shift.csv`.

Expected:
- Sparse context is treated as sparse.
- New periods/environmental conditions are represented as changed context.
- The system does not claim generalization merely because parsing succeeded.

## 4. Real Criterivox-style questions to ask

These are **intent tests**, not school exercises.

### Content / marketing
1. "I have last month's content performance and this month's audience goal. What should we test next, and what evidence is missing?"
2. "Compare these campaign options using the supplied audience and platform context. Separate observed facts from interpretation."
3. "The audience changed from existing subscribers to new users. Reframe the current task without throwing away the useful prior context."
4. "Build a decision brief from this CSV and tell me which claims cannot be supported by the supplied data."
5. "Show me the route Criterivox should take to answer this, and explain why each worker is involved."

### Research / analysis
6. "Here are notes from three sources. Identify where they agree, where they conflict, and what needs verification before I act."
7. "Use this document as context, but do not assume that an unmeasured field is zero."
8. "What changed between these two datasets, and which changes could affect the decision?"

### Team / decision support
9. "I need to choose between these two plans. Keep my hard constraints fixed and expose the trade-offs rather than making the decision invisible."
10. "Pause the current task. Add a requirement that no recommendation can rely on an unsupported claim. Then continue."

### Guardrail / ambiguity
11. "The supplied documents disagree about the target audience. Do not choose one silently. Identify the clash and tell me what must be resolved."
12. "This request is missing the time period. Build the context, but mark the period as unknown and tell me why it matters."

## 5. What materials to upload

Use a small controlled pack first. Do not begin with a giant random internet folder because humans apparently enjoy debugging five variables at once.

Recommended first-run pack:
- one CSV with campaign/content metrics;
- one JSON file with audience/context metadata;
- one Markdown/TXT brief describing the goal and constraints;
- one second document containing a conflicting or updated context statement;
- one small SVG/image asset to test file identification/preview if the UI supports it;
- optionally one HTML/text export representing a web/content artifact.

The material should be **synthetic or user-owned** for repository tests. Do not commit private personal data or copyrighted third-party documents merely to make a test fixture look realistic.

## 6. Where materials should come from

### For repository acceptance tests
Generate small synthetic fixtures from the Criterivox research requirements. This is the preferred source because the expected outcome is known and reproducible.

### For external realism tests
Use:
- your own campaign/content analytics exports;
- your own anonymized briefs and notes;
- public datasets whose license permits the intended use;
- public-domain or openly licensed documents/images;
- synthetic documents deliberately created to contain missing fields, schema changes, conflicting context, and temporal changes.

External material is useful for realism, but it must not silently become a new research ground truth. Licensing and provenance must remain explicit.

## 7. What should NOT be committed to the repository

Do not add:
- private customer/creator data;
- personal identifiers;
- credentials or API exports containing secrets;
- copyrighted question papers/articles merely because they are convenient test data;
- huge production datasets;
- undocumented benchmark data with unclear licensing.

Commit the **small synthetic fixture and its provenance/expected behavior**, not someone's entire real data lake.

## 8. Current implementation status

### Strongly represented in the current branch
- S5 → S6 data/context architecture.
- JSONL training/evaluation fixtures.
- CSV acceptance/unseen context fixtures.
- Syvax plan/dispatch/replan/steering surfaces.
- Universal Dropzone ingestion path.
- Bloom checkpoint/replay/budget/trace surfaces.
- Character visual/session animation system.
- Centralized `CharacterVisualProfile` identity source.

### Must be verified by an actual running app, not inferred from source
- End-to-end visual behavior of every Home 03 control.
- Actual browser file-picker/dropzone behavior for each supported media type.
- Live telemetry timing and smoothness.
- Real camera/portal preview behavior.
- Actual backend-to-Bloom live state synchronization.
- Full multimodal semantic extraction for image/audio/document formats.
- Production-quality model accuracy.

### Important distinction
A successful upload is **not** proof of semantic multimodal understanding. A route being generated is **not** proof that every downstream character executed a real computation. A visual animation is **not** proof that telemetry is correctly driving it. Acceptance testing must check each boundary separately.

## 9. Pass criteria for the first human-run acceptance session

A first run is functionally convincing when all of these are observable:

- [ ] Gate 1 opens and exposes the AI civilization.
- [ ] Home 03 opens with Syvax + Bloom.
- [ ] A natural task becomes an explicit route.
- [ ] The route can be inspected without raw-log overload.
- [ ] Syvax can be steered mid-flight.
- [ ] Context changes produce a meaningful diff/replan.
- [ ] At least CSV + JSON + text/Markdown materials are ingested.
- [ ] Source/material identity remains traceable.
- [ ] Missing/uncertain values remain explicit.
- [ ] At least one provenance/handoff case can be inspected.
- [ ] Bloom state changes when work is active.
- [ ] Character state changes are visible.
- [ ] Checkpoint/replay behavior can be exercised.
- [ ] An unseen schema/sparse/temporal case does not require hard-coded training examples.
- [ ] No unsupported claim is presented as an established measurement.

This playbook deliberately distinguishes **implemented**, **observable**, and **not-yet-proven** behavior. Passing the UI smoke test is not the same thing as proving the research system.
