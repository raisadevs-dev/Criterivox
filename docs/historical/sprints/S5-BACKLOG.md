# S5 — DATA FOUNDATION + CHARACTER AUTHORING

**Status:** Planned  
**Baseline:** S4 Domain Analysis Workspace  
**Sprint goal:** Establish the first durable data foundation for Criterivox while completing the production-ready character artwork pipeline required by the existing runtime.

## 1. Sprint Objective

S5 establishes the data foundation that later intelligence and context services will consume. It also completes the vector character authoring work that is already required by the presentation/runtime boundary.

The sprint must preserve the architecture:

```text
DATA → CONTEXT → INTELLIGENCE → EXPLANATION → HUMAN CHALLENGE → HYPOTHESIS → EXPERIMENT → EVIDENCE → KNOWLEDGE → CONTEXT-CONDITIONED REUSE / TRANSFER
```

S5 is **not** the Context Engine. Context modeling and context reasoning belong to S6.

## 2. Mandatory S5 Backlog

### S5-01 — Dataset ingestion foundation
- Define an input-neutral ingestion boundary.
- Accept synthetic/local datasets through a validated application/domain boundary.
- Support structured tabular input and a clear internal representation.
- Reject malformed, oversized, or unsupported input safely.
- Preserve source identity and ingestion metadata.
- Add automated tests for valid and invalid ingestion.

### S5-02 — Contextual information capture
- Define the data model for creator/user-provided contextual information that accompanies a dataset.
- Separate supplied context from system-derived information.
- Preserve context provenance and timestamps.
- Do not implement S6 context reasoning yet.

### S5-03 — Derived information representation
- Define a representation for information derived from raw data.
- Clearly distinguish raw, supplied-context, and derived fields.
- Record derivation/provenance metadata.
- Keep derivation deterministic for the S5 prototype.

### S5-04 — Provenance model
- Every ingested dataset and derived field must be traceable to its source.
- Define source type, source identifier, creation/ingestion time, and derivation relationship.
- Ensure provenance survives movement from ingestion into the analysis task model.

### S5-05 — Missing-value semantics
- Define explicit missing-value states instead of silently converting missing values.
- Distinguish at minimum: missing, unavailable, not-applicable, and intentionally omitted where the representation requires it.
- Test serialization and analysis behavior for missing values.

### S5-06 — Validation and normalization
- Validate schema, field names, supported value types, and basic constraints.
- Normalize representation without destroying original source meaning.
- Produce structured validation errors suitable for the existing runtime/application boundary.
- Add tests for malformed and edge-case datasets.

### S5-07 — Canonical data representation
- Establish the domain-level representation consumed by downstream services.
- Keep presentation independent of the data model.
- Ensure the representation can later support multiple platforms and non-social-media datasets.

## 3. Mandatory Character Authoring Work

### S5-08 — Glaxnimate character authoring pipeline **MUST BE COMPLETED**

This is a mandatory S5 deliverable, not a deferred nice-to-have.

Characters in scope:
- **Dharen**
- **Syvax**

For each character, author/refine all six required visual states in Glaxnimate:

```text
IDLE
RECEIVE
WORK
COMMUNICATE
HANDOFF
COMPLETE
```

Required work:
- Refine the supplied character artwork as vector artwork in Glaxnimate.
- Establish clean layer/group structure suitable for animation editing.
- Create state-specific motion for all six states.
- Preserve consistent character identity across states.
- Keep animation meaning aligned with the semantic character-state vocabulary.
- Export production SVG assets for Flutter consumption.
- Keep Glaxnimate source/project files under the repository's character authoring area so the artwork remains editable and reproducible.
- Document the source-to-export relationship briefly in the character asset README.

### S5-09 — SVG state asset integration

For both Dharen and Syvax, the exported authoring result must map to:

```text
characters/
├── dharen/
│   ├── idle.svg
│   ├── receive.svg
│   ├── work.svg
│   ├── communicate.svg
│   ├── handoff.svg
│   └── complete.svg
└── syvax/
    ├── idle.svg
    ├── receive.svg
    ├── work.svg
    ├── communicate.svg
    ├── handoff.svg
    └── complete.svg
```

The existing six-frame sheets may remain as fallback assets, but the state-specific assets are the primary S5 authoring deliverable.

### S5-10 — Character runtime verification
- Verify Python semantic state remains authoritative.
- Verify each semantic state resolves to the correct character visual state.
- Verify Dharen and Syvax render independently.
- Verify no character artwork invents application state.
- Verify reduced-motion behavior remains accessible.
- Add/update tests for state-to-asset resolution.

## 4. S5 Integration / Quality

### S5-11 — Analysis-task data integration
- Connect the S5 canonical data representation to the existing Analysis Task boundary.
- Preserve task ID, source, context, references, provenance, and validation information.
- Ensure existing Workspace/Chat behavior does not regress.

### S5-12 — Error and recovery behavior
- Invalid dataset → structured validation feedback.
- Unsupported format → clear rejection.
- Missing required data → explicit missing-value/validation semantics.
- Invalid character state/asset → safe idle/fallback behavior.
- Asset loading failure must not crash the application shell.

### S5-13 — Accessibility and responsive validation
- Character state changes expose meaningful semantic labels.
- Reduced-motion behavior is respected.
- Data validation feedback is accessible.
- Character assets remain usable across supported viewport sizes.

### S5-14 — Automated verification
Required before Sprint 5 completion:
- Python tests pass.
- Flutter tests/analyzer pass.
- Data validation tests pass.
- Character state mapping tests pass.
- Runtime integration smoke test passes.
- No known regression in Bloom → Analysis Workspace → Dharen flow.

## 5. Documentation Required

- Update S5 architecture/data documentation.
- Update character asset documentation with Glaxnimate → SVG → Flutter pipeline.
- Record the canonical S5 data model and provenance semantics.
- Record explicit S5 non-scope and S6 handoff.
- Do not create duplicate or decorative documentation.

## 6. S5 Acceptance Criteria

Sprint 5 is complete only when:

- [ ] Local/synthetic datasets can be ingested through a validated boundary.
- [ ] Raw data, supplied context, and derived information are structurally distinct.
- [ ] Provenance is represented and preserved.
- [ ] Missing values have explicit semantics.
- [ ] Validation and normalization are tested.
- [ ] A canonical downstream data representation exists.
- [ ] Dharen has six Glaxnimate-authored/exported states.
- [ ] Syvax has six Glaxnimate-authored/exported states.
- [ ] Glaxnimate source files are committed to GitHub.
- [ ] Exported SVG state assets are committed to GitHub.
- [ ] Flutter resolves semantic character state to the correct visual asset.
- [ ] Python remains authoritative for semantic character state.
- [ ] Reduced-motion and accessibility behavior remain functional.
- [ ] Existing S4 runtime/application behavior remains intact.
- [ ] Automated verification passes.
- [ ] S5 documentation and S6 handoff are complete.

## 7. Explicit Non-Scope

S5 does **not** implement:

- S6 Context Engine reasoning/orchestration.
- Full intelligence/ML/LLM implementation.
- XAI engine.
- Social-media API integrations.
- Production database/authentication/synchronization unless separately promoted into a future sprint.
- Full 15-character ecosystem implementation.
- Advanced autonomous agent orchestration.

Character authoring is mandatory in S5 because it completes the existing presentation asset pipeline. It does not turn characters into independent AI agents.

## 8. S6 Handoff

S5 hands S6 a validated, provenance-aware canonical data foundation containing:

```text
RAW DATA
   ↓
SUPPLIED CONTEXT
   ↓
DERIVED INFORMATION
   ↓
PROVENANCE + VALIDATION + NORMALIZATION
   ↓
CANONICAL DATA REPRESENTATION
   ↓
S6 CONTEXT ENGINE
```

S5 also hands forward production-ready Dharen and Syvax vector assets whose visual states remain driven by the existing semantic character contract.
