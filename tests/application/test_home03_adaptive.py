from criterivox.application.syvax import syvax_engine

def test_candidate_route_is_policy_valid():
    plan = syvax_engine.compile_plan('analyze this evidence')
    result = syvax_engine.candidate_route(plan)
    assert result['validation']['valid'] is True
    assert result['candidate']['nodes']
    assert result['candidate']['nodes'][-1]['actor'] == 'Syvax'

def test_runtime_event_can_raise_evidence_and_human_challenge():
    plan = syvax_engine.compile_plan('analyze this')
    result = syvax_engine.revise_from_runtime(plan, {'confidence': 0.2, 'target': 'Dharen', 'status': 'ok'})
    actors = [s['actor'] for s in result['plan']['steps']]
    assert 'Medrus' in actors
    assert 'Epistre' in actors
    assert 'Manis' in actors
    assert result['candidate']['validation']['valid'] is True
