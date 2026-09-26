from criterivox.s8 import PartVEvidenceSurface


def test_cross_quarter_handoff_is_canonical():
    surface = PartVEvidenceSurface()
    evidence = surface.add_evidence({"claim": "revenue increased", "source": "ledger"})
    result = surface.handoff(
        (evidence.artifact_id,),
        handoff_type="evidence_to_knowledge",
        destination="viveda",
        claim="revenue increased",
        purpose="update reusable knowledge",
        assumptions=["ledger is complete"],
        uncertainty="limited to supplied ledger",
        update_reason="new verified evidence",
    )
    assert result["handoff_type"] == "evidence_to_knowledge"
    assert result["destination"] == "viveda"
    assert result["source_refs"] == (evidence.artifact_id,)
    assert result["validated"] is False


def test_cross_quarter_handoff_rejects_unknown_evidence():
    surface = PartVEvidenceSurface()
    try:
        surface.handoff(("missing",), handoff_type="decision_to_evidence", destination="medrus")
    except ValueError as exc:
        assert "Unknown evidence" in str(exc)
    else:
        raise AssertionError("unknown evidence must be rejected")
