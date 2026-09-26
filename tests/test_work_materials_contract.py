from criterivox.work_materials import WorkMaterial

def test_work_material_contract_preserves_human_fields():
    material=WorkMaterial(
        material_id="mat-1",
        material_type="analytical_report",
        title="Analytical Report",
        purpose="Show actual analysis",
        status="OK",
        source_service="analytical_reporting",
        content={"findings":["x observed"]},
        structured_data={"row_count":3},
        uncertainty=("Interpretation remains bounded.",),
        limitations=("No causal inference.",),
        editable_elements=("assumptions",),
        challengeable_elements=("finding",),
    )
    assert material.material_type == "analytical_report"
    assert material.structured_data["row_count"] == 3
    assert "finding" in material.challengeable_elements
