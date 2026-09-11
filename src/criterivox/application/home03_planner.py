from __future__ import annotations
from dataclasses import asdict, dataclass
from typing import Any

ALLOWED_HOMES={f'Home {i:02d}' for i in range(1,9)}
ALLOWED_ACTORS={'Dharen','Syvax','Tarkis','Vivren','Medrus','Epistre','Pramon','Manis','Kaelen','Anuka','Bodhex','Veridat','Viveda','Sandre'}

@dataclass(frozen=True)
class RouteNode:
    id:str; actor:str; home:str; capability:str
@dataclass(frozen=True)
class RouteEdge:
    source:str; target:str; reason:str
@dataclass(frozen=True)
class CandidateRouteGraph:
    graph_id:str; task_id:str; intent:str; nodes:tuple[RouteNode,...]; edges:tuple[RouteEdge,...]; rationale:dict[str,Any]

class CandidateRoutePlanner:
    def propose(self,plan):
        nodes=tuple(RouteNode(f'n{i+1}',s.actor,s.home,s.capability) for i,s in enumerate(plan.steps))
        edges=tuple(RouteEdge(nodes[i].id,nodes[i+1].id,nodes[i+1].capability) for i in range(len(nodes)-1))
        return CandidateRouteGraph('candidate-'+plan.task_id,plan.task_id,plan.intent.intent_type,nodes,edges,{'confidence':plan.intent.confidence,'source':'Syvax hybrid planner'})

class DeterministicRoutePolicy:
    def validate(self,graph:CandidateRouteGraph)->dict[str,Any]:
        reasons=[]; ids={n.id for n in graph.nodes}
        if not graph.nodes: reasons.append('Candidate graph must contain at least one node.')
        if any(n.actor not in ALLOWED_ACTORS for n in graph.nodes): reasons.append('Unknown actor in candidate graph.')
        if any(n.home not in ALLOWED_HOMES for n in graph.nodes): reasons.append('Unknown home in candidate graph.')
        if any(e.source not in ids or e.target not in ids for e in graph.edges): reasons.append('Edge references an unknown node.')
        if graph.nodes and graph.nodes[-1].actor!='Syvax': reasons.append('Human-facing plans must terminate at Syvax.')
        if len({n.actor for n in graph.nodes}) != len(graph.nodes): reasons.append('Duplicate actor execution is rejected by the baseline policy.')
        return {'valid':not reasons,'reasons':reasons,'policy':'home03-route-policy-v1','graph':asdict(graph)}

class RuntimeAdaptivePlanner:
    def __init__(self): self.candidates={}; self.policy=DeterministicRoutePolicy(); self.planner=CandidateRoutePlanner()
    def propose(self,plan):
        graph=self.planner.propose(plan); validation=self.policy.validate(graph); self.candidates[graph.graph_id]={'graph':graph,'validation':validation}; return {'candidate':asdict(graph),'validation':validation}
    def revise(self,plan,event:dict[str,Any]):
        signal={}
        confidence=event.get('confidence')
        if confidence is not None and float(confidence)<.5: signal['evidence_required']=True; signal['human_challenge']=True
        target=str(event.get('target',''))
        if target in {'Tarkis','Vivren'} and event.get('status') in {'failed','blocked'}: signal['skip_hypothesis']=True
        revised=type(plan)(plan.task_id,plan.intent,plan.steps,plan.created_at)
        return signal,revised

runtime_adaptive_planner=RuntimeAdaptivePlanner()
