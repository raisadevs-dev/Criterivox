from __future__ import annotations
from dataclasses import dataclass
from typing import Any

@dataclass(frozen=True)
class Argument:
    argument_id:str
    claim:str
    supports:tuple[str,...]=()
    attacks:tuple[str,...]=()
    evidence_ids:tuple[str,...]=()


def build_argumentation(observations:list[dict[str,Any]], hypotheses:list[dict[str,Any]])->dict[str,Any]:
    args=[]
    for i,h in enumerate(hypotheses):
        hid=str(h.get('id') or h.get('hypothesis_id') or f'H{i+1}')
        related=[str(o.get('id') or o.get('record_id')) for o in observations if o.get('supports')==hid]
        args.append(Argument(hid,str(h.get('statement','')),evidence_ids=tuple(related)))
    attacks=[]
    for i,a in enumerate(args):
        for b in args[i+1:]:
            if a.claim and b.claim and a.claim != b.claim: attacks.append((a.argument_id,b.argument_id))
    return {'arguments':[a.__dict__ for a in args],'attacks':[{'from':a,'to':b} for a,b in attacks],'semantics':'bounded conflict graph; acceptance requires explicit evidence/context'}


def compare_hypotheses(observations:list[dict[str,Any]], hypotheses:list[dict[str,Any]])->list[dict[str,Any]]:
    result=[]
    for h in hypotheses:
        hid=str(h.get('id') or h.get('hypothesis_id'))
        evidence=[o for o in observations if o.get('supports')==hid]
        conflicts=[o for o in observations if o.get('contradicts')==hid]
        result.append({'hypothesis_id':hid,'support_count':len(evidence),'conflict_count':len(conflicts),'status':'supported_by_supplied_context' if evidence and not conflicts else 'contested' if evidence and conflicts else 'insufficient_support'})
    return result


def bounded_counterfactual(context:dict[str,Any], intervention:dict[str,Any])->dict[str,Any]:
    """Counterfactual only when the fixture explicitly supplies a causal model and intervention target."""
    model=context.get('causal_model')
    target=intervention.get('target')
    if not model or not target:return {'status':'insufficient_information','missing':['causal_model','intervention.target'],'fabrication_prevented':True}
    return {'status':'bounded_counterfactual','intervention':intervention,'model':model,'note':'No causal effect is inferred beyond the supplied model.'}
