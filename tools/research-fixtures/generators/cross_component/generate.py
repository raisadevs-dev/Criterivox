from __future__ import annotations

def generate(task: str, component: str = 'Dharen', upstream: str = 'Anuka') -> dict:
    return {'task':task,'simulated_upstream_components':[component,upstream],'input_kind':'structured cross-component context','synthetic':True}
