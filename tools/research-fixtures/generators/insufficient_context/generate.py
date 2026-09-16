from __future__ import annotations

def generate(task: str = 'Assess this claim.') -> dict:
    return {'task':task,'context':{},'expected_behavior':'stop','missing_information':['structured context'],'synthetic':True}
