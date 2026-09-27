from criterivox.Manis import ManisChallenge
def test_manis_assesses_human_challenge():
    a=ManisChallenge().assess("What evidence would falsify this?",challenge_type="evidence",affected_options=("strategy-rapid",))
    assert a.challenge_type=="evidence"
    assert a.affected_options==("strategy-rapid",)
def test_manis_rejects_empty_challenge():
    try: ManisChallenge().assess(" ")
    except ValueError as e: assert "challenge text" in str(e)
    else: raise AssertionError("empty challenge accepted")
