from __future__ import annotations
from dataclasses import dataclass
import re
from typing import Any

@dataclass(frozen=True, slots=True)
class LanguageResult:
    raw_text: str
    normalized_text: str
    intent: str
    entities: dict[str, Any]
    target: str | None
    requested_output: str | None
    confidence: float
    ambiguous: bool
    clarification: str | None = None
    source: str = "deterministic"

_INTENTS = (
    ("QUERY_PAST_STATE", ("what happened", "show history", "what changed")),
    ("QUERY_CURRENT_STATE", ("what is happening", "where are we", "current status", "who is working")),
    ("QUERY_NEXT_STATE", ("what happens next", "what's next", "what remains", "waiting for")),
    ("EXPLAIN", ("why", "explain", "show the evidence", "provenance")),
    ("PAUSE", ("pause",)),
    ("RESUME", ("resume", "continue")),
    ("STOP", ("stop", "cancel")),
    ("RETRY", ("retry",)),
    ("CHANGE_REQUIREMENT", ("change the requirement", "change the goal", "change the constraint")),
    ("CHALLENGE", ("challenge", "stress test", "red team")),
    ("SHOW_OPTIONS", ("show options", "compare options", "review the plan")),
    ("RECOMMEND", ("recommend",)),
    ("ACCEPT", ("accept", "approve", "authorize")),
    ("REJECT", ("reject", "deny")),
    ("MODIFY", ("modify",)),
    ("PREPARE_ACTION", ("prepare action", "show action", "check authorization")),
    ("EXECUTE", ("execute", "run the action")),
    ("VERIFY", ("verify", "did it actually happen", "check the result")),
    ("SHOW_PROVENANCE", ("show provenance", "where did this come from")),
    ("KNOWLEDGE", ("what did we learn", "can this be reused", "is this verified")),
    ("CAPABILITY_DISCOVERY", ("what can you do", "what capability handles this")),
    ("HANDOFF", ("handoff", "pass this to")),
)

_CHARACTERS = {
    "syvax":"syvax","gateway":"syvax","dharen":"dharen","sandre":"sandre","kaelen":"kaelen",
    "anuka":"anuka","vivren":"vivren","tarkis":"tarkis","pramon":"pramon","bodhex":"bodhex",
    "medrus":"medrus","epistre":"epistre","veridat":"veridat","manis":"manis","viveda":"viveda","anukor":"anukor",
}

def normalize(text:str)->str:
    return re.sub(r"\s+"," ", text.strip().casefold())

def interpret(text:str)->LanguageResult:
    raw=text or ""
    normalized=normalize(raw)
    matches=[(intent,phrase) for intent,phrases in _INTENTS for phrase in phrases if phrase in normalized]
    unique=[]
    for intent,_ in matches:
        if intent not in unique: unique.append(intent)
    intent=unique[0] if unique else "GENERAL_REQUEST"
    ambiguous=len(unique)>1
    entities={}
    target=None
    for alias,cid in _CHARACTERS.items():
        if re.search(rf"\b{re.escape(alias)}\b",normalized):
            target=cid
            entities["character"]=cid
            break
    task=re.search(r"\b(?:task|journey)\s*[:#]?\s*([A-Za-z0-9_-]+)",raw,re.I)
    if task: entities["task_id"]=task.group(1)
    requested_output={"QUERY_PAST_STATE":"history","QUERY_CURRENT_STATE":"status","QUERY_NEXT_STATE":"next","VERIFY":"verification","SHOW_PROVENANCE":"provenance"}.get(intent)
    clarification=None
    if ambiguous: clarification=f"Multiple intents matched: {', '.join(unique)}. Please clarify the requested operation."
    confidence=0.95 if matches and not ambiguous else (0.65 if matches else 0.35)
    return LanguageResult(raw,normalized,intent,entities,target,requested_output,confidence,ambiguous,clarification)
