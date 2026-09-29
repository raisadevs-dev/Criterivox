"""Train a learned sentence relevance model from HotpotQA supporting-fact supervision.

This is an attention-style compressor: it learns a relevance score for context
sentences and can later select high-scoring sentences under a token budget.
It does not replace Dharen's deterministic safety firewall or hard constraints.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import joblib
from datasets import load_dataset
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score
from sklearn.pipeline import Pipeline


def rows(limit: int = 3000):
    dataset = load_dataset("hotpotqa/hotpot_qa", "distractor", split=f"train[:{limit}]")
    for row in dataset:
        question = str(row["question"])
        context = row["context"]
        supporting = row["supporting_facts"]
        positive = {(str(t), int(s)) for t, s in zip(supporting["title"], supporting["sent_id"])}
        for title, sentences in zip(context["title"], context["sentences"]):
            for index, sentence in enumerate(sentences):
                yield question + " [SEP] " + str(sentence), int((str(title), index) in positive)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="artifacts/s6-models/context_compressor.joblib")
    parser.add_argument("--limit", type=int, default=3000)
    args = parser.parse_args()
    examples = list(rows(args.limit))
    texts = [x[0] for x in examples]
    labels = [x[1] for x in examples]
    n = len(examples)
    train_end, valid_end = int(n * .70), int(n * .85)
    model = Pipeline([("tfidf", TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True)), ("classifier", LogisticRegression(max_iter=1200, class_weight="balanced"))])
    model.fit(texts[:train_end], labels[:train_end])
    validation = model.predict(texts[train_end:valid_end])
    test = model.predict(texts[valid_end:])
    report = {
        "dataset": "hotpotqa/hotpot_qa:distractor",
        "license": "CC BY-SA 4.0",
        "train_examples": train_end,
        "validation_examples": valid_end - train_end,
        "test_examples": n - valid_end,
        "validation_accuracy": float(accuracy_score(labels[train_end:valid_end], validation)),
        "validation_macro_f1": float(f1_score(labels[train_end:valid_end], validation, average="macro")),
        "test_accuracy": float(accuracy_score(labels[valid_end:], test)),
        "test_macro_f1": float(f1_score(labels[valid_end:], test, average="macro")),
        "task": "supporting-sentence relevance / context compression",
    }
    output = Path(args.output); output.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, output)
    output.with_suffix(".json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
