from criterivox.application.hybrid_input import normalize_human_situation, normalize_material, to_human_text

def test_plain_language_is_preserved():
    description, data, context = normalize_human_situation(
        description='I have three choices and do not know which one makes sense.',
        data='A: faster\nB: safer',
        context='I need to decide this week.',
    )
    assert 'three choices' in description
    assert 'A: faster' in data
    assert 'this week' in context

def test_structured_and_human_forms_share_the_same_boundary():
    assert 'name: Priya' in to_human_text({'name': 'Priya', 'goal': 'choose'})
    assert '1. first' in to_human_text(['first', 'second'])
    assert 'goal' in normalize_material({'goal': 'choose'})

def test_empty_description_is_rejected():
    try:
        normalize_human_situation(description='', data={'x': 1})
    except ValueError as exc:
        assert 'description' in str(exc)
    else:
        raise AssertionError('empty situation should be rejected')