"""Train S6 learned models from public datasets plus Criterivox task labels."""
from __future__ import annotations
import argparse, json, random
from pathlib import Path
from datasets import load_dataset
from criterivox.context.ml import evaluate_text_model, save_training_report, train_text_model

SEED=42
PUBLIC_DATASETS=[{"id":"hotpotqa/hotpot_qa","config":"distractor","split":"train","role":"reasoning_context","license":"CC BY-SA 4.0"}]

def _load_public_examples(limit=4000):
    dataset=load_dataset("hotpotqa/hotpot_qa","distractor",split=f"train[:{limit}]")
    rows=[]
    for row in dataset:
        question=str(row.get("question","")); context=row.get("context",[]); context_text=" ".join(str(x) for x in context)[:5000]
        if question and context_text: rows.append({"text":question+"\n"+context_text})
    return rows

def _label_context(text):
    lowered=text.lower()
    if any(x in lowered for x in ("must","required","constraint","only","cannot")): return "critical"
    if any(x in lowered for x in ("evidence","source","fact","support")): return "high"
    if any(x in lowered for x in ("background","history","context")): return "medium"
    return "low"

def _label_anuka(text):
    lowered=text.lower()
    if "counterfactual" in lowered or "what if" in lowered: return "counterfactual_requested"
    if any(x in lowered for x in ("must","required","constraint")): return "constraint_changed"
    if any(x in lowered for x in ("new","updated","changed")): return "requirements_changed"
    if any(x in lowered for x in ("evidence","source","fact")): return "evidence_changed"
    return "stable"

def _split(rows):
    rows=list(rows); random.Random(SEED).shuffle(rows); n=len(rows)
    return rows[:int(n*.70)],rows[int(n*.70):int(n*.85)],rows[int(n*.85):]

def _train_eval(rows,output,model_name):
    train,validation,test=_split(rows)
    train_metrics=train_text_model([r["text"] for r in train],[r["label"] for r in train],output)
    valid_metrics=evaluate_text_model(output,[r["text"] for r in validation],[r["label"] for r in validation])
    test_metrics=evaluate_text_model(output,[r["text"] for r in test],[r["label"] for r in test])
    report={"train_examples":len(train),"validation_examples":len(validation),"test_examples":len(test),"train_accuracy":train_metrics.accuracy,"train_macro_f1":train_metrics.macro_f1,"validation_accuracy":valid_metrics.accuracy,"validation_macro_f1":valid_metrics.macro_f1,"test_accuracy":test_metrics.accuracy,"test_macro_f1":test_metrics.macro_f1}
    save_training_report(output.with_suffix(".json"),model=model_name,metrics=report,datasets=PUBLIC_DATASETS,split={"train":.70,"validation":.15,"test":.15,"seed":SEED})
    return report

def main():
    parser=argparse.ArgumentParser(); parser.add_argument("--output-dir",default="artifacts/s6-models"); args=parser.parse_args(); output=Path(args.output_dir); output.mkdir(parents=True,exist_ok=True)
    rows=_load_public_examples()
    dharen_rows=[{"text":r["text"],"label":_label_context(r["text"])} for r in rows]
    anuka_rows=[{"text":r["text"],"label":_label_anuka(r["text"])} for r in rows]
    dharen=_train_eval(dharen_rows,output/"dharen_scope.joblib","dharen_scope")
    anuka=_train_eval(anuka_rows,output/"anuka_adaptation.joblib","anuka_adaptation")
    (output/"training_manifest.json").write_text(json.dumps({"datasets":PUBLIC_DATASETS,"dharen":dharen,"anuka":anuka},indent=2),encoding="utf-8")

if __name__=="__main__": main()
