from criterivox.Bloom import BloomController, BloomCapability

def test_bloom_capability_activation_routes():
    result = BloomController().activate_capability(BloomCapability.ANALYZE, source="test")
    assert result["capability"] == "analyze"
    assert result["destinations"]

def test_bloom_budget_and_mode():
    controller = BloomController()
    assert controller.set_budget("Home 03", 250) == 250
    assert controller.set_mode("HOTL") == "HOTL"
