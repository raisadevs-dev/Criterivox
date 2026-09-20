from __future__ import annotations
from dataclasses import dataclass
import re
from pathlib import Path
from typing import Any
try:
 import yaml
except ImportError:
 yaml=None

@dataclass(frozen=True, slots=True)
class LanguageResult:
 raw_text:str; normalized_text:str; intent:str; entities:dict[str,Any]; target:str|None
 requested_output:str|None; confidence:float; ambiguous:bool; clarification:str|None=None
 source:str="deterministic"; detected_language:str="en"; response_language:str="en"; language_confidence:float=1.0

_INTENTS=(
("QUERY_PAST_STATE",("what happened","show history","what changed")),("QUERY_CURRENT_STATE",("what is happening","where are we","current status","who is working")),("QUERY_NEXT_STATE",("what happens next","what's next","what remains","waiting for")),("EXPLAIN",("why","explain","show the evidence","provenance")),("PAUSE",("pause",)),("RESUME",("resume","continue")),("STOP",("stop","cancel")),("RETRY",("retry",)),("CHANGE_REQUIREMENT",("change the requirement","change the goal","change the constraint")),("CHALLENGE",("challenge","stress test","red team")),("SHOW_OPTIONS",("show options","compare options","review the plan")),("RECOMMEND",("recommend",)),("ACCEPT",("accept","approve","authorize")),("REJECT",("reject","deny")),("MODIFY",("modify",)),("PREPARE_ACTION",("prepare action","show action","check authorization")),("EXECUTE",("execute","run the action")),("VERIFY",("verify","did it actually happen","check the result")),("SHOW_PROVENANCE",("show provenance","where did this come from")),("KNOWLEDGE",("what did we learn","can this be reused","is this verified")),("CAPABILITY_DISCOVERY",("what can you do","what capability handles this")),("HANDOFF",("handoff","pass this to")),
)
_CHARACTERS={"syvax":"syvax","gateway":"syvax","dharen":"dharen","sandre":"sandre","kaelen":"kaelen","anuka":"anuka","vivren":"vivren","tarkis":"tarkis","pramon":"pramon","bodhex":"bodhex","medrus":"medrus","epistre":"epistre","veridat":"veridat","manis":"manis","viveda":"viveda","anukor":"anukor"}

def normalize(text:str)->str:return re.sub(r"\s+"," ",text.strip().casefold())

def _resource_intents(lang:str)->dict[str,tuple[str,...]]:
 path=Path(__file__).resolve().parents[3]/"configs"/"character_chat"/f"intent_phrases.{lang}.yaml"
 if not path.exists() or yaml is None:return {}
 try:
  data=yaml.safe_load(path.read_text(encoding="utf-8")) or {}
  return {k:tuple(v) for k,v in (data.get("intents") or {}).items()}
 except Exception:return {}

def _detect(text:str)->tuple[str,float]:
 n=normalize(text)
 if re.search(r"[\u0900-\u097F]",n):
  mr=sum(x in n for x in ("आत्ता","चालले","काय","पुढे","गरज","अट","कृती","आपण","शिकलो","का"))
  hi=sum(x in n for x in ("क्या","हुआ","अभी","आगे","आवश्यकता","कार्रवाई","हमने","दिखाओ","सत्यापित"))
  return ("mr",0.90) if mr>hi else ("hi",0.90 if hi>mr else 0.55)
 return "en",0.99

def interpret(text:str)->LanguageResult:
 raw=text or ""; normalized=normalize(raw); lang,lang_conf=_detect(raw); resources=_resource_intents(lang)
 matches=[(i,p) for i,ps in (resources.items() if resources else _INTENTS) for p in ps if p in normalized]
 if lang!="en": matches += [(i,p) for i,ps in _INTENTS for p in ps if p in normalized]
 unique=[]
 for i,_ in matches:
  if i not in unique: unique.append(i)
 intent=unique[0] if unique else "GENERAL_REQUEST"; ambiguous=len(unique)>1
 entities={}; target=None
 for alias,cid in _CHARACTERS.items():
  if re.search(rf"\b{re.escape(alias)}\b",normalized): target=cid; entities["character"]=cid; break
 task=re.search(r"\b(?:task|journey)\s*[:#]?\s*([A-Za-z0-9_-]+)",raw,re.I)
 if task: entities["task_id"]=task.group(1)
 requested={"QUERY_PAST_STATE":"history","QUERY_CURRENT_STATE":"status","QUERY_NEXT_STATE":"next","VERIFY":"verification","SHOW_PROVENANCE":"provenance"}.get(intent)
 clarification=None
 if ambiguous:
  clarification={"hi":"एक से अधिक अनुरोध मिले। कृपया एक ऑपरेशन स्पष्ट करें।","mr":"एकापेक्षा अधिक विनंत्या आढळल्या। कृपया एक कृती स्पष्ट करा।"}.get(lang,"Multiple intents matched. Please clarify the requested operation.")
 confidence=0.95 if matches and not ambiguous else 0.65 if matches else 0.35
 return LanguageResult(raw,normalized,intent,entities,target,requested,confidence,ambiguous,clarification,"deterministic",lang,lang,lang_conf)
