from criterivox.s8 import ArtifactKind, PartVEvidenceSurface


def test_part5_surface_reuses_s8_for_grounding_and_provenance():
    surface = PartVEvidenceSurface()
    evidence = surface.add_evidence({"claim": "sample", "source": "doc", "document": "a.md", "line_start": 4, "line_end": 8})
    result = surface.verify("sample", (evidence.artifact_id,))
    assert result["status"] == "grounded_pending_validation"
    assert result["provenance_id"] is not None


def test_part5_reconciliation_is_explicit():
    surface = PartVEvidenceSurface()
    contradiction = surface.bureau.add_contradiction(("a",), description="conflict")
    result = surface.reconcile(contradiction.artifact_id, "quarantine", actor="human", note="needs review")
    assert result["resolution"] == "quarantine"
    assert surface.bureau.artifacts[contradiction.artifact_id].status == "quarantine"


def test_part5_retrieval_mode_is_inspectable():
    surface = PartVEvidenceSurface()
    fact = surface.bureau.record_temporal_fact("subject", "status", "active")
    result = surface.retrieval("subject")
    assert result["badge"] == "DETERMINISTIC"
    assert fact.artifact_id in result["artifact_ids"]


def test_part5_entropy_is_research_prototype():
    result = PartVEvidenceSurface().drift(["a", "a", "b"])
    assert result["metric"] == "semantic_entropy"
    assert result["status"] == "RESEARCH_PROTOTYPE"


def test_part5_line_attribution_preserves_available_granularity():
    surface = PartVEvidenceSurface()
    evidence = surface.add_evidence({"claim": "x", "document": "doc.md", "chunk": 2, "line_start": 10, "line_end": 14})
    result = surface.attribution("x")
    assert result["records"][0]["line_start"] == 10
