from __future__ import annotations

def generate(records: int=10, competing: bool=True, contradictory: bool=True) -> list[dict]:
    rows=[]
    for i in range(records):
        rows.append({'fixture_id':f'hypothesis-{i+1:04d}','scenario':'hypothesis','simulated_upstream_component':'structured_observations','task':'Explore competing explanations for a synthetic observation.','context':{'observation':f'synthetic observation {i+1}','source':'fixture-lab'},'observations':[{'id':f'obs-{i+1:04d}','value':'synthetic','supports':['H1'] if i%2==0 else ['H2']], 'hypotheses':[{'id':'H1','statement':'Explanation A'},{'id':'H2','statement':'Explanation B'}] if competing else [{'id':'H1','statement':'Explanation A'}], 'contradictions':[{'id':f'c-{i+1:04d}','between':['H1','H2']}] if contradictory and competing and i%3==0 else [], 'provenance':{'generator':'research-fixtures.hypothesis','synthetic':True}, 'limitations':['Synthetic stimulus; not production intelligence.'], 'synthetic':True})
    return rows
