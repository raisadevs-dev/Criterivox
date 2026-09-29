from datetime import datetime, timedelta, timezone

from criterivox.application.context_engine import ContextEngine, Scratchpad
from criterivox.domain.context import ContextDimension, EvidenceStatus
from criterivox.domain.data_foundation import ConfirmationStatus, DataFoundation, DataHandoff, Provenance, QualityMetadata, SourceRecord, SourceType


def _foundation():
    source = SourceRecord("SRC-1", "sample", SourceType.DATASET, "test", "2026-09-10T00:00:00Z", provenance=Provenance("SRC-1", SourceType.DATASET, "sample"))
    return DataFoundation("DF-1", "2026-09-10T00:00:00Z", sources=(source,), supplied_context={"purpose": "research"}, canonical_data=({"value": 1},), quality=QualityMetadata(), confirmation_status=ConfirmationStatus.USER_CONFIRMED, handoff_ready=True)


def test_context_engine_preserves_material_lineage():
    result = ContextEngine().create_from_material_set(_foundation())
    assert result.context.lineage is not None
    assert result.context.lineage.material_set_id == "DF-1"
    assert result.context.lineage.immutable is False
    assert "content" in {item.dimension.value for item in result.context.items}


def test_normalization_does_not_assert_semantic_equivalence():
    context = ContextEngine().create_from_material_set(_foundation()).context
    result = ContextEngine().normalize(context)
    assert all(item.semantic_equivalence_asserted is False for item in result)


def test_baseline_is_explicitly_unknown():
    result = ContextEngine().create_from_material_set(_foundation())
    assert result.baselines[0].status is EvidenceStatus.UNKNOWN
    assert result.baselines[0].limitations


def test_scratchpad_expires_by_absolute_ttl():
    now = datetime(2026, 9, 10, tzinfo=timezone.utc)
    pad = Scratchpad(timedelta(hours=24))
    pad.put("module", "temporary", now=now)
    assert pad.get("module", now=now + timedelta(hours=23)) == "temporary"
    assert pad.get("module", now=now + timedelta(hours=24, seconds=1)) is None


def test_scratchpad_cleans_on_signoff():
    pad = Scratchpad()
    pad.put("module", "temporary")
    assert pad.cleanup(signed_off=True) == ("module",)
    assert pad.get("module") is None
