"""S8 fixture laboratory for synthetic Criterivox member-to-bureau traffic."""
from __future__ import annotations

import json
from pathlib import Path
from criterivox.s8 import ArtifactKind, EvidenceResearchBureau
from criterivox.s8.intake import CONTRACT, S8Intake

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "acceptance" / "fixtures" / "s8"


def message(name: str, sender: str, task: str) -> dict:
    return {
        "contract": CONTRACT, "message_id": f"S8-FX-{name}", "sender": sender,
        "message_type": "research_context", "task": task,
        "context": {"fixture": name, "source_component": sender},
        "materials": [], "provenance": {"origin": sender, "fixture": name, "synthetic": True}, "synthetic": True,
    }


def run(name: str, sender: str, *, contradiction=False, missing=False, tamper=False) -> dict:
    parsed = S8Intake().parse(message(name, sender, "Inspect evidence and explain its epistemic status."))
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(ArtifactKind.EVIDENCE, {"fixture": name, "source_component": parsed.sender, "synthetic": parsed.synthetic}, tenant_id="fixture-tenant", context_id=name)
    contradiction_artifact = bureau.add_contradiction((evidence.artifact_id,), description="Synthetic conflict requiring preservation and human resolution.", tenant_id="fixture-tenant", context_id=name) if contradiction else None
    verification = bureau.verify_claim("fixture claim", (contradiction_artifact.artifact_id if contradiction_artifact else evidence.artifact_id,), tenant_id="fixture-tenant", context_id=name)
    if missing:
        verification = bureau.verify_claim("missing-evidence claim", ("missing-artifact",), tenant_id="fixture-tenant", context_id=name)
    integrity = bureau.verify_integrity(evidence.artifact_id, tenant_id="fixture-tenant", context_id=name)
    if tamper:
        evidence.payload["tampered"] = True
        integrity = bureau.verify_integrity(evidence.artifact_id, tenant_id="fixture-tenant", context_id=name)
    return {"fixture": name, "sender": parsed.sender, "synthetic": parsed.synthetic, "verification_status": verification.status, "integrity_status": integrity.status, "artifact_count": len(bureau.artifacts), "event_count": len(bureau.events)}


def main() -> int:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    cases = [("01_member_intake", "Dharen", False, False, False), ("02_temporal_memory", "Medrus", False, False, False), ("03_missing_evidence", "Anuka", False, True, False), ("04_contradiction", "Tarkis", True, False, False), ("05_uncertainty", "Syvax", False, False, False), ("06_human_correction", "Epistre", True, False, False), ("07_integrity_tamper", "Veridat", False, False, True)]
    results = [run(name, sender, contradiction=c, missing=m, tamper=t) for name, sender, c, m, t in cases]
    output = FIXTURES / "s8-fixtures-report.json"
    output.write_text(json.dumps({"contract": CONTRACT, "synthetic": True, "fixtures": results}, indent=2), encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
