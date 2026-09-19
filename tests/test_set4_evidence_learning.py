from pathlib import Path
from tempfile import TemporaryDirectory
from criterivox.character_backbone.set4 import (
    Set4Store, Set4Runtime, EvidenceRecord, VerificationRecord,
    ReasoningExplanation, HypothesisRecord, ChallengeRecord,
    DecisionRecord, OutcomeRecord, KnowledgeRecord, AdaptationRecord,
    TransferRecord,
)

def runtime(tmp):
    return Set4Runtime(Set4Store(Path(tmp) / "set4.sqlite3"))

def test_journey_and_full_records_are_durable():
    with TemporaryDirectory() as d:
        rt=runtime(d)
        j=rt.create_journey("Evaluate a research choice", conversation_id="c1", task_id="t1")
        eid=rt.record_evidence(EvidenceRecord("e1",j.journey_id,"t1","What supports this?","source-1","document","Observed result",provenance={"source":"source-1"}))
        vid=rt.record_verification(VerificationRecord("v1","evidence",eid,"source-check",("source-1",),("source exists",),(),"valid","intact","veridat","2026-09-19T00:00:00Z","VERIFIED"))
        rt.record_reasoning(ReasoningExplanation("r1",j.journey_id,"Why?","Use the observed result",(eid,),(),("sample is bounded",),("alternative-a",),(),(),(),("limited sample",),{"evidence":eid}))
        rt.record_hypothesis(HypothesisRecord("h1",j.journey_id,"Why?","Candidate explanation","tarkis",(eid,),status="SUPPORTED"))
        rt.record_challenge(ChallengeRecord("ch1",j.journey_id,"hypothesis","h1","I disagree","LOGIC","The assumption may not hold"))
        rt.record_decision(DecisionRecord("d1",j.journey_id,("A","B"),"A",("evidence e1",),"A","human-1",None,"Observed evidence supports A",(),(eid,),(),"AUTHORIZED","2026-09-19T00:00:00Z"))
        rt.record_outcome(OutcomeRecord("o1",j.journey_id,"t1","d1",None,None,"A succeeds","Observed A",(eid,),(),"SUCCESSFUL","VERIFIED",("bounded result",),"2026-09-19T00:00:00Z"))
        rt.record_knowledge(KnowledgeRecord("k1",j.journey_id,"choice","A worked under the recorded context",("o1",),(eid,),(vid,),("context-c1",),("similar bounded tasks",),("not universal",),(),"REUSABLE","2026-09-19T00:00:00Z","2026-09-19T00:00:00Z"))
        rt.record_adaptation(AdaptationRecord("a1",j.journey_id,"context-c1","v1","v2","verified outcome",("k1",),"re-evaluate affected context","PROPOSED"))
        rt.record_transfer(TransferRecord("tr1",j.journey_id,"knowledge","planning","k1","context-c1","context-c2","compatible-with-review",True,"a1","ADAPTED"))
        snap=rt.inspect_journey(j.journey_id)
        assert snap["record_count"] >= 12
        assert snap["stages"]["evidence"][0]["evidence_id"] == "e1"
        assert snap["stages"]["verification"][0]["result"] == "VERIFIED"

def test_unverified_evidence_cannot_be_claimed_verified():
    with TemporaryDirectory() as d:
        rt=runtime(d); j=rt.create_journey("x")
        try:
            rt.record_evidence(EvidenceRecord("e",j.journey_id,None,"q","s","document","o",verification_status="VERIFIED"))
            assert False
        except ValueError:
            pass

def test_hypothesis_cannot_jump_to_verified():
    with TemporaryDirectory() as d:
        rt=runtime(d); j=rt.create_journey("x")
        try:
            rt.record_hypothesis(HypothesisRecord("h",j.journey_id,"q","claim","tarkis",status="VERIFIED"))
            assert False
        except ValueError:
            pass

def test_successful_outcome_requires_verification():
    with TemporaryDirectory() as d:
        rt=runtime(d); j=rt.create_journey("x")
        try:
            rt.record_outcome(OutcomeRecord("o",j.journey_id,None,None,None,None,"x","x",(),(),"SUCCESSFUL","UNVERIFIED",(),"2026-09-19T00:00:00Z"))
            assert False
        except ValueError:
            pass

def test_decision_attribution_requires_human_actor():
    with TemporaryDirectory() as d:
        rt=runtime(d); j=rt.create_journey("x")
        try:
            rt.record_decision(DecisionRecord("d",j.journey_id,("A",),"A",(),"A",None,None,None,(),(),(),"AUTHORIZED","2026-09-19T00:00:00Z"))
            assert False
        except ValueError:
            pass

def test_character_boundaries_do_not_overclaim():
    with TemporaryDirectory() as d:
        rt=runtime(d)
        assert "Hidden chain-of-thought" in rt.character_answer("vivren", "explain reasoning")
        assert "No authoritative verification" in rt.character_answer("veridat", "is this verified?")
        assert "human decision" in rt.character_answer("pramon", "who decided?")
        assert "transfer" in rt.character_answer("anukor", "did it transfer?").lower()
