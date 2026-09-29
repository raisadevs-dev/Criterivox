# Criterivox S5 ML Decision Record — 2026-09-11

## Locked user decisions

- Model ambition: **E — progressive architecture**: classical ML baseline → advanced tabular ML → hybrid ML + agent/LLM only when evidence requires it.
- Compute: browser-hosted execution is the target presentation/deployment surface; inference/training remains local to the user's environment rather than requiring a remote ML service.
- Maximum inference time: **30–250 seconds**, treated as a UX budget rather than a model-quality threshold.
- Expected dataset size: **<200 MB per working dataset/package**.
- Expected concurrency: **5–8 users**.
- Training: **inside Criterivox**.
- Privacy: user data is not used for training if the user explicitly disables/denies that option. Default behavior should be opt-in/explicit consent for training use, with provenance of the consent decision.
- Kaggle: **external test-only references**, also tracked in a research-data workspace. Kaggle data is not automatically copied into Git.
- Cost constraint: benchmark selection must prioritize resources that are free of direct monetary cost; license/terms still have to permit the intended research use.

## Runtime architecture decision

Browser is the product surface, not the training algorithm. The ML runtime must therefore be capability-detected:

```text
Browser UI
   ↓
Local ML runtime adapter
   ├─ preferred: browser-capable local inference/training
   └─ fallback: local application runtime when browser ML is unavailable
   ↓
Sandre / Kaelen models
   ↓
existing DataFoundation contracts
```

Do not promise GPU acceleration on every browser/device. Detect capability and expose a clear runtime status. The 30–250 second budget permits background/progressive execution and progress telemetry.

## Evaluation decision: global-search findings

### ReTabAD
ICLR 2026 establishes semantic context as important to tabular anomaly detection and provides 20 tabular datasets enriched with structured textual metadata. This directly supports Sandre's Semantic Inspector and semantic-aware anomaly research. It is a primary research benchmark, not a claim that one algorithm is optimal.

### TABARD
EMNLP/Findings 2025 provides paired clean/corrupted tables over eight anomaly classes: value, factual, logical, temporal, calculation, security, normalization, and consistency. Its public repository includes anomaly-generation code and evaluation utilities. It is therefore useful both as an external benchmark and as evidence for the controlled-corruption strategy.

### Kaggle Data Cleaning
The 2026 competition contains realistic missing values, inconsistent labels, corrupted numeric fields and duplicate records. It is designated as external test/reference material only for Criterivox.

## Empirical threshold policy

No universal 85% threshold is adopted. The following starting policy is locked instead:

1. Build a validation corpus with clean and controlled-corruption cases.
2. Measure Sandre's anomaly probability calibration and error costs.
3. Select operating thresholds on validation data only.
4. Lock them before final test evaluation.
5. Report threshold, precision, recall, false-quarantine rate, missed-critical-anomaly rate and calibration.
6. Preserve a final untouched audit set.

For the initial implementation, use **0.85 as a provisional alert threshold only for UI prototyping**, clearly marked `PROVISIONAL`, and do not use it as a scientific result.

For binary quality gates, prefer a cost-sensitive policy rather than a fixed percentage:

```text
risk = P(critical anomaly | evidence)
expected_cost(pass) = risk × cost_of_missed_anomaly
expected_cost(review) = review_cost
expected_cost(quarantine) = quarantine_cost
choose lowest expected cost subject to safety constraints
```

The exact costs remain experiment configuration until empirical study is complete.

## Dataset roles

| Dataset family | Sandre | Kaelen | Role |
|---|---:|---:|---|
| ReTabAD | Primary | Secondary | semantic anomaly benchmark |
| TABARD | Primary | Secondary | fine-grained anomaly + controlled perturbation |
| ADBench selected tabular sets | Primary | No | cross-domain anomaly robustness |
| Table-GPT | Secondary | Primary | schema/transformation/error tasks |
| TabFix/tabular-errors-v1 | Secondary | Primary | error repair |
| Kaggle Data Cleaning | No training | No training | external test/reference |
| Synthetic Criterivox corruption suite | Primary | Primary | controlled train/validation data |

## License/cost rule

A dataset is eligible for the final benchmark only if:

- no direct monetary payment is required for the planned research use;
- license/terms permit the planned use;
- source and version can be recorded;
- provenance and checksum can be recorded;
- test-only material is kept outside training;
- redistribution into the repository is performed only when explicitly permitted.

## Remaining user decisions / evidence gaps

1. Exact browser ML runtime library is still an implementation decision; choose after compatibility testing rather than assuming universal WebGPU.
2. Exact model family after baseline remains empirical.
3. Exact false-positive/false-negative monetary or operational costs are not supplied and remain configuration variables.
4. Exact benchmark versions and downloadable subsets must be frozen at acquisition time.
5. Kaggle competition terms should be rechecked at acquisition time.
6. User-consent UX wording for training-data opt-in needs final product/legal review.
7. A production-ready browser training pipeline should be added only after a small benchmark proves that the selected model fits the <200 MB and 30–250 second budgets.
