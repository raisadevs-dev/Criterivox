from __future__ import annotations

def generate(artifact_id: str = 'A-fixture', action: str = 'challenge') -> list[dict]:
    return [{'intervention_id':'I-fixture-0001','target_artifact_id':artifact_id,'action':action,'instruction':'Reconsider the weakest supported inference.','provenance':'human_intervention'}]
