from criterivox.agents.kaelen.vector import VectorEncoder, VectorLakehousePackageBuilder


def test_vector_encoder_is_deterministic_and_normalized():
    encoder = VectorEncoder(dimension=8)
    first = encoder.encode({"id": 1, "name": "a"})
    second = encoder.encode({"id": 1, "name": "a"})
    assert first == second
    assert len(first.vector) == 8
    assert round(sum(value * value for value in first.vector), 6) == 1.0


def test_vector_package_is_inspectable_and_hashed():
    package = VectorLakehousePackageBuilder(VectorEncoder(8)).build(
        [{"id": 1}, {"id": 2}]
    )
    assert package["kind"] == "kaelen.vectorized_lakehouse_package"
    assert package["storage"] == "local-inspectable-artifact"
    assert package["row_count"] == 2
    assert len(package["content_hash"]) == 64
