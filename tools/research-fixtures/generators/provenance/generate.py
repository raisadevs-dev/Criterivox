from __future__ import annotations

def generate(records: int, component: str = 'Dharen') -> list[dict]:
    return [{'record_id':f'prov-{i+1:04d}','source_component':component,'source_kind':'synthetic_upstream_request','captured_at':'fixture-generation-time','chain':['upstream','s7-input','s7-artifact']} for i in range(records)]
