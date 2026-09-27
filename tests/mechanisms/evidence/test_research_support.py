from datetime import datetime, timezone

from criterivox.s8.bureau import EvidenceResearchBureau
from criterivox.s8.models import ArtifactKind
from criterivox.s8.research import EvaluationRecorder, MemoryConsolidator, TemporalRetriever


def test_temporal_retrieval_respects_validity_window():
    bureau = EvidenceResearchBureau()
    current = datetime(2026, 1, 1, tzinfo=timezone.utc)
    historical = bureau.record_temporal_fact("case", "status", "old", valid_from=datetime(2025, 1, 1, tzinfo=timezone.utc), valid_to=datetime(2025, 12, 1, tzinfo=timezone.utc))
    active = bureau.record_temporal_fact("case", "status", "current", valid_from=datetime(2025, 12, 1, tzinfo=timezone.utc))
    found = TemporalRetriever().retrieve(bureau.artifacts, subject="case", at=current)
    assert [x.artifact_id for x in found] == [active.artifact_id]
    assert historical.artifact_id not in {x.artifact_id for x in found}


def test_memory_consolidation_retains_epistemic_metadata():
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(ArtifactKind.EVIDENCE, {"x": 1})
    memory = MemoryConsolidator().consolidate(bureau.artifacts, artifact_ids=(evidence.artifact_id,))
    assert memory.kind is ArtifactKind.MEMORY
    assert memory.payload["retains_provenance"] is True
    assert memory.payload["write_mode"] == "derived_reference_only"


def test_evaluation_record_is_reproducible_input_record():
    recorder = EvaluationRecorder()
    record = recorder.record("verification", {"dataset": "local"}, ("S8A-1",), execution_receipt={"status": "recorded"})
    assert record.experiment_id == "S8X-000001"
    assert record.artifact_ids == ("S8A-1",)
