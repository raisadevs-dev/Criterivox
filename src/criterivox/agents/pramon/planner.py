from __future__ import annotations

from typing import Any


class PramonPlanner:
    """Structure decision options from the human problem and supplied evidence."""

    def build_options(self, goal, plan, research_run=None, *, foundation=None, context=""):
        evidence = [] if research_run is None else [r.to_dict() for r in research_run.results]
        supplied = []
        if foundation is not None:
            for row in foundation.canonical_data[:12]:
                if isinstance(row, dict):
                    supplied.append({
                        "source": "human-supplied-data",
                        "data": {str(k): v for k, v in row.items()},
                    })
            if not supplied:
                for source in foundation.sources[:12]:
                    content = str(source.raw_content or "").strip()
                    if content:
                        supplied.append({
                            "source": str(source.name),
                            "data": content[:1200],
                        })
        combined_evidence = supplied + evidence
        evidence_note = (
            f"{len(supplied)} supplied evidence record(s)"
            if supplied else
            "No structured supplied evidence was extracted"
        )
        return [
          {"id":"strategy-rapid","label":"Rapid path","objective":goal,"approach":f"Act on the strongest supported path for: {goal}","steps":["Confirm the highest-confidence supplied evidence","Execute the smallest reversible action","Review the result before expanding"],"benefits":["Fast feedback","Low initial commitment"],"tradeoffs":{"speed":90,"cost":70,"reliability":55},"risk":"Higher uncertainty","evidence":combined_evidence[:8],"evidence_basis":evidence_note},
          {"id":"strategy-balanced","label":"Balanced path","objective":goal,"approach":"Combine validation with measured execution and explicit checkpoints using the supplied evidence.","steps":["Validate supplied assumptions","Execute in checkpoints","Measure outcome","Adjust before the next step"],"benefits":["Balanced evidence and execution","Explicit rollback points"],"tradeoffs":{"speed":65,"cost":55,"reliability":78},"risk":"Moderate time and cost","evidence":combined_evidence[:12],"evidence_basis":evidence_note},
          {"id":"strategy-rigor","label":"Rigor path","objective":goal,"approach":"Add deeper validation, alternative checks and rollback boundaries before action, grounded in the supplied evidence.","steps":["Validate primary and alternative evidence","Stress-test assumptions","Define rollback","Execute only after the evidence gate"],"benefits":["Higher confidence","Stronger rollback boundary"],"tradeoffs":{"speed":35,"cost":75,"reliability":92},"risk":"Slower execution","evidence":combined_evidence[:16],"evidence_basis":evidence_note},
        ]
