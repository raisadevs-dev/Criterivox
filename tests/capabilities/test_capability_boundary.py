from criterivox.application.capability_boundary import CapabilityRequest, InternalCapabilityBoundary


def test_capability_boundary_is_protocol_neutral() -> None:
    boundary = InternalCapabilityBoundary()
    boundary.register("context.inspect", lambda payload: {"context_id": payload["context_id"]})

    response = boundary.request(CapabilityRequest("REQ-1", "context.inspect", {"context_id": "CTX-1"}))

    assert response.status == "OK"
    assert response.output == {"context_id": "CTX-1"}
    assert response.provenance == ("context.inspect",)


def test_unknown_capability_does_not_execute_arbitrary_work() -> None:
    boundary = InternalCapabilityBoundary()
    response = boundary.request(CapabilityRequest("REQ-2", "unknown", {}))

    assert response.status == "UNSUPPORTED"
