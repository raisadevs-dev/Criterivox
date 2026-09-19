from __future__ import annotations
from criterivox.application.conversation import ConversationInterpretation
from criterivox.application.state_runtime import state_runtime
from criterivox.domain.state_awareness import SituationLevel

def respond_state_query(task_id:str, interpretation:ConversationInterpretation)->tuple[str,dict]:
    mapping={"history":SituationLevel.HISTORY,"current":SituationLevel.CURRENT,"next":SituationLevel.NEXT,"status":SituationLevel.CURRENT}
    level=mapping.get(interpretation.intent,SituationLevel.CURRENT)
    situation=state_runtime.situation(task_id,level);d=situation.to_dict()
    if situation.status=="NO_AUTHORITATIVE_RECORD":
        return "No authoritative runtime record exists for that state.",d
    if level is SituationLevel.HISTORY:
        lines=[f"{x['timestamp']}: {x['type']} ({x['actor']})" for x in d["history"]]
        return "Recorded history:\n" + "\n".join(lines),d
    if level is SituationLevel.CURRENT:
        c=d["current"]
        text=f"The latest checkpoint records state {c['state']} at step {c.get('active_step') or c.get('step') or 'UNKNOWN'}."
        if c.get("character"):text+=f" Responsible character: {c['character']}."
        if c.get("capability"):text+=f" Active capability: {c['capability']}."
        if d.get("blocking"):text+=f" Blocking condition: {d['blocking']}."
        return text,d
    n=d["next"];return f"Next-state classification: {n['type']}. {n['description']}",d
