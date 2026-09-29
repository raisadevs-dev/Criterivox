from __future__ import annotations
from collections import defaultdict
from typing import Any

def enrich_snapshot(snapshot: dict[str, Any]) -> dict[str, Any]:
    artifacts=list(snapshot.get('artifacts', [])); children=defaultdict(list); branches=defaultdict(list)
    for a in artifacts:
        branches[a.get('branch_id','main')].append(a)
        for p in a.get('parent_ids',[]): children[p].append(a['artifact_id'])
    branch_rows=[]
    for bid,items in sorted(branches.items()):
        branch_rows.append({'branch_id':bid,'status':'active' if bid==snapshot.get('branch_id') else 'preserved','artifact_count':len(items),'artifact_ids':[a['artifact_id'] for a in items],'root_artifacts':[a['artifact_id'] for a in items if not a.get('parent_ids')],'result_artifacts':[a['artifact_id'] for a in items if a.get('kind')=='result']})
    lineage={a['artifact_id']:{'artifact_id':a['artifact_id'],'parents':list(a.get('parent_ids',[])),'children':children.get(a['artifact_id'],[]),'version':a.get('version',1),'branch_id':a.get('branch_id','main'),'kind':a.get('kind'),'title':a.get('title')} for a in artifacts}
    provenance={a['artifact_id']:{'source':a.get('content',{}).get('provenance','derived_from_s7_artifacts'),'parents':list(a.get('parent_ids',[])),'branch_id':a.get('branch_id','main'),'created_at':a.get('created_at')} for a in artifacts}
    interventions=[a for a in artifacts if a.get('kind')=='human_intervention']
    kinds={a.get('kind') for a in artifacts}
    character_states={'vivren':{'identity':'VIVREN','room':'Critical Intelligence Chamber','role':'critical intelligence','state':'attending' if kinds & {'evaluation','objection','limitation'} else 'idle','attention':[a['artifact_id'] for a in artifacts if a.get('kind') in {'evaluation','objection','limitation'}]},'tarkis':{'identity':'TARKIS','room':'Hypothesis Exploration Chamber','role':'hypothesis exploration','state':'exploring' if kinds & {'hypothesis','comparison'} else 'idle','attention':[a['artifact_id'] for a in artifacts if a.get('kind') in {'hypothesis','comparison'}]}}
    comparisons=[]
    for a in artifacts:
        if a.get('kind')=='comparison':
            c=a.get('content',{}); comparisons.append({'comparison_artifact_id':a['artifact_id'],'branch_id':a.get('branch_id','main'),'candidates':c.get('candidates',[]),'comparisons':c.get('comparisons',[]),'status':c.get('status','bounded_comparison')})
    result=dict(snapshot); result.update({'branches':branch_rows,'lineage':lineage,'provenance':provenance,'interventions':interventions,'character_states':character_states,'hypothesis_comparisons':comparisons}); return result

def compare_branches(snapshot: dict[str,Any]) -> dict[str,Any]:
    rows=[]; artifacts=snapshot.get('artifacts',[])
    for branch in snapshot.get('branches',[]):
        items=[a for a in artifacts if a.get('branch_id')==branch['branch_id']]
        rows.append({'branch_id':branch['branch_id'],'status':branch.get('status'),'artifact_count':len(items),'kinds':sorted({a.get('kind') for a in items}),'results':[a['artifact_id'] for a in items if a.get('kind')=='result'],'interventions':[a['artifact_id'] for a in items if a.get('kind')=='human_intervention'],'limitations':[a.get('content',{}).get('limitations',[]) for a in items if a.get('kind')=='result']})
    return {'basis':'artifact structure and recorded evaluations','truth_claim':'none','branches':rows}
