"""S8 fixture laboratory for synthetic Criterivox member-to-bureau traffic."""
from __future__ import annotations

import json
from pathlib import Path

from criterivox.s8 import ArtifactKind, EvidenceResearchBureau
from criterivox.s8.intake import CONTRACT, S8Intake
from criterivox.s8.policy import AuthorizationError

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "acceptance" / "fixtures" / "s8"
TENANT = "fixture-tenant"


def message(name: str, sender: str, task: str, *, materials: list[dict] | None = None) -> dict:
    return {
        "contract": CONTRACT,
        "message_id": f"S8-FX-{name}",
        "sender": sender,
        "message_type": "research_context",
        "task": task,
        "context": {"fixture": name, "source_component": sender},
        "materials": materials or [],
        "provenance": {"origin": sender, "fixture": name, "synthetic": True},
        "synthetic": True,
    }


def run(name: str, sender: str, *, contradiction=False, missing=False, tamper=False, intervention=False, isolation=False, temporal=False) -> dict:
    parsed = S8Intake().parse(message(name, sender, "Inspect evidence and explain its epistemic status."))
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(
        ArtifactKind.EVIDENCE,
        {"fixture": name, "source_component": parsed.sender, "synthetic": parsed.synthetic},
        tenant_id=TENANT,
        context_id=name,
    )

    contradiction_artifact = None
    if contradiction:
        contradiction_artifact = bureau.add_contradiction(
            (evidence.artifact_id,),
            description="Synthetic conflict requiring preservation and human resolution.",
            tenant_id=TENANT,
            context_id=name,
        )

    verification = bureau.verify_claim(
        "fixture claim",
        (contradiction_artifact.artifact_id if contradiction_artifact else evidence.artifact_id,),
        tenant_id=TENANT,
        context_id=name,
    )
    if missing:
        verification = bureau.verify_claim("missing-evidence claim", ("missing-artifact",), tenant_id=TENANT, context_id=name)

    uncertainty = None
    if name == "05_uncertainty":
        uncertainty = bureau.add_uncertainty(
            (evidence.artifact_id,),
            dimensions={"source_completeness": "unknown", "semantic_ambiguity": "present"},
            reason="Synthetic fixture intentionally lacks enough context for a stronger conclusion.",
            tenant_id=TENANT,
            context_id=name,
        )

    temporal_artifact = None
    if temporal:
        temporal_artifact = bureau.record_temporal_fact(
            "fixture-subject", "state", "observed",
            source_ids=(evidence.artifact_id,), tenant_id=TENANT, context_id=name,
        )
        assert bureau.retrieve_temporal("fixture-subject", tenant_id=TENANT, context_id=name)

    integrity = bureau.verify_integrity(evidence.artifact_id, tenant_id=TENANT, context_id=name)
    if tamper:
        evidence.payload["tampered"] = True
        integrity = bureau.verify_integrity(evidence.artifact_id, tenant_id=TENANT, context_id=name)
        assert integrity.status == "tampered"

    intervention_status = "not-run"
    if intervention:
        intervention = bureau.challenge("human", (evidence.artifact_id,), tenant_id=TENANT, context_id=name, proposed_alternative="revise the affected interpretation")
        try:
            bureau.record_revision(intervention.intervention_id, (evidence.artifact_id,), ("revised-1",), (evidence.artifact_id,))
        except PermissionError:
            intervention_status = "authorization-required"
        bureau.authorize_challenge(intervention.intervention_id, actor_id="human")
        revision = bureau.record_revision(intervention.intervention_id, (evidence.artifact_id,), ("revised-1",), (evidence.artifact_id,))
        assert revision.preserved_original
        intervention_status = "revised-with-authorization"

    isolation_status = "not-run"
    if isolation:
        isolation_status = "denied" if not bureau.policy.can_inspect(
            actor_id="human", tenant_id="other-tenant", context_id=name,
            artifact_tenant_id=TENANT, artifact_context_id=name,
        ) else "unexpectedly-allowed"
        assert isolation_status == "denied"

    return {
        "fixture": name,
        "sender": parsed.sender,
        "synthetic": parsed.synthetic,
        "verification_status": verification.status,
        "integrity_status": integrity.status,
        "uncertainty": uncertainty is not None,
        "temporal": temporal_artifact is not None,
        "intervention_status": intervention_status,
        "isolation_status": isolation_status,
        "artifact_count": len(bureau.artifacts),
        "event_count": len(bureau.events),
    }


def main() -> int:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    cases = [
        ("01_member_intake", "Dharen", {}),
        ("02_temporal_memory", "Medrus", {"temporal": True}),
        ("03_missing_evidence", "Anuka", {"missing": True}),
        ("04_contradiction", "Tarkis", {"contradiction": True}),
        ("05_uncertainty", "Syvax", {}),
        ("06_human_correction", "Epistre", {"contradiction": True, "intervention": True}),
        ("07_integrity_tamper", "Veridat", {"tamper": True}),
        ("08_cross_context_isolation", "Pramon", {"isolation": True}),
    ]
    results = [run(name, sender, **options) for name, sender, options in cases]
    assert all(item["synthetic"] for item in results)
    assert any(item["verification_status"] == "insufficient_evidence" for item in results)
    assert any(item["verification_status"] == "contradictory" for item in results)
    assert any(item["integrity_status"] == "tampered" for item in results)
    assert any(item["intervention_status"] == "revised-with-authorization" for item in results)
    assert any(item["isolation_status"] == "denied" for item in results)

    output = FIXTURES / "s8-fixtures-report.json"
    output.write_text(json.dumps({"contract": CONTRACT, "synthetic": True, "fixtures": results}, indent=2), encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
