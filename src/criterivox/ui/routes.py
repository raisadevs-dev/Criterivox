"""Browser-facing UI routes and Home 03 interaction APIs."""
from fastapi import APIRouter,Request
from fastapi.responses import HTMLResponse,JSONResponse
from fastapi.templating import Jinja2Templates
import base64,binascii,hashlib,json,time
from ..application.syvax import syvax_engine
from ..application.bloom import bloom_controller
from ..application.home03_services import home03_services
from ..application.home03_store import home03_store
from ..application.home03_bridge import install as install_home03_bridge
from ..infrastructure.runtime import runtime_connections
install_home03_bridge(runtime_connections)
router=APIRouter();templates=Jinja2Templates(directory='src/criterivox/ui/templates')
@router.get('/',response_class=HTMLResponse)
def home(request:Request):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':'Criterivox'})
@router.get('/settings',response_class=HTMLResponse)
def settings_page(request:Request):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':'Criterivox Settings'})
@router.get('/home-03',response_class=HTMLResponse)
def home03(request:Request):return templates.TemplateResponse(request=request,name='home03.html',context={'request':request,'title':'Home 03 • Syvax + The Bloom'})
def placeholder_page(request,page_name):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':f'Criterivox {page_name}'})
def _register_placeholder(page_name):router.add_api_route(f'/{page_name}',lambda request,_page_name=page_name:placeholder_page(request,_page_name),methods=['GET'],response_class=HTMLResponse,name=f'{page_name}_page')
for _page in ('workspace','data','intelligence','explanations','experiments','knowledge'):_register_placeholder(_page)
def _plan_payload(plan):return {'task_id':plan.task_id,'intent':{'goal':plan.intent.goal,'intent_type':plan.intent.intent_type,'confidence':plan.intent.confidence,'entities':plan.intent.entities},'steps':[step.__dict__ for step in plan.steps],'created_at':plan.created_at}
@router.post('/api/syvax/plan')
async def syvax_plan(payload:dict):
 message=str(payload.get('message','')).strip();safety=syvax_engine.safety_check(message)
 if safety['status']=='blocked':return JSONResponse({'safety':safety,'plan':None},status_code=422)
 plan=syvax_engine.compile_plan(message,payload.get('task_id'));return {'safety':safety,'plan':_plan_payload(plan),'candidate':syvax_engine.candidate_route(plan)}
@router.post('/api/syvax/replan')
async def syvax_replan(payload:dict):
 plan=syvax_engine.compile_plan(str(payload.get('message','')),str(payload.get('task_id','')) or None);return syvax_engine.revise_from_runtime(plan,dict(payload.get('runtime_event',{})))
@router.post('/api/syvax/dispatch')
async def syvax_dispatch(payload:dict):
 message=str(payload.get('message','')).strip();safety=syvax_engine.safety_check(message)
 if safety['status']=='blocked':return JSONResponse({'safety':safety,'plan':None},status_code=422)
 plan=syvax_engine.compile_plan(message,payload.get('task_id'));result=home03_services.dispatch(message,plan.task_id);return {'safety':safety,'plan':_plan_payload(plan),'candidate':syvax_engine.candidate_route(plan),'adaptive':result,'dispatched':True,'execution_status':'control_plane_accepted'}
@router.post('/api/syvax/steer')
async def syvax_steer(payload:dict):return {**syvax_engine.steer(str(payload.get('task_id','')),str(payload.get('correction',''))),'runtime':home03_services.suspend(str(payload.get('task_id','')),str(payload.get('correction','')))}
@router.post('/api/syvax/resume')
async def syvax_resume(payload:dict):return home03_services.resume(str(payload.get('task_id','')))
@router.post('/api/syvax/intervention')
async def syvax_intervention(payload:dict):return home03_services.intervene(str(payload.get('task_id','')),str(payload.get('action','')),dict(payload.get('diff',{})))
@router.post('/api/syvax/render')
async def syvax_render(payload:dict):return home03_services.render(str(payload.get('text','')),str(payload.get('intent','general')),str(payload.get('mode','')))
@router.post('/api/syvax/oversight')
async def syvax_oversight(payload:dict):return {'mode':syvax_engine.set_mode(str(payload.get('mode','HITL')))}
@router.post('/api/syvax/budget')
async def syvax_budget(payload:dict):return {'home':str(payload.get('home','')),'budget':syvax_engine.set_budget(str(payload.get('home','')),int(payload.get('budget',100)))}
@router.get('/api/home03/runtime')
async def home03_runtime_state():return home03_services.snapshot()
@router.post('/api/home03/runtime-event')
async def home03_runtime_event(payload:dict):
 result=home03_services.ingest_runtime_event(payload);plan=syvax_engine.compile_plan(str(payload.get('goal',payload.get('message','runtime event'))),str(payload.get('task_id','')) or None);result['replan']=syvax_engine.revise_from_runtime(plan,payload);return result
@router.post('/api/home03/consume')
async def home03_consume(payload:dict):return {'remaining':home03_services.consume(str(payload.get('task_id','')),str(payload.get('home','')),int(payload.get('cost',1)))}
@router.post('/api/home03/conversation/{conversation_id}/message')
async def conversation_message(conversation_id,payload):
 branch=str(payload.get('branch_id','main'));mid=home03_store.message(conversation_id,branch,str(payload.get('role','user')),str(payload.get('content','')),dict(payload.get('metadata',{})));return {'message_id':mid,'tree':home03_store.tree(conversation_id)}
@router.get('/api/home03/conversation/{conversation_id}/tree')
async def conversation_tree(conversation_id):return home03_store.tree(conversation_id)
@router.post('/api/home03/conversation/{conversation_id}/branch')
async def conversation_branch(conversation_id,payload):
 bid=str(payload.get('branch_id') or f'branch-{int(time.time()*1000)}');return {'branch_id':home03_store.branch(bid,conversation_id,int(payload.get('parent_message',0)),str(payload.get('name','New branch')),dict(payload.get('state',{})))}
@router.post('/api/home03/checkpoint')
async def home03_checkpoint(payload):
 state=dict(payload.get('state',{}));h=hashlib.sha256(json.dumps(state,sort_keys=True,default=str).encode()).hexdigest();cid=home03_store.checkpoint(str(payload.get('conversation_id','default')),str(payload.get('branch_id','main')),state,h);return {'checkpoint_id':cid,'state_hash':h}
@router.post('/api/home03/replay')
async def home03_replay(payload):return home03_services.restore(str(payload.get('checkpoint_id','')))
@router.post('/api/home03/fork')
async def home03_fork(payload):return home03_services.fork(str(payload.get('checkpoint_id','')),str(payload.get('name','Replay branch')))
@router.post('/api/home03/ingest')
async def home03_ingest(payload):
 name=str(payload.get('filename','upload'));encoded=str(payload.get('content_base64',''))
 try:data=base64.b64decode(encoded,validate=True)
 except (ValueError,binascii.Error):return JSONResponse({'accepted':False,'error':'content_base64 is invalid'},status_code=400)
 if len(data)>8*1024*1024:return JSONResponse({'accepted':False,'error':'8 MB upload limit exceeded'},status_code=413)
 cid=str(payload.get('collection_id') or f'home03-{abs(hash(name))}');source={'name':name,'source_type':'file','channel':'home03-universal-dropzone','collection_id':cid,'content':data.decode('utf-8',errors='replace')}
 from ..application.data_foundation_store import data_foundations
 foundation=data_foundations.ingest({'sources':[source],'collection_id':cid,'supplied_context':{'entered_through':'Home 03 Universal Dropzone','content_type':payload.get('content_type')}})
 return {'accepted':True,'filename':name,'size':len(data),'foundation_id':foundation.foundation_id,'forward_target':'Sandre/Data Foundation'}
@router.get('/api/bloom/state')
async def bloom_state():return bloom_controller.state()
@router.post('/api/bloom/mode')
async def bloom_mode(payload):return {'mode':bloom_controller.set_mode(str(payload.get('mode','HITL')))}
@router.post('/api/bloom/budget')
async def bloom_budget(payload):return {'home':str(payload.get('home','')),'budget':bloom_controller.set_budget(str(payload.get('home','')),int(payload.get('budget',100)))}
@router.post('/api/bloom/checkpoint')
async def bloom_checkpoint(payload):return bloom_controller.checkpoint(str(payload.get('task_id','unknown')),dict(payload.get('state',{})))
@router.post('/api/bloom/trace')
async def bloom_trace(payload):return bloom_controller.evaluate(str(payload.get('task_id','unknown')),str(payload.get('source','')),str(payload.get('target','')),float(payload.get('score',1)),reason=str(payload.get('reason','')))
