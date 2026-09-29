# S5 Evaluation Dataset Registry

## Purpose

Evaluation inputs are external references or locally acquired under their licenses. They are not copied into Git by default. Training and evaluation execute locally inside Criterivox.

## Registry

| Family | Role | Acquisition | Required tracking |
|---|---|---|---|
| OpenML benchmark suites | cross-dataset training/evaluation reference | OpenML task/dataset API | dataset/task ID, version, license, checksum, split |
| OpenML-CC18 | standardized tabular benchmark reference | OpenML | task IDs, split, version, checksum |
| TABARD | tabular error/anomaly evaluation | project/repository source | release/version, license, checksum, anomaly taxonomy |
| ReTabAD | semantic-context anomaly evaluation reference | publication/project source | dataset/version, license, enrichment metadata |
| Kaggle Data Cleaning challenge families | external robustness/reference tests | Kaggle | competition/dataset URL, license/terms, version |
| Criterivox synthetic corruption fixtures | committed deterministic test data | generated locally | generator version, seed, corruption class |

## Gate protocol

1. Train only on datasets explicitly assigned the `train` role.
2. Keep validation data separate from model-fitting rows.
3. Reserve test datasets for final evaluation and threshold calibration.
4. Run completeness, schema alignment, anomaly review, provenance, semantic readability, and output-stability checks.
5. The existing 0.85 readiness value is a **provisional engineering gate**, not a scientific truth.
6. Thresholds must be recalibrated from aggregate benchmark results and actual Criterivox runs before being treated as empirical.
7. Any dataset with incompatible terms, unclear provenance, or unverifiable versioning is excluded from automated acquisition.

## Runtime constraints

- Local training and inference.
- Working dataset target: under 200 MB.
- Browser/local-first product surface.
- Explicit consent controls whether user material can be used for training.
- No automatic upload of user material to public benchmark services.

## External evidence

OpenML benchmark suites provide standardized train/test splits and machine-readable metadata, which makes them appropriate for reproducible cross-dataset evaluation. Criterivox should store registry metadata and acquisition instructions rather than committing third-party datasets by default.
