from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Mapping

@dataclass(frozen=True)
class InsightPackage:
    objective: str
    findings: tuple[Mapping[str,Any],...]
    supporting_artifact_ids: tuple[str,...]
    limitations: tuple[str,...]
    status: str="COMPILED_INSIGHT"
    def to_dict(self):
        return {"objective":self.objective,"findings":[dict(x) for x in self.findings],"supporting_artifact_ids":list(self.supporting_artifact_ids),"limitations":list(self.limitations),"status":self.status}

class InsightCompiler:
    """Compile recorded outputs without creating unsupported conclusions."""
    def compile(self, objective: str, artifacts) -> InsightPackage:
        findings=[]; ids=[]; limitations=[]
        for artifact in artifacts:
            ids.append(artifact.artifact_id)
            payload=dict(getattr(artifact,"payload",{}) or {})
            if payload: findings.append({"artifact_id":artifact.artifact_id,"kind":str(getattr(artifact,"kind","unknown")),"payload":payload})
            if payload.get("limitations"): limitations.extend(str(x) for x in payload["limitations"])
        if not findings: limitations.append("No authoritative analytical artifacts were supplied.")
        return InsightPackage(objective,tuple(findings),tuple(ids),tuple(dict.fromkeys(limitations)))
