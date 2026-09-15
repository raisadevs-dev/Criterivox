from __future__ import annotations
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from .orchestrator import ReasoningResearchBureau
from .inspection import enrich_snapshot, compare_branches
from .mechanisms import mechanism_registry
router=APIRouter(prefix='/api/s7',tags=['s7-reasoning-research-bureau']); bureau=ReasoningResearchBureau()
def view(session_id:str): return enrich_snapshot(bureau.snapshot(session_id))
@router.get('/health')
def health(): return {'bureau':'Reasoning Research Bureau','status':'ready','standalone':True}
@router.get('/mechanisms')
def mechanisms(): return {'mechanisms':[{'mechanism_id':m.mechanism_id,'name':m.name,'classification':m.classification,'purpose':m.purpose,'provenance':m.provenance,'limitations':m.limitations} for m in mechanism_registry()]}
@router.post('/sessions')
def create_session(payload:dict):
    try: return view(bureau.start(str(payload.get('task','')),payload.get('context') if isinstance(payload.get('context'),dict) else {}).session_id)
    except ValueError as exc: return JSONResponse({'accepted':False,'error':str(exc)},status_code=400)
@router.get('/sessions/{session_id}')
def get_session(session_id:str):
    try:return view(session_id)
    except ValueError as exc:return JSONResponse({'accepted':False,'error':str(exc)},status_code=404)
@router.get('/sessions/{session_id}/branches')
def branches(session_id:str):
    try:return compare_branches(view(session_id))
    except ValueError as exc:return JSONResponse({'accepted':False,'error':str(exc)},status_code=404)
@router.get('/sessions/{session_id}/artifacts/{artifact_id}/lineage')
def artifact_lineage(session_id:str,artifact_id:str):
    try:
        s=view(session_id); item=s.get('lineage',{}).get(artifact_id)
        if not item:return JSONResponse({'accepted':False,'error':'Unknown analytical artifact.'},status_code=404)
        return {'artifact':next(a for a in s['artifacts'] if a['artifact_id']==artifact_id),'lineage':item,'provenance':s.get('provenance',{}).get(artifact_id,{})}
    except ValueError as exc:return JSONResponse({'accepted':False,'error':str(exc)},status_code=404)
@router.post('/sessions/{session_id}/intervene')
def intervene(session_id:str,payload:dict):
    try:return view(bureau.intervene(session_id,str(payload.get('artifact_id','')),str(payload.get('action','')),str(payload.get('instruction',''))).session_id)
    except ValueError as exc:return JSONResponse({'accepted':False,'error':str(exc)},status_code=400)
@router.post('/sessions/{session_id}/challenge')
def challenge(session_id:str,payload:dict):
    try:return view(bureau.challenge(session_id,str(payload.get('artifact_id','')),str(payload.get('challenge',''))).session_id)
    except ValueError as exc:return JSONResponse({'accepted':False,'error':str(exc)},status_code=400)
@router.websocket('/ws')
async def control_websocket(websocket:WebSocket):
    await websocket.accept(); await websocket.send_json({'type':'connected','bureau':'Reasoning Research Bureau','protocol':'s7-live-control-v2'})
    try:
        while True:
            m=await websocket.receive_json(); t=str(m.get('type','')).lower()
            if t=='ping': await websocket.send_json({'type':'pong','bureau':'Reasoning Research Bureau'})
            elif t=='subscribe':
                try: await websocket.send_json({'type':'subscribed','session':view(str(m.get('session_id','')))})
                except ValueError as exc: await websocket.send_json({'type':'error','error':str(exc)})
            elif t=='intervene':
                try: await websocket.send_json({'type':'session_updated','session':view(bureau.intervene(str(m.get('session_id','')),str(m.get('artifact_id','')),str(m.get('action','')),str(m.get('instruction',''))).session_id)})
                except ValueError as exc: await websocket.send_json({'type':'error','error':str(exc)})
            else: await websocket.send_json({'type':'control_ack','accepted':False,'reason':'Unsupported control message'})
    except WebSocketDisconnect:return
