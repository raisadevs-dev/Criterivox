from __future__ import annotations

def generate(task: str, records: int, component: str = 'Dharen') -> list[dict]:
    return [{'record_id':f'reason-{i+1:04d}','task':task,'observation':f'Synthetic structured observation {i+1}','source_component':component} for i in range(records)]
