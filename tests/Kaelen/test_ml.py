from criterivox.Kaelen.ml import KaelenMLAgent


def test_kaelen_ml_plan_remains_constrained():
    plan = KaelenMLAgent().propose(
        {"id": "int", "name": "str"},
        {"id": "str", "name": "str", "score": "float"},
    )
    KaelenMLAgent.validate_plan(plan)
    assert plan.action == "type_repair"
    assert {operation["op"] for operation in plan.operations} <= {
        "cast", "add_field", "remove_field"
    }
