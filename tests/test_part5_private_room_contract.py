from criterivox.s8 import PartVEvidenceSurface


def test_private_room_pass3_contract_is_representable():
    surface = PartVEvidenceSurface()
    evidence = surface.add_evidence({"claim": "decision support", "source": "human supplied"})
    handoff = surface.handoff(
        (evidence.artifact_id,),
        handoff_type="evidence_to_human_territory",
        destination="private_room",
        claim="decision support",
        purpose="human inspection",
        uncertainty="source supplied by human",
        update_reason="decision context",
    )
    assert handoff["destination"] == "private_room"
    assert handoff["handoff_type"] == "evidence_to_human_territory"
