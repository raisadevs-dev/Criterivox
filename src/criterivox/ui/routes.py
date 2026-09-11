"""Browser-facing UI routes plus Home 03 Syvax gateway endpoints."""
from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from ..application.syvax import syvax_engine

router=APIRouter(); templates=Jinja2Templates(directory='src/criterivox/ui/templates')
@router.get('/',response_class=HTMLResponse)
def home(request:Request):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':'Criterivox'})
@router.get('/home-03',response_class=HTMLResponse)
def home03(request:Request):return templates.TemplateResponse(request=request,name='home03.html',context={'request':request,'title':'Home 03 · Syvax Gateway'})
@router.get('/settings',response_class=HTMLResponse)
def settings_page(request:Request):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':'Criterivox Settings'})
@router.post('/api/syvax/plan')
async def syvax_plan(payload:dict):
    message=payload.get('message') if isinstance(payload,dict) else None
    if not isinstance(message,str) or not message.strip() or len(message)>2000:return JSONResponse({'error':'A message between 1 and 2000 characters is required.'},status_code=400)
    safety=syvax_engine.safety_check(message)
    if safety.status=='blocked':return JSONResponse({'safety':{'status':safety.status,'reasons':safety.reasons}},status_code=422)
    plan=syvax_engine.compile_plan(message,payload.get('task_id'));syvax_engine.record_trace(plan.task_id,'human','Syvax',plan.intent.confidence,'intent extraction')
    for a,b in zip(plan.steps,plan.steps[1:]):syvax_engine.record_trace(plan.task_id,a.actor,b.actor,plan.intent.confidence,b.capability)
    return {'safety':{'status':safety.status,'reasons':safety.reasons},'plan':{'task_id':plan.task_id,'created_at':plan.created_at,'intent':plan.intent.__dict__,'steps':[s.__dict__ for s in plan.steps]}}
@router.post('/api/syvax/steer')
async def syvax_steer(payload:dict):
    try:return syvax_engine.steer(str(payload.get('task_id','')),str(payload.get('correction','')))
    except (KeyError,ValueError) as exc:return JSONResponse({'error':str(exc)},status_code=400)
@router.post('/api/syvax/oversight')
async def syvax_oversight(payload:dict):
    try:return {'type':'MODE_SWITCH','mode':syvax_engine.set_oversight(str(payload.get('mode','')))}
    except ValueError as exc:return JSONResponse({'error':str(exc)},status_code=400)
@router.post('/api/syvax/budget')
async def syvax_budget(payload:dict):
    try:return {'type':'SET_COMPUTE_LIMIT','home':payload.get('home'),'limit':syvax_engine.set_budget(str(payload.get('home','')),int(payload.get('limit',1)))}
    except (KeyError,ValueError,TypeError) as exc:return JSONResponse({'error':str(exc)},status_code=400)
def placeholder_page(request:Request,page_name:str):return templates.TemplateResponse(request=request,name='home.html',context={'request':request,'title':f'Criterivox {page_name}'})
def _register_placeholder(page_name:str)->None:router.add_api_route(f'/{page_name}',lambda request,_page_name=page_name:placeholder_page(request,_page_name),methods=['GET'],response_class=HTMLResponse,name=f'{page_name}_page')
for _page in ('workspace','data','intelligence','explanations','experiments','knowledge'): _register_placeholder(_page)
