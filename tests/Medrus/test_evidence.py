from criterivox.Medrus import MedrusEvidence, EvidenceAssessment, ExperimentAssessment
from criterivox.s8.bureau import EvidenceResearchBureau

def test_medrus_collects_raw_evidence():
    m=MedrusEvidence(EvidenceResearchBureau())
    a=EvidenceAssessment("e1","j1","Q","source-1","document","Observed value")
    r=m.collect(a)
    assert r.kind.value=="evidence"
    assert r.status=="raw"

def test_medrus_records_experiment_without_calling_it_verification():
    m=MedrusEvidence(EvidenceResearchBureau())
    a=ExperimentAssessment("x1","j1","Q","Test hypothesis",("measure","compare"),("5","6"),"changed",("e1",))
    r=m.experiment(a)
    assert r.kind.value=="experiment"
    assert r.status=="RECORDED"

def test_medrus_rejects_empty_experiment_procedure():
    m=MedrusEvidence(EvidenceResearchBureau())
    a=ExperimentAssessment("x1","j1","Q","Test hypothesis",(),(),"",())
    try: m.experiment(a)
    except ValueError as e: assert "procedure" in str(e)
    else: raise AssertionError("experiment without procedure accepted")
