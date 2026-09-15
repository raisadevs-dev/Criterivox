from __future__ import annotations

def generate(task: str, records: int, component: str = 'Dharen') -> list[dict]:
    rows=[{'record_id':f'obs-{i+1:04d}','observation':f'Synthetic observation {i+1}','source_component':component} for i in range(records)]
    rows.append({'record_id':'contradiction-0001','observation':'Synthetic evidence conflicts with an earlier observation.','conflict':True})
    return rows
