from criterivox.Viveda import VivedaKnowledge

class Store:
    def record_knowledge(self, record): return record.knowledge_id

def test_viveda_requires_verification_for_verified_knowledge():
    v=VivedaKnowledge(Store())
    try: v.assess(subject="Rule",statement="Supported",maturity="VERIFIED")
    except ValueError as e: assert "verification" in str(e)
    else: raise AssertionError("unverified knowledge accepted")

def test_viveda_requires_applicability_for_reusable_knowledge():
    v=VivedaKnowledge(Store())
    try: v.assess(subject="Rule",statement="Supported",maturity="REUSABLE",verification_refs=("v1",))
    except ValueError as e: assert "applicability" in str(e)
    else: raise AssertionError("unscoped reusable knowledge accepted")

def test_viveda_records_candidate_knowledge():
    v=VivedaKnowledge(Store())
    a=v.assess(subject="Pattern",statement="Observed repeatedly",source_artifacts=("a1",),maturity="CANDIDATE")
    assert v.record(knowledge_id="k1",journey_id="j1",assessment=a)=="k1"
