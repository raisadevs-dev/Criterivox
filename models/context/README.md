# S6 learned-model registry

This directory contains four local learned classifiers used by the S5/S6 character agents:

- `sandre.json`: data-quality state classifier (`ready`, `review`, `quarantine`)
- `kaelen.json`: schema-action classifier (`no_change`, `schema_extension`, `schema_reduction_review`, `schema_mapping_review`, `type_repair`)
- `dharen.json`: context-tier classifier (`critical`, `high`, `medium`, `low`)
- `anuka.json`: context-adaptation trigger classifier (`stable`, `requirements_changed`, `evidence_changed`, `constraint_changed`, `drift_detected`, `counterfactual_requested`)

The artifacts use `criterivox.multinomial_nb.v1`, a small serialized multinomial Naive Bayes model. They are trained local bootstrap models, not claims of empirical production accuracy. Deterministic safety, schema-diff, and state-gating logic remains authoritative. The learned models provide ranked/advisory signals and are surfaced with model version and confidence for traceability.

The single runtime entry point is `src/criterivox/context/ml.py:S6LearnedModelRegistry`.
