from criterivox.s7.inspection import compare_branches, enrich_snapshot
from criterivox.s7.orchestrator import ReasoningResearchBureau


def test_inspection_exposes_lineage_provenance_and_character_state():
    bureau=ReasoningResearchBureau()
    session=bureau.start('Compare two hypotheses', {'observation':'synthetic'})
    view=enrich_snapshot(bureau.snapshot(session.session_id))
    assert view['lineage']
    assert view['provenance']
    assert view['character_states']['vivren']['identity']=='VIVREN'
    assert view['character_states']['tarkis']['identity']=='TARKIS'
    assert compare_branches(view)['truth_claim']=='none'


def test_challenge_branch_is_comparable_and_intervention_is_traceable():
    bureau=ReasoningResearchBureau()
    session=bureau.start('Compare two hypotheses', {'observation':'synthetic'})
    before=bureau.snapshot(session.session_id)
    target=next(a for a in before['artifacts'] if a['kind']=='reasoning')
    after=bureau.challenge(session.session_id,target['artifact_id'],'Account for an alternative observation.')
    view=enrich_snapshot(bureau.snapshot(after.session_id))
    comparison=compare_branches(view)
    assert len(comparison['branches'])==2
    assert view['interventions']
    intervention=view['interventions'][-1]
    assert target['artifact_id'] in intervention['parent_ids']
