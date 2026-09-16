"""Minimal standalone S8 process smoke entrypoint."""
from __future__ import annotations

from .bureau import EvidenceResearchBureau
from .models import ArtifactKind


def main() -> int:
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(
        ArtifactKind.EVIDENCE,
        {"fixture": "standalone-smoke", "source": "local"},
        tenant_id="standalone",
        context_id="default",
    )
    result = bureau.verify_claim(
        "standalone smoke claim",
        (evidence.artifact_id,),
        tenant_id="standalone",
        context_id="default",
    )
    print(f"S8 standalone: {result.status}; artifacts={len(bureau.artifacts)} events={len(bureau.events)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
