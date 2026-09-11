from criterivox.application.tool_boundary import ToolBoundary, ToolRequest, ToolResponse


def test_tool_boundary_routes_explicit_capability() -> None:
    boundary = ToolBoundary()

    def handler(request: ToolRequest) -> ToolResponse:
        return ToolResponse(
            capability=request.capability,
            action=request.action,
            status="OK",
            result={"accepted": True},
        )

    boundary.register("context.inspect", handler)
    response = boundary.invoke(
        ToolRequest(capability="context.inspect", action="read", arguments={})
    )

    assert response.status == "OK"
    assert response.result["accepted"] is True


def test_unknown_capability_is_explicit() -> None:
    response = ToolBoundary().invoke(
        ToolRequest(capability="future.mcp", action="read", arguments={})
    )

    assert response.status == "UNKNOWN_CAPABILITY"
