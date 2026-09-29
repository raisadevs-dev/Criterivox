from __future__ import annotations
class PramonPlanner:
    """Structure decision options; never select or execute for the human."""
    def build_options(self, goal, plan, research_run=None):
        evidence=[] if research_run is None else [r.to_dict() for r in research_run.results]
        return [
          {"id":"strategy-rapid","label":"Rapid path","objective":goal,"approach":f"Act on the strongest supported path for: {goal}","steps":["Confirm the highest-confidence evidence","Execute the smallest reversible action","Review the result before expanding"],"benefits":["Fast feedback","Low initial commitment"],"tradeoffs":{"speed":90,"cost":70,"reliability":55},"risk":"Higher uncertainty","evidence":evidence[:3]},
          {"id":"strategy-balanced","label":"Balanced path","objective":goal,"approach":"Combine validation with measured execution and explicit checkpoints.","steps":["Validate assumptions","Execute in checkpoints","Measure outcome","Adjust before the next step"],"benefits":["Balanced evidence and execution","Explicit rollback points"],"tradeoffs":{"speed":65,"cost":55,"reliability":78},"risk":"Moderate time and cost","evidence":evidence[:5]},
          {"id":"strategy-rigor","label":"Rigor path","objective":goal,"approach":"Add deeper validation, alternative checks and rollback boundaries before action.","steps":["Validate primary and alternative evidence","Stress-test assumptions","Define rollback","Execute only after the evidence gate"],"benefits":["Higher confidence","Stronger rollback boundary"],"tradeoffs":{"speed":35,"cost":75,"reliability":92},"risk":"Slower execution","evidence":evidence[:8]},
        ]
