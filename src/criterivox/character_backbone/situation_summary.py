from __future__ import annotations
from dataclasses import dataclass
from typing import Any
@dataclass(frozen=True, slots=True)
class SituationSummary:
 completed:tuple[str,...]=(); current:str|None=None; blocked:str|None=None; changed:tuple[str,...]=(); next:str|None=None; active_responsibility:str|None=None; human_input:str|None=None
 def text(self)->str:
  parts=[]
  if self.completed: parts.append("Completed: "+", ".join(self.completed)+".")
  if self.current: parts.append("Currently: "+self.current+".")
  if self.blocked: parts.append("Blocked: "+self.blocked+".")
  if self.changed: parts.append("Changed: "+", ".join(self.changed)+".")
  if self.next: parts.append("Next recorded step: "+self.next+".")
  if self.active_responsibility: parts.append("Responsible: "+self.active_responsibility+".")
  if self.human_input: parts.append("Human input required: "+self.human_input+".")
  return " ".join(parts) if parts else "No authoritative runtime state is available."
def summarize(checkpoint:dict[str,Any]|None, events:list[dict[str,Any]]=())->SituationSummary:
 if not checkpoint: return SituationSummary()
 return SituationSummary(tuple(checkpoint.get("completed_steps",())),checkpoint.get("active_step") or checkpoint.get("current_step"),checkpoint.get("blocked_reason") or checkpoint.get("waiting_for"),tuple(e.get("type",e.get("event_type","")) for e in events if e.get("new_state")=="CHANGED"),(checkpoint.get("remaining_steps") or [None])[0],checkpoint.get("active_character") or checkpoint.get("active_capability"),checkpoint.get("waiting_for"))
