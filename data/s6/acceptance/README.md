# Criterivox S6 Dataset Protocol

These datasets are deliberately small, inspectable acceptance fixtures, not demo data and not ML training weights.

## Train / validation / test

- `train_context_cases.csv`: known structural/context patterns used to exercise deterministic context construction.
- `validation_context_cases.csv`: held-out combinations used during implementation validation.
- `test_context_cases.csv`: user-facing acceptance cases for checking the Context Workspace.

## User acceptance datasets

- `01_cross_platform_context.csv`: same content idea under different platform, audience and period context.
- `02_context_shift_and_memory.csv`: changing context plus explicit stale-memory/recheck reasons.
- `03_missing_and_uncertain_context.csv`: missing, unknown, unmeasured and unsupported fields that must not become zero or false certainty.
- `04_provenance_and_handoff.csv`: multi-source lineage and explicit handoff-oriented context records.

## Unseen-data checks

- `unseen_01_schema_variation.csv`: unfamiliar but valid field combinations.
- `unseen_02_sparse_context.csv`: sparse observations with missing contextual dimensions.
- `unseen_03_temporal_shift.csv`: a new time period and changed environmental conditions.

Unseen datasets are not used to tune thresholds. They are reserved for generalization checks after implementation changes.

## Provenance

The cases are Criterivox-generated synthetic acceptance data, designed from the finalized S6 research requirements. Public Kaggle datasets were reviewed for contextual/recommender patterns, but their schemas and licensing/competition constraints do not by themselves establish Criterivox's research semantics. Relevant public references include Kaggle's context-aware recommender material and recommendation challenges. See the project research package for the authoritative S6 evidence/decision record.
