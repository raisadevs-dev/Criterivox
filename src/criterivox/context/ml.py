from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json, math, re
from typing import Any, Iterable, Mapping

try:
    import joblib
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline
    from sklearn.metrics import accuracy_score, f1_score
except ImportError:
    joblib = None
    TfidfVectorizer = LogisticRegression = Pipeline = None
    accuracy_score = f1_score = None


@dataclass(frozen=True)
class ModelMetrics:
    accuracy: float
    macro_f1: float
    examples: int

@dataclass(frozen=True)
class LearnedPrediction:
    label: str
    confidence: float
    model_version: str

class JsonMultinomialNB:
    """Small, provenance-safe serialized learned classifier used at runtime."""
    def __init__(self, payload: Mapping[str, Any]):
        if payload.get("format") != "criterivox.multinomial_nb.v1": raise ValueError("Unsupported learned model format")
        self.classes = tuple(str(x) for x in payload["classes"])
        self.vocabulary = {str(t): i for i, t in enumerate(payload["vocabulary"])}
        self.class_counts = {str(k): float(v) for k, v in payload["class_counts"].items()}
        self.token_counts = {str(k): [float(v) for v in vals] for k, vals in payload["token_counts"].items()}
        self.token_totals = {str(k): float(v) for k, v in payload["token_totals"].items()}
        self.alpha = float(payload.get("alpha", 1.0))
        self.training_examples = int(payload.get("training_examples", sum(self.class_counts.values())))

    @staticmethod
    def _tokens(text: str) -> list[str]:
        return re.findall(r"[a-z0-9_]+", str(text).lower())

    def predict_proba(self, texts: list[str]) -> list[list[float]]:
        total_classes = sum(self.class_counts.values()) or 1.0
        vocab_size = max(1, len(self.vocabulary))
        rows=[]
        for text in texts:
            tokens=self._tokens(text); scores=[]
            for cls in self.classes:
                score=math.log((self.class_counts[cls]+self.alpha)/(total_classes+self.alpha*len(self.classes)))
                denom=self.token_totals[cls]+self.alpha*vocab_size
                counts=self.token_counts[cls]
                for token in tokens:
                    idx=self.vocabulary.get(token)
                    if idx is not None: score += math.log((counts[idx]+self.alpha)/denom)
                scores.append(score)
            peak=max(scores); exps=[math.exp(s-peak) for s in scores]; z=sum(exps) or 1.0
            rows.append([v/z for v in exps])
        return rows

    def predict(self, texts: list[str]) -> list[str]:
        return [self.classes[max(range(len(self.classes)), key=lambda i:p[i])] for p in self.predict_proba(texts)]

class LearnedContextModel:
    labels: tuple[str, ...] = ()
    def __init__(self, model_path: str | Path | None = None, *, model_version: str = "unloaded") -> None:
        self.model_path=Path(model_path) if model_path else None; self.model=None; self.model_version=model_version
    @property
    def available(self) -> bool: return self.model is not None
    def load(self) -> bool:
        if not self.model_path or not self.model_path.exists(): return False
        if self.model_path.suffix == ".json": self.model=JsonMultinomialNB(json.loads(self.model_path.read_text(encoding="utf-8"))); return True
        if joblib is None: return False
        self.model=joblib.load(self.model_path); return True
    def predict(self, texts: Iterable[str]) -> list[str]: return [str(x) for x in self.model.predict(list(texts))] if self.model is not None else []
    def predict_one(self, text: str) -> LearnedPrediction | None:
        if self.model is None: return None
        label=str(self.model.predict([text])[0]); confidence=1.0
        proba=getattr(self.model,"predict_proba",None)
        if callable(proba): confidence=float(max(proba([text])[0]))
        return LearnedPrediction(label,confidence,self.model_version)

class DharenLearnedModel(LearnedContextModel): labels=("critical","high","medium","low")
class AnukaLearnedModel(LearnedContextModel): labels=("stable","requirements_changed","evidence_changed","constraint_changed","drift_detected","counterfactual_requested")
class SandreLearnedModel(LearnedContextModel): labels=("ready","review","quarantine")
class KaelenLearnedModel(LearnedContextModel): labels=("no_change","schema_extension","schema_reduction_review","schema_mapping_review","type_repair")

class S6LearnedModelRegistry:
    """Single model boundary: all S6 learned agents load through one registry."""
    def __init__(self, model_dir: str | Path | None = None):
        root=Path(model_dir) if model_dir else Path(__file__).resolve().parents[3]/"models"/"s6"
        self.model_dir=root
        self.dharen=DharenLearnedModel(root/"dharen.json",model_version="dharen-context-learned-1")
        self.anuka=AnukaLearnedModel(root/"anuka.json",model_version="anuka-adaptation-learned-1")
        self.sandre=SandreLearnedModel(root/"sandre.json",model_version="sandre-quality-learned-1")
        self.kaelen=KaelenLearnedModel(root/"kaelen.json",model_version="kaelen-schema-learned-1")
    def models(self)->dict[str,LearnedContextModel]: return {"dharen":self.dharen,"anuka":self.anuka,"sandre":self.sandre,"kaelen":self.kaelen}
    def load_all(self)->dict[str,bool]: return {n:m.load() for n,m in self.models().items()}
    def status(self)->dict[str,Any]: return {n:{"available":m.available,"path":str(m.model_path),"model_version":m.model_version,"labels":m.labels} for n,m in self.models().items()}

def train_text_model(texts:list[str],labels:list[str],output_path:str|Path)->ModelMetrics:
    if Pipeline is None or joblib is None: raise RuntimeError("Install the optional ML dependencies before training.")
    if len(texts)!=len(labels) or len(set(labels))<2: raise ValueError("Training requires equally sized texts/labels with at least two classes.")
    model=Pipeline([("tfidf",TfidfVectorizer(ngram_range=(1,2),min_df=1,sublinear_tf=True)),("classifier",LogisticRegression(max_iter=1200,class_weight="balanced"))]); model.fit(texts,labels); predictions=model.predict(texts)
    metrics=ModelMetrics(float(accuracy_score(labels,predictions)),float(f1_score(labels,predictions,average="macro")),len(texts)); out=Path(output_path); out.parent.mkdir(parents=True,exist_ok=True); joblib.dump(model,out); return metrics

def evaluate_text_model(model_path:str|Path,texts:list[str],labels:list[str])->ModelMetrics:
    if joblib is None or accuracy_score is None: raise RuntimeError("Install the optional ML dependencies before evaluation.")
    model=joblib.load(model_path); predictions=model.predict(texts); return ModelMetrics(float(accuracy_score(labels,predictions)),float(f1_score(labels,predictions,average="macro")),len(labels))

def save_training_report(path:str|Path,*,model:str,metrics:Mapping[str,Any],datasets:list[Mapping[str,Any]],split:Mapping[str,Any])->None:
    payload={"model":model,"metrics":dict(metrics),"datasets":datasets,"split":dict(split)}; Path(path).parent.mkdir(parents=True,exist_ok=True); Path(path).write_text(json.dumps(payload,indent=2,sort_keys=True),encoding="utf-8")

__all__=["AnukaLearnedModel","DharenLearnedModel","KaelenLearnedModel","LearnedContextModel","LearnedPrediction","ModelMetrics","S6LearnedModelRegistry","SandreLearnedModel","evaluate_text_model","save_training_report","train_text_model"]
