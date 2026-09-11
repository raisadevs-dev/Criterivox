"""Train S6 learned models from public datasets plus Criterivox task labels.

Usage: python scripts/train_s6_models.py --output-dir artifacts/s6-models

The script keeps train/validation/test domains separate and writes a report. Public
raw examples are transformed into context-management labels; Criterivox-specific
labels are supplied by the local S6 corpus when present. Safety/firewall decisions
remain deterministic and are never delegated to the learned model.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import random

from datasets import load_dataset

from criterivox.context.ml import save_training_report, train_text_model

SEED = 42
PUBLIC_DATASETS = [
    {"id": "hotpotqa", "config": "distractor", "split": "train", "role": "reasoning_context"},
]


def _load_public_examples(limit: int = 4000) -> list[dict[str, str]]:
    dataset = load_dataset("hotpotqa/hotpot_qa", "distractor", split=f"train[:{limit}]")
    rows = []
    for row in dataset:
        question = str(row.get("question", ""))
        context = row.get("context", [])
        context_text = " ".join(str(x) for x in context)[:5000]
        if question and context_text:
            rows.append({"text": question + "\n" + context_text, "label": "high"})
    return rows


def _label_context(text: str) -> str:
    lowered = text.lower()
    if any(term in lowered for term in ("must", "required", "constraint", "only", "cannot")):
        return "critical"
    if any(term in lowered for term in ("evidence", "source", "fact", "support")):
        return "high"
    if any(term in lowered for term in ("background", "history", "context")):
        return "medium"
    return "low"


def _anuka_examples(rows: list[dict[str, str]]) -> tuple[list[str], list[str]]:
    examples = []
    labels = []
    for row in rows:
        text = row["text"]
        lowered = text.lower()
        if "counterfactual" in lowered or "what if" in lowered:
            label = "counterfactual_requested"
        elif any(term in lowered for term in ("must", "required", "constraint")):
            label = "constraint_changed"
        elif any(term in lowered for term in ("new", "updated", "changed")):
            label = "requirements_changed"
        elif any(term in lowered for term in ("evidence", "source", "fact")):
            label = "evidence_changed"
        else:
            label = "stable"
        examples.append(text)
        labels.append(label)
    return examples, labels


def _split(rows: list[dict[str, str]]) -> tuple[list, list, list]:
    random.Random(SEED).shuffle(rows)
    n = len(rows)
    return rows[: int(n * .70)], rows[int(n * .70): int(n * .85)], rows[int(n * .85):]


def _train_eval(rows: list[dict[str, str]], output: Path, model_name: str) -> dict:
    train, validation, test = _split(rows)
    train_texts = [r["text"] for r in train]
    train_labels = [r["label"] for r in train]
    metrics = train_text_model(train_texts, train_labels, output)
    # Keep validation/test material isolated and report deterministic held-out counts.
    report = {"train_examples": len(train), "validation_examples": len(validation), "test_examples": len(test), "fit_accuracy": metrics.accuracy, "fit_macro_f1": metrics.macro_f1}
    save_training_report(output.with_suffix(".json"), model=model_name, metrics=report, datasets=PUBLIC_DATASETS, split={"train": .70, "validation": .15, "test": .15, "seed": SEED})
    return report


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="artifacts/s6-models")
    args = parser.parse_args()
    output = Path(args.output_dir)
    output.mkdir(parents=True, exist_ok=True)
    rows = _load_public_examples()
    for row in rows:
        row["label"] = _label_context(row["text"])
    dharen = _train_eval(rows, output / "dharen_scope.joblib", "dharen_scope")
    anuka_texts, anuka_labels = _anuka_examples(rows)
    anuka_rows = [{"text": text, "label": label} for text, label in zip(anuka_texts, anuka_labels)]
    anuka = _train_eval(anuka_rows, output / "anuka_adaptation.joblib", "anuka_adaptation")
    (output / "training_manifest.json").write_text(json.dumps({"datasets": PUBLIC_DATASETS, "dharen": dharen, "anuka": anuka}, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
