from criterivox.world.level2_part2 import part2_runtime

def test_part2_has_four_canonical_homes_and_truth_model():
    state=part2_runtime.state()
    assert [h["id"] for h in state["homes"]]==["gateway","bloom","data","context"]
    assert state["truth_model"]==["LIVE","SIMULATED","HISTORICAL","PLANNED"]

def test_dynamic_ui_intents_follow_runtime_state():
    running=part2_runtime.synthesize_ui_intents({"status":"RUNNING"})
    assert "pause" in running["intents"]
    paused=part2_runtime.synthesize_ui_intents({"status":"PAUSED"})
    assert "resume" in paused["intents"]

def test_steering_changes_live_status():
    part2_runtime.steer("pause")
    assert part2_runtime.status_ticker()["state"]=="PAUSED"
    part2_runtime.steer("resume")
    assert part2_runtime.status_ticker()["state"]=="RUNNING"
    part2_runtime.steer("abort")

def test_energy_allocation_is_bounded():
    event=part2_runtime.allocate_energy("bloom",2000)
    assert event["budget"]==1000
    assert part2_runtime.energy["bloom"]==1000

def test_context_budget_requires_complete_100_percent_allocation():
    part2_runtime.allocate_context_budget({"critical":40,"high":30,"medium":20,"low":10})
    assert sum(part2_runtime.context_budget.values())==100
