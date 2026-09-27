from criterivox.Anukor import AnukorTransfer

def test_anukor_rejects_incompatible_transfer():
    r=AnukorTransfer(object()).assess(source_home="Medrus",destination_home="Pramon",source_artifact="e1",compatibility="INCOMPATIBLE")
    assert r.status=="REJECTED"

def test_anukor_requires_adaptation_for_unknown_compatibility():
    r=AnukorTransfer(object()).assess(source_home="Medrus",destination_home="Pramon",source_artifact="e1",compatibility="UNKNOWN")
    assert r.status=="ADAPTATION_REQUIRED"
    assert r.adaptation_required is True

def test_anukor_never_calls_delivery_success():
    r=AnukorTransfer(object()).assess(source_home="Medrus",destination_home="Pramon",source_artifact="e1",compatibility="COMPATIBLE")
    assert r.status=="READY_FOR_TRANSFER"
    assert "delivery" in r.reason.lower()
