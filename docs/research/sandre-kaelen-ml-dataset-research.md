# Criterivox S5 — Sandre + Kaelen ML/Agent Dataset Research

**Branch:** `s5-data-foundation`  
**Status:** implementation decision record, 2026-09-11  
**Scope:** preserve the existing S5 data foundation and add ML/agent capabilities for Sandre and Kaelen.

## 1. Scope decision

For this branch, **Sandre and Kaelen are intentionally treated as ML modules and AI-agent interfaces**. Existing S5 storage, provenance, confirmation, profiling, quality metadata, anomaly records, transformations, and handoff contracts remain the system-of-record boundary. The ML layer augments those contracts; it does not replace them.

The runtime shape is:

```text
Incoming material
      ↓
S5 DataFoundationStore
      ↓
Sandre ML Agent
  ├─ quality features
  ├─ anomaly detection
  ├─ drift / readiness signal
  └─ provenance-aware decision
      ↓
validated foundation
      ↓
Kaelen ML Agent
  ├─ schema-diff classification
  ├─ transformation recommendation
  ├─ repair confidence
  └─ transformation plan
      ↓
canonical / transformed package
      ↓
Dharen handoff
```

## 2. Research-derived capability map

| Agent | ML problem | Training data | Validation data | External benchmark/test material |
|---|---|---|---|---|
| Sandre | row/table anomaly detection and quality-risk scoring | clean tables + injected labeled quality faults; ReTabAD/TABARD-derived training subsets | held-out domains + synthetic corruption suites | ReTabAD, TABARD, ADBench, Kaggle Data Cleaning |
| Sandre | missingness/duplicate/schema-risk classification | corrupted-vs-clean table pairs | unseen corruption combinations | Kaggle Data Cleaning; Kaggle TSS Pandas Challenge #2 |
| Sandre | semantic-aware anomaly detection | metadata-enriched tables | domain-held-out tables | ReTabAD |
| Kaelen | schema-change classification | generated schema-diff pairs + Table-GPT transformation tasks | unseen schema structures | Microsoft Table-GPT |
| Kaelen | error detection / repair recommendation | clean/corrupt paired tables | held-out error families | TabFix / `tabular-errors-v1`, TABARD |
| Kaelen | transformation-plan generation | synthetic declarative transformation pairs | unseen combinations and multi-step plans | Table-GPT R2R/SM/ED/DI tasks |
| Both | agent repeatability / pipeline task evaluation | controlled task suite | repeated-run holdout | EDA Benchmark |

## 3. Dataset families selected

### A. ReTabAD — primary Sandre benchmark

ReTabAD is an ICLR 2026 benchmark containing 20 tabular datasets with semantic metadata, logical types, descriptions, normal/anomalous examples and anomaly labels. It is particularly valuable because Sandre's proposed semantic inspector should not treat anomalies as purely numeric events.

Use:
- **train:** a subset of datasets selected by domain and schema shape;
- **validation:** different datasets/domains, not random rows from the same table;
- **test:** untouched datasets and repeated seeds;
- **evaluation:** AUROC/AUPRC, precision/recall/F1, calibration, false-block rate, and explanation usefulness.

Source: https://github.com/yoonsanghyu/ReTabAD

### B. TABARD — fine-grained anomaly benchmark

TABARD provides labeled anomalies across value, factual, logical, temporal, calculation, security, normalization and consistency categories, with aligned clean/perturbed/yes-no representations.

Use primarily for **Sandre test and stress evaluation**, plus Kaelen error-repair evaluation. Do not leak anomaly markers or labels into features.

Source: https://github.com/TABARD-emnlp-2025/TABARD-dataset

### C. ADBench / ADRepository — broad anomaly coverage

ADBench provides a broad collection for tabular anomaly detection, while the ADBenchmarks repository packages real-world anomaly datasets across modalities. Use selected tabular datasets for cross-domain robustness and model-family comparison.

Sources:
- https://github.com/Minqi824/ADBench
- https://github.com/mala-lab/ADBenchmarks-anomaly-detection-datasets

### D. Microsoft Table-GPT — primary Kaelen transformation benchmark

Table-GPT includes train/test tasks for row transformation, entity matching, schema matching, data imputation and error detection. These tasks map directly to Kaelen's transformation-studio responsibilities.

Use:
- schema matching for drift mapping;
- row-to-row transformation for transformation planning;
- imputation and error detection for repair proposals;
- held-out test split for evaluation.

Source: https://github.com/microsoft/Table-GPT

### E. TabFix / tabular-errors-v1 — repair benchmark

The TabFix dataset pairs clean and corrupt tabular representations with explicit repair information and hard negatives. It is useful for training/evaluating Kaelen's error-family classification and repair recommendation layer. The dataset card must be checked at acquisition time for license and split details before redistribution.

Source: https://huggingface.co/datasets/Antix5/tabular-errors-v1

### F. Kaggle Data Cleaning — practical quality suite

The 2026 Kaggle Data Cleaning competition explicitly includes missing values, inconsistent labels, corrupted numeric fields and duplicate records. Use it as an **external practical test set**, subject to Kaggle competition rules and access terms. Do not commit Kaggle data into the repository unless its terms permit redistribution.

Source: https://www.kaggle.com/competitions/data-cleaning

### G. Kaggle TSS Pandas Challenge #2 — deterministic quality cases

This challenge contains missing values, duplicate rows, inconsistent text formatting, merging and date handling. It is useful as a small human-auditable regression suite for Sandre's profiling/remediation behavior.

Source: https://www.kaggle.com/competitions/tss-pandas-challenge-2

### H. EDA Benchmark — agent evaluation

The EDA Benchmark is useful for measuring analytical quality and repeatability rather than only one-shot accuracy. It should be used as a later agent-level evaluation suite, not as Sandre's primary supervised training source.

Source: https://github.com/deepsense-ai/eda-benchmark

## 4. Train / validation / test policy

Avoid random row splitting as the only evaluation method. For Criterivox, the important generalization unit is **dataset/domain/schema**, not merely the row.

Recommended hierarchy:

```text
TRAIN
  └─ source datasets + generated corruptions

VALIDATION
  └─ unseen corruption combinations
  └─ unseen schemas from familiar domains

TEST
  └─ held-out datasets/domains
  └─ external benchmark datasets

FINAL AUDIT
  └─ Kaggle/benchmark material not used for model fitting
  └─ adversarial edge cases
  └─ provenance/PII/security tests
```

For repeated measurements, use fixed seeds and report confidence intervals. Keep a final untouched audit set that is never used for model selection.

## 5. Synthetic data is required, but not a replacement for real benchmarks

Criterivox needs controlled corruption generators because some S5 requirements need labels that public datasets do not consistently provide. Generate paired clean/corrupt examples for:

- missing required field;
- missing optional field;
- duplicate row;
- duplicate identifier;
- type change;
- renamed field;
- field addition/removal;
- categorical spelling/normalization error;
- numeric outlier;
- impossible date/order;
- distribution shift;
- unit mismatch;
- malformed JSON/schema;
- injected instruction-like text in a data field;
- conflicting semantic metadata.

Every synthetic mutation must retain a mutation manifest containing source hash, mutation type, affected field(s), seed, before/after schema fingerprints and expected remediation.

## 6. Metrics

### Sandre
- anomaly AUROC and AUPRC;
- precision, recall and F1 at selected operating points;
- false quarantine rate;
- missed-critical-anomaly rate;
- calibration / Brier score where probabilistic output is used;
- schema-drift detection precision/recall;
- duplicate detection accuracy;
- missingness classification accuracy;
- quality-score stability across repeated runs.

### Kaelen
- schema-drift classification accuracy/F1;
- transformation action accuracy;
- repair exact-match rate;
- repair validity rate after applying the proposed transformation;
- downstream schema compatibility;
- idempotence where expected;
- rollback success;
- confidence calibration;
- repeated-run consistency.

### Agent-level
- task success;
- repeatability;
- unsafe/unsupported action rate;
- provenance completeness;
- human override rate;
- time/compute cost;
- blast-radius containment.

## 7. Important threshold decision

The proposed **85% Data Quality Indicator warning threshold is kept as a product configuration default, not an empirical truth**. It must be tuned against validation data later. The research package should never present 85% as a universally established scientific threshold.

Likewise, anomaly and drift thresholds remain configurable until empirical calibration is complete.

## 8. Privacy and licensing decision

Public datasets are **references and evaluation inputs**, not automatically redistributable repository assets. Criterivox should store a dataset registry with source URL, license, checksum/version, intended use, split role, and acquisition instructions. Only small synthetic fixtures and data explicitly permitted for redistribution should be committed to Git.

## 9. Current implementation decision

Implement the first ML layer with interpretable, low-dependency tabular baselines:

- Sandre: Isolation Forest over a provenance-safe feature representation, wrapped as an agent with explicit `train/predict/evaluate` operations.
- Kaelen: a supervised schema-change/action classifier over explicit schema-diff features, wrapped as an agent producing a declarative transformation proposal.

These are **baseline ML agents**, not claims of production-optimal models. The architecture must permit later replacement by gradient boosting, deep tabular models, embedding models or LLM/tool agents without changing the S5 data contract.

## 10. Research status

**Decided now:** architecture, dataset families, split philosophy, metrics, licensing policy, baseline model classes, synthetic corruption taxonomy, and 85% threshold treatment.

**Still requires user/research decision:** exact production model family, final benchmark subset, target deployment hardware/latency, privacy policy for user data, acceptable false-quarantine cost, and final empirical thresholds.
