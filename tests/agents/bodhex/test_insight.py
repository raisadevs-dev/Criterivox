from criterivox.Bodhex import InsightCompiler

class A:
    def __init__(self,i,p): self.artifact_id=i; self.payload=p; self.kind="evidence"

def test_bodhex_compiles_recorded_artifacts():
    result=InsightCompiler().compile("Assess the situation.",[A("a1",{"finding":"supported"}),A("a2",{"limitations":["missing source"]})])
    assert result.status=="COMPILED_INSIGHT"
    assert result.supporting_artifact_ids==("a1","a2")
    assert "missing source" in result.limitations
def test_bodhex_does_not_invent_when_empty():
    result=InsightCompiler().compile("Assess.",[])
    assert result.findings==()
    assert result.limitations
