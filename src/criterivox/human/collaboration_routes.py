"""HTTP boundary for the Gate 2 collaboration runtime."""
from fastapi import APIRouter
from fastapi.responses import JSONResponse
from .collaboration_engine import collaboration_engine
from ..application.syvax import syvax_engine

router=APIRouter(prefix="/api/collaboration",tags=["collaboration"])
def _error(e):
    if isinstance(e,KeyError):return JSONResponse({"accepted":False,"error":str(e)},status_code=404)
    if isinstance(e,PermissionError):return JSONResponse({"accepted":False,"error":str(e)},status_code=403)
    if isinstance(e,ValueError):return JSONResponse({"accepted":False,"error":str(e)},status_code=400)
    return JSONResponse({"accepted":False,"error":str(e)},status_code=500)
@router.post("/session")
async def create_session(payload:dict):return {"accepted":True,**collaboration_engine.create(str(payload.get("residence_id","")),str(payload.get("owner_id","")),str(payload.get("owner_name","House Owner")))}
@router.get("/session/{session_id}")
async def get_session(session_id:str,actor:str=""):
    try:
        result=collaboration_engine.snapshot(session_id,actor)
        if result["role"]=="guest":
            s=result["session"];s["votes"]={"Option A":"MASKED","Option B":"MASKED","Option C":"MASKED"};s["candidate_context"]=[];s["context_diffs"]=[];s["challenges"]=[];s["signatures"]={};s["outcomes"]=[];result["authoritative_context"]=[];result["dispatch"]={"unlocked":False,"execution_boundary":"Bodhex","reason":"guest_cannot_execute"};result["permissions"]=["comment","read"]
        return {"accepted":True,**result}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/members")
async def add_member(session_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.add_member(session_id,str(payload.get("actor","")),str(payload.get("display_name","")),str(payload.get("role","resident")),payload.get("member_id"))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/configure")
async def configure(session_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.configure(session_id,str(payload.get("actor","")),risk_level=payload.get("risk_level"),required_signatories=payload.get("required_signatories"),visibility=payload.get("visibility"))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/comment")
async def comment(session_id:str,payload:dict):
    try:return {"accepted":True,"event":collaboration_engine.comment(session_id,str(payload.get("actor","")),str(payload.get("text","")),str(payload.get("visibility","PUBLIC_TO_ROOM")))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/classify")
async def classify(session_id:str,payload:dict):
    try:
        text=str(payload.get("text",""));plan=syvax_engine.compile_plan(text);candidate=collaboration_engine.classify_context(session_id,str(payload.get("actor","")),text,confirm=False,variable_type=str(payload.get("variable_type","constraint")));candidate["syvax"]["plan"]={"task_id":plan.task_id,"intent_type":plan.intent.intent_type,"goal":plan.intent.goal,"confidence":plan.intent.confidence,"entities":plan.intent.entities};return {"accepted":True,"candidate":candidate}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/context/{candidate_id}/confirm")
async def confirm_context(session_id:str,candidate_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.confirm_context(session_id,str(payload.get("actor","")),candidate_id,bool(payload.get("accepted",False)))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/vote")
async def vote(session_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.vote(session_id,str(payload.get("actor","")),str(payload.get("option","")))}
    except Exception as e:return _error(e)
@router.get("/session/{session_id}/consensus")
async def consensus(session_id:str):
    try:return {"accepted":True,**collaboration_engine.consensus(session_id)}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/challenge")
async def challenge(session_id:str,payload:dict):
    try:return {"accepted":True,"challenge":collaboration_engine.challenge(session_id,str(payload.get("actor","")),str(payload.get("text","")))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/sign/owner")
async def owner_sign(session_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.owner_sign(session_id,str(payload.get("actor","")),dict(payload.get("action",{})))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/sign/resident")
async def resident_sign(session_id:str,payload:dict):
    try:return {"accepted":True,**collaboration_engine.sign(session_id,str(payload.get("actor","")),dict(payload.get("action",{})))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/dispatch")
async def dispatch(session_id:str,payload:dict):
    try:return {"accepted":True,"dispatch":collaboration_engine.dispatch(session_id,str(payload.get("actor","")),dict(payload.get("action",{})))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/outcome")
async def outcome(session_id:str,payload:dict):
    try:return {"accepted":True,"outcome":collaboration_engine.outcome(session_id,str(payload.get("actor","")),str(payload.get("result","")),str(payload.get("selected_option","")),list(payload.get("contributors",[])))}
    except Exception as e:return _error(e)
@router.post("/session/{session_id}/learning-proposal")
async def learning_proposal(session_id:str,payload:dict):
    try:return {"accepted":True,"proposal":collaboration_engine.learning_proposal(session_id,str(payload.get("actor","")),str(payload.get("outcome_id","")))}
    except Exception as e:return _error(e)
@router.post("/learning-proposal/{proposal_id}/approve")
async def approve_learning(proposal_id:str,payload:dict):
    try:return {"accepted":True,"proposal":collaboration_engine.approve_learning(proposal_id,str(payload.get("actor","")))}
    except Exception as e:return _error(e)
