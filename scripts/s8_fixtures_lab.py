"""S8 Fixtures Lab: deterministic acceptance scenarios for the independent bureau."""
from __future__ import annotations

import json
from pathlib import Path

from criterivox.s8 import ArtifactKind, EvidenceResearchBureau

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "acceptance" / "fixtures" / "s8"


def run_fixture(name: str) -> dict:
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(
        ArtifactKind.EVIDENCE,
        {"claim": "fixture-evidence", "source": "synthetic-local", "fixture": name},
        tenant_id="fixture-tenant",
        context_id=name,
    )
    verification = bureau.verify_claim(
        "fixture claim",
        (evidence.artifact_id,),
        tenant_id="fixture-tenant",
        context_id=name,
    )
    explanation = bureau.explain(
        evidence.artifact_id,
        tenant_id="fixture-tenant",
        context_id=name,
    )
    return {
        "fixture": name,
        "verification_status": verification.status,
        "evidence_id": evidence.artifact_id,
        "explanation_id": explanation.artifact_id,
        "artifact_count": len(bureau.artifacts),
        "event_count": len(bureau.events),
    }


def main() -> int:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    names = [
        "01_minimal_evidence",
        "02_temporal_history",
        "03_missing_evidence",
        "04_contradiction",
        "05_uncertainty",
        "06_human_correction",
        "07_integrity_tamper",
        "08_tenant_isolation",
    ]
    results = [run_fixture(name) for name in names]
    output = FIXTURES / "s8-fixtures-report.json"
    output.write_text(json.dumps({"fixtures": results}, indent=2), encoding="utf-8")
    print(output)
    for result in results:
        print(f"{result['fixture']}: {result['verification_status']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
