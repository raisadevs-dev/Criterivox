# S6 learned-model training manifest

The checked-in artifacts are bootstrap learned models trained from the explicit role/action examples below. They are intentionally small and local so the runtime can exercise the learned path without inventing empirical thresholds.

| Model | Character | Algorithm | Classes | Examples |
|---|---|---|---|---:|
| sandre | Sandre | Multinomial Naive Bayes | ready/review/quarantine | 6 |
| kaelen | Kaelen | Multinomial Naive Bayes | no_change/schema_extension/schema_reduction_review/schema_mapping_review/type_repair | 9 |
| dharen | Dharen | Multinomial Naive Bayes | critical/high/medium/low | 8 |
| anuka | Anuka | Multinomial Naive Bayes | stable/requirements_changed/evidence_changed/constraint_changed/drift_detected/counterfactual_requested | 12 |

These are implementation bootstrap models. They are not a substitute for later S6 evaluation/training against validated research datasets. No production performance threshold is inferred from these examples.
