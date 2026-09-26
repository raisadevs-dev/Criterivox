
"""Browser-facing UI routes and Home 03 interaction APIs."""
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
import json
import base64,binascii,hashlib,json,time
from ..application.syvax import syvax_engine
from ..application.bloom import bloom_controller
from ..application.home03_services import home03_services
from ..application.home03_store import home03_store
from ..application.home03_bridge import install as install_home03_bridge
from ..application.human_residence_store import human_residences
from ..application.human_residence_local_store import human_residence_local
from ..human.guest_pass import GuestPassManager
from ..human.collaboration_routes import router as collaboration_router
from ..infrastructure.runtime import runtime_connections
install_home03_bridge(runtime_connections)
router=APIRouter();router.include_router(collaboration_router);guest_passes=GuestPassManager()
def _plan_payload(plan):return {'task_id':plan.task_id,'intent':{'goal':plan.intent.goal,'intent_type':plan.intent.intent_type,'confidence':plan.intent.confidence,'entities':plan.intent.entities},'steps':[step.__dict__ for step in plan.steps],'created_at':plan.created_at}

@router.post('/api/human-auth/signup')
async def human_auth_signup(payload: dict):
    try:
        result = human_residence_local.signup(email=str(payload.get('email','')), password=str(payload.get('password','')), display_name=str(payload.get('display_name','')), residence_id=str(payload.get('residence_id','')), residence_type=str(payload.get('residence_type','private')), avatar_data_url=payload.get('avatar_data_url'))
        return {'accepted': True, 'identity': result, 'session_token': human_residence_local.issue_session(result['owner_id']), 'residences': human_residence_local.residences_for_owner(result['owner_id']), 'storage': 'local-sqlite'}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

@router.post('/api/human-auth/login')
async def human_auth_login(payload: dict):
    try:
        result = human_residence_local.login(email=str(payload.get('email','')), password=str(payload.get('password','')))
        return {'accepted': True, 'identity': result, 'session_token': human_residence_local.issue_session(result['owner_id']), 'residences': human_residence_local.residences_for_owner(result['owner_id']), 'storage': 'local-sqlite'}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=401)

@router.post('/api/human-auth/profile')
async def human_auth_profile(payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token','')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        return {'accepted': True, 'identity': human_residence_local.update_profile(owner_id=owner_id, display_name=payload.get('display_name'), avatar_data_url=payload.get('avatar_data_url'), role=payload.get('role'))}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

@router.post('/api/human-decisions')
async def human_decision_save(payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token','')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    decision = human_residence_local.save_decision(owner_id=owner_id, residence_id=str(payload.get('residence_id','')), title=str(payload.get('title','Criterivox Strategy')), goal=str(payload.get('goal','')), strategy=dict(payload.get('strategy',{})), trace=list(payload.get('trace',[])))
    return {'accepted': True, 'decision': decision, 'storage': 'local-sqlite'}

@router.post('/api/human-residence/decision/{decision_id}/challenge')
async def human_decision_challenge(decision_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token', '')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        event = human_residence_local.record_decision_event(
            decision_id=decision_id,
            owner_id=owner_id,
            event_type='challenge',
            payload={'text': str(payload.get('text', '')).strip(), 'actor': 'human'},
        )
        return {'accepted': True, 'event': event, 'response': {
            'actor': 'manis',
            'responsibility': 'challenge',
            'detail': 'Challenge recorded. Re-evaluation is required before acceptance.',
        }}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.post('/api/human-residence/decision/{decision_id}/accept')
async def human_decision_accept(decision_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token', '')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        event = human_residence_local.record_decision_event(
            decision_id=decision_id,
            owner_id=owner_id,
            event_type='accepted',
            payload={'calendar_at': payload.get('calendar_at'), 'action': payload.get('action', 'execute'), 'actor': 'human'},
        )
        return {'accepted': True, 'event': event, 'execution': {
            'status': 'ACCEPTED',
            'handler': 'bodhex',
            'calendar_at': payload.get('calendar_at'),
        }}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.post('/api/human-residence/decision/{decision_id}/outcome')
async def human_decision_outcome(decision_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token', '')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        event = human_residence_local.record_decision_event(
            decision_id=decision_id,
            owner_id=owner_id,
            event_type='outcome',
            payload={'result': str(payload.get('result', '')).strip(), 'actor': 'human'},
        )
        return {'accepted': True, 'event': event, 'learning': {
            'status': 'RECORDED_FOR_REVIEW',
            'reuse_policy': 'outcomes become evidence for future similar decisions after review; they are not blindly reused.',
        }}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.get('/api/human-residence/decision/{decision_id}/events')
async def human_decision_events(decision_id: str, session_token: str):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        return {'accepted': True, 'events': human_residence_local.decision_events(decision_id=decision_id, owner_id=owner_id)}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.get('/api/human-decisions')
async def human_decisions_list(session_token: str, query: str = ''):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    return {'accepted': True, 'decisions': human_residence_local.list_decisions(owner_id, query)}

@router.post('/api/service-layer/execute')
async def service_layer_execute(payload: dict):
    from ..service_layer import ServiceRequest, service_composer
    import uuid
    goal = str(payload.get('goal', '')).strip()
    if not goal:
        return JSONResponse({'accepted': False, 'error': 'goal is required'}, status_code=400)
    request = ServiceRequest(
        request_id=str(payload.get('request_id') or f'SVC-{time.time_ns()}'),
        goal=goal,
        supplied_data=str(payload.get('data', '')),
        context=str(payload.get('context', '')),
        session_id=str(payload.get('session_id', '')) or None,
        actor_id=str(payload.get('actor_id', 'human')),
        authorization=str(payload.get('authorization', 'human-review')),
    )
    try:
        plan, results = service_composer.execute(request)
        return {
            'accepted': True,
            'request': request.request_id,
            'plan': {'services': list(plan.services), 'rationale': list(plan.rationale)},
            'results': {
                name: {
                    'service_type': result.service_type,
                    'status': result.status,
                    'purpose': result.purpose,
                    'content': dict(result.content),
                    'structured_data': dict(result.structured_data),
                    'evidence_refs': list(result.evidence_refs),
                    'provenance_refs': list(result.provenance_refs),
                    'uncertainty': list(result.uncertainty),
                    'limitations': list(result.limitations),
                    'alternatives': list(result.alternatives),
                    'artifact_refs': list(result.artifact_refs),
                    'execution_ref': result.execution_ref,
                    'authorization_state': result.authorization_state,
                    'failure_reason': result.failure_reason,
                }
                for name, result in results.items()
            },
        }
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)
    except Exception as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=502)

@router.post('/api/work-materials/from-service')
async def work_material_from_service(payload: dict):
    from ..service_layer import ServiceRequest, service_composer
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token','')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    goal = str(payload.get('goal','')).strip()
    if not goal:
        return JSONResponse({'accepted': False, 'error': 'goal is required'}, status_code=400)
    request = ServiceRequest(
        request_id=str(payload.get('request_id') or f'SVC-{uuid.uuid4()}'),
        goal=goal,
        supplied_data=str(payload.get('data','')),
        context=str(payload.get('context','')),
        actor_id=owner_id,
        authorization='human-review',
    )
    try:
        plan, results = service_composer.execute(request)
        material_type = str(payload.get('material_type','')).strip()
        if material_type:
            candidates = {material_type: next((r for n,r in results.items() if n == material_type or r.service_type == material_type), None)}
        else:
            candidates = {
                'situation_brief': results.get('situation_understanding'),
                'evidence_package': results.get('evidence_data_analysis'),
                'analytical_report': results.get('analytical_reporting'),
                'reasoning_map': results.get('reasoning_hypothesis'),
                'strategy_set': results.get('strategy_construction'),
                'tradeoff_analysis': results.get('tradeoff_analysis'),
                'action_plan': results.get('planning'),
                'verification_explanation': results.get('verification_explanation'),
            }
        created=[]
        for kind,result in candidates.items():
            if result is None: continue
            material={
                'material_id': f'mat-{request.request_id}-{kind}',
                'material_type': kind,
                'title': {'situation_brief':'Situation Brief','evidence_package':'Evidence Package','analytical_report':'Analytical Report','reasoning_map':'Reasoning Map','strategy_set':'Strategy Set','tradeoff_analysis':'Trade-off Analysis','action_plan':'Action Plan','verification_explanation':'Verification & Explanation Package'}.get(kind, kind.replace('_',' ').title()),
                'purpose': result.purpose,
                'status': result.status,
                'source_service': result.service_type,
                'content': dict(result.content),
                'structured_data': dict(result.structured_data),
                'evidence_refs': list(result.evidence_refs),
                'provenance_refs': list(result.provenance_refs),
                'assumptions': list(result.assumptions),
                'uncertainty': list(result.uncertainty),
                'limitations': list(result.limitations),
                'editable_elements': list(result.editable),
                'challengeable_elements': list(result.challengeable),
                'dependencies': list(result.downstream_dependencies),
                'artifact_refs': list(result.artifact_refs),
                'execution_ref': result.execution_ref,
                'authorization_state': result.authorization_state,
                'history': [{'version': 1, 'source': result.service_type, 'status': result.status}],
            }
            created.append(human_residence_local.save_work_material(owner_id=owner_id, residence_id=str(payload.get('residence_id','')) or None, material=material))
        return {'accepted': True, 'request_id': request.request_id, 'plan': list(plan.services), 'materials': created}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)
    except Exception as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=502)

@router.get('/api/work-materials')
async def work_materials_list(session_token: str, material_type: str = ''):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    return {'accepted': True, 'materials': human_residence_local.list_work_materials(owner_id, material_type)}

@router.get('/api/work-materials/{material_id}/export')
async def work_material_export(material_id: str, session_token: str, format: str = 'json'):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None: return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    material=human_residence_local.get_work_material(material_id, owner_id)
    if material is None: return JSONResponse({'accepted': False, 'error': 'material_not_found'}, status_code=404)
    from fastapi.responses import Response
    if format.lower() == 'html':
        title=str(material.get('title','Criterivox Work Material'))
        body='<h1>'+title+'</h1><p>'+str(material.get('purpose',''))+'</p><h2>Status</h2><p>'+str(material.get('status',''))+'</p><h2>Content</h2><pre>'+json.dumps(material.get('content',{}),indent=2,default=str)+'</pre><h2>Limitations</h2><pre>'+json.dumps(material.get('limitations',[]),indent=2)+'</pre>'
        return Response('<!doctype html><html><body>'+body+'</body></html>',media_type='text/html',headers={'Content-Disposition': 'attachment; filename="criterivox-material-'+material_id+'.html"'})
    return Response(json.dumps(material,indent=2,default=str),media_type='application/json',headers={'Content-Disposition': 'attachment; filename="criterivox-material-'+material_id+'.json"'})

@router.get('/api/work-materials/{material_id}')
async def work_material_get(material_id: str, session_token: str):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    material=human_residence_local.get_work_material(material_id, owner_id)
    if material is None: return JSONResponse({'accepted': False, 'error': 'material_not_found'}, status_code=404)
    return {'accepted': True, 'material': material}

@router.post('/api/work-materials/{material_id}/challenge')
async def work_material_challenge(material_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token','')))
    if owner_id is None: return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        event=human_residence_local.record_material_event(material_id=material_id, owner_id=owner_id, event_type='challenge', payload={'text':str(payload.get('text','')).strip(),'actor':'human'})
        return {'accepted': True, 'event': event}
    except ValueError as exc: return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.post('/api/work-materials/{material_id}/change')
async def work_material_change(material_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token','')))
    if owner_id is None: return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        current=human_residence_local.get_work_material(material_id, owner_id)
        if current is None: raise ValueError('material not found')
        changed=dict(current); changed_fields=payload.get('changes',{})
        if not isinstance(changed_fields,dict): raise ValueError('changes must be an object')
        changed['content']=dict(changed.get('content',{}))
        changed['content'].update(changed_fields.get('content',{}))
        for field in ('assumptions','limitations'):
            if field in changed_fields: changed[field]=list(changed_fields[field])
        changed['status']='changed'
        changed['history']=list(changed.get('history',[]))+[{'version':int(current.get('version',1))+1,'source':'human','changed':list(changed_fields.keys())}]
        saved=human_residence_local.save_work_material(owner_id=owner_id,residence_id=current.get('residence_id'),material=changed)
        event=human_residence_local.record_material_event(material_id=material_id,owner_id=owner_id,event_type='change',payload={'changed_fields':list(changed_fields.keys()),'actor':'human'})
        return {'accepted': True, 'material': saved, 'event': event, 'recomputation': 'NOT_RUN'}
    except ValueError as exc: return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

@router.post('/api/human-situation/understand')
async def human_situation_understand(request: Request):
    from ..application.hybrid_input import normalize_human_situation

    content_type = request.headers.get('content-type', '').lower()
    payload: dict[str, object] = {}
    if 'application/json' in content_type:
        raw = await request.json()
        payload = raw if isinstance(raw, dict) else {'description': raw}
    elif 'multipart/form-data' in content_type or 'application/x-www-form-urlencoded' in content_type:
        form = await request.form()
        for key, value in form.multi_items():
            if hasattr(value, 'filename'):
                payload.setdefault('files', []).append({
                    'name': getattr(value, 'filename', ''),
                    'content_type': getattr(value, 'content_type', ''),
                    'size': len(await value.read()),
                })
            elif key in payload:
                existing = payload[key]
                payload[key] = [existing, value]
            else:
                payload[key] = value
    else:
        payload = {'description': (await request.body()).decode('utf-8', errors='replace')}

    description, supplied_data, context = normalize_human_situation(
        description=payload.get('description', ''),
        data=payload.get('data', ''),
        context=payload.get('context', ''),
    )
    if payload.get('files'):
        supplied_data = f"{supplied_data}\nAttached material: {payload['files']}".strip()

    try:
        from ..application.human_situation_orchestrator import human_situation_orchestrator
        image_roles = payload.get('image_roles', ())
        if isinstance(image_roles, str):
            image_roles = tuple(x.strip() for x in image_roles.split(',') if x.strip())
        elif isinstance(image_roles, (list, tuple)):
            image_roles = tuple(str(x) for x in image_roles if x)
        else:
            image_roles = ()
        result = human_situation_orchestrator.execute(
            description=description,
            session_token=str(payload.get('session_token', '')),
            residence_id=str(payload.get('residence_id', '')),
            image_count=int(payload.get('image_count', 0) or 0),
            image_roles=image_roles,
            supplied_data=supplied_data,
            context=context,
            allow_external_research=bool(payload.get('allow_external_research', False)),
        )
        return {'accepted': True, **result}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)
    except Exception as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=502)

@router.post('/api/human-residence/decision')
async def human_residence_decision(payload: dict):
    from ..application.decision_orchestrator import decision_orchestrator
    try:
        result = decision_orchestrator.execute(
            session_token=str(payload.get('session_token', '')),
            residence_id=str(payload.get('residence_id', '')),
            goal=str(payload.get('goal', '')),
            supplied_data=str(payload.get('data', '')),
            context=str(payload.get('context', '')),
            allow_external_research=bool(payload.get('allow_external_research', False)),
        )
        return {
            'accepted': True,
            'decision_id': result.decision_id,
            'strategy': result.strategy,
            'trace': result.trace,
            'research': result.research,
            'foundation_id': result.foundation_id,
        }
    except PermissionError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=401)
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)
    except Exception as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=502)

@router.get('/api/human-residence/calendar')
async def human_residence_calendar(session_token: str, from_at: str | None = None, to_at: str | None = None):
    owner_id = human_residence_local.owner_for_session(session_token)
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    return {'accepted': True, 'events': human_residence_local.list_calendar_events(owner_id, from_at=from_at, to_at=to_at)}

@router.post('/api/human-residence/calendar')
async def human_residence_calendar_create(payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token', '')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        event = human_residence_local.create_calendar_event(
            owner_id=owner_id,
            residence_id=str(payload.get('residence_id', '')),
            decision_id=str(payload.get('decision_id', '')),
            title=str(payload.get('title', 'Criterivox strategy')),
            starts_at=str(payload.get('starts_at', '')),
            ends_at=payload.get('ends_at'),
            strategy_id=payload.get('strategy_id'),
            notes=str(payload.get('notes', '')),
        )
        human_residence_local.record_decision_event(
            decision_id=event['decision_id'],
            owner_id=owner_id,
            event_type='scheduled',
            payload={'calendar_id': event['calendar_id'], 'starts_at': event['starts_at'], 'title': event['title']},
        )
        return {'accepted': True, 'event': event}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

@router.patch('/api/human-residence/calendar/{calendar_id}')
async def human_residence_calendar_update(calendar_id: str, payload: dict):
    owner_id = human_residence_local.owner_for_session(str(payload.get('session_token', '')))
    if owner_id is None:
        return JSONResponse({'accepted': False, 'error': 'invalid_session'}, status_code=401)
    try:
        return {'accepted': True, 'event': human_residence_local.update_calendar_event(
            calendar_id=calendar_id,
            owner_id=owner_id,
            status=payload.get('status'),
            starts_at=payload.get('starts_at'),
            ends_at=payload.get('ends_at'),
        )}
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=404)

@router.get('/api/human-residence/research/status')
async def human_residence_research_status():
    from ..application.external_research import google_research
    return {'provider': 'google-programmable-search', 'configured': google_research.configured}

@router.post('/api/human-residence/intake')
async def human_residence_intake(payload: dict):
    sources = payload.get('sources')
    if not isinstance(sources, list) or not sources:
        return JSONResponse({'accepted': False, 'error': 'at least one source is required'}, status_code=400)
    try:
        from ..application.data_foundation_store import data_foundations
        foundation = data_foundations.ingest({
            'sources': sources[:50],
            'collection_id': payload.get('collection_id'),
            'supplied_context': {
                'entered_through': 'Human Residence',
                **dict(payload.get('supplied_context') or {}),
            },
        })
        return {'accepted': True, 'foundation_id': foundation.foundation_id, 'sources': [s.to_dict() for s in foundation.sources]}
    except (ValueError, TypeError) as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

@router.post('/api/human-residence')
async def human_residence(payload:dict):
 record=human_residences.upsert(dict(payload));return {'accepted':True,'residence':record,'storage':'python-local-mirror','browser_authority':'IndexedDB'}
@router.get('/api/human-residence/{residence_id}')
async def get_human_residence(residence_id:str):
 record=human_residences.get(residence_id)
 if record is None:return JSONResponse({'accepted':False,'error':'residence_not_found'},status_code=404)
 return {'accepted':True,'residence':record,'storage':'python-local-mirror'}
@router.get('/api/human-residences/owner/{owner_id}')
async def owner_human_residences(owner_id:str):return {'accepted':True,'residences':human_residences.by_owner(owner_id),'storage':'python-local-mirror'}
@router.post('/api/guest-pass/session')
async def guest_session_create():
 session=guest_passes.create();return {'accepted':True,'session_id':session.session_id,'sandbox_status':'ISOLATED_EPHEMERAL_STATE','created_at':session.created_at.isoformat(),'expires_at':session.expires_at.isoformat(),'ttl_seconds':guest_passes.ttl_seconds,'persistent_storage':False}
@router.get('/api/guest-pass/session/{session_id}')
async def guest_session_get(session_id:str):
 session=guest_passes.get(session_id)
 if session is None:return JSONResponse({'accepted':False,'error':'guest_session_expired'},status_code=410)
 return {'accepted':True,'session_id':session.session_id,'sandbox_status':'ISOLATED_EPHEMERAL_STATE','expires_at':session.expires_at.isoformat(),'trace':session.trace,'decisions':session.decisions}
@router.post('/api/guest-pass/session/{session_id}/input')
async def guest_session_input(session_id:str,payload:dict):
 try:session=guest_passes.update(session_id,goal=str(payload.get('goal','')).strip(),data=payload.get('data'),context=dict(payload.get('context',{})))
 except KeyError:return JSONResponse({'accepted':False,'error':'guest_session_expired'},status_code=410)
 return {'accepted':True,'session_id':session.session_id,'goal':session.goal,'missing_fields':[k for k,v in {'goal':session.goal,'data':session.data,'context':session.context}.items() if v in ('',None,{})]}
@router.post('/api/guest-pass/session/{session_id}/trace')
async def guest_session_trace(session_id:str,payload:dict):
 if guest_passes.get(session_id) is None:return JSONResponse({'accepted':False,'error':'guest_session_expired'},status_code=410)
 guest_passes.append_trace(session_id,dict(payload));return {'accepted':True,'session_id':session_id,'trace':guest_passes.get(session_id).trace}
@router.post('/api/guest-pass/session/{session_id}/claim/prepare')
async def guest_session_claim_prepare(session_id:str):
 try:return {'accepted':True,'migratable':guest_passes.migratable(session_id),'vaporized_guest_session':False,'claim_status':'PREPARED'}
 except KeyError:return JSONResponse({'accepted':False,'error':'guest_session_expired'},status_code=410)
@router.post('/api/guest-pass/session/{session_id}/claim/commit')
async def guest_session_claim_commit(session_id:str):
 try:return {'accepted':True,'migratable':guest_passes.commit_claim(session_id),'vaporized_guest_session':True,'claim_status':'COMMITTED'}
 except KeyError:return JSONResponse({'accepted':False,'error':'guest_session_expired'},status_code=410)
@router.post('/api/guest-pass/session/{session_id}/claim')
async def guest_session_claim(session_id:str):return await guest_session_claim_commit(session_id)
@router.delete('/api/guest-pass/session/{session_id}')
async def guest_session_leave(session_id:str):
 removed=guest_passes.vaporize(session_id);return {'accepted':removed,'vaporized':removed,'persistent_storage':False}
@router.get('/api/guest-pass/status')
async def guest_pass_status():return {'active_ephemeral_sessions':guest_passes.active_count(),'ttl_seconds':guest_passes.ttl_seconds}
@router.post('/api/syvax/plan')
async def syvax_plan(payload:dict):
 prepared=syvax_engine.prepare(
  str(payload.get('message','')).strip(),
  payload.get('task_id'),
 )
 if prepared['safety']['status']=='blocked':
  return JSONResponse({'safety':prepared['safety'],'plan':None},status_code=422)
 return prepared
@router.post('/api/syvax/replan')
async def syvax_replan(payload:dict):
 plan=syvax_engine.compile_plan(str(payload.get('message','')),str(payload.get('task_id','')) or None);return syvax_engine.revise_from_runtime(plan,dict(payload.get('runtime_event',{})))
@router.post('/api/syvax/dispatch')
async def syvax_dispatch(payload:dict):
 message=str(payload.get('message','')).strip()
 prepared=syvax_engine.prepare(message,payload.get('task_id'))
 safety=prepared['safety']
 if safety['status']=='blocked':
  return JSONResponse({'safety':safety,'plan':None},status_code=422)
 plan=prepared['plan']
 candidate=prepared['candidate']
 if not candidate['validation']['valid']:
  return JSONResponse({'safety':safety,'plan':plan,'candidate':candidate,'dispatched':False},status_code=409)
 result=home03_services.dispatch(message,plan['task_id'],plan)
 return {'safety':safety,'plan':plan,'candidate':candidate,'adaptive':result,'dispatched':True,'execution_status':'control_plane_accepted'}
@router.post('/api/syvax/steer')
async def syvax_steer(payload:dict):return {**syvax_engine.steer(str(payload.get('task_id','')),str(payload.get('correction',''))),'runtime':home03_services.suspend(str(payload.get('task_id','')),str(payload.get('correction','')))}
@router.post('/api/syvax/resume')
async def syvax_resume(payload:dict):return home03_services.resume(str(payload.get('task_id','')))
@router.post('/api/syvax/intervention')
async def syvax_intervention(payload:dict):return home03_services.intervene(str(payload.get('task_id','')),str(payload.get('action','')),dict(payload.get('diff',{})))
@router.post('/api/syvax/render')
async def syvax_render(payload:dict):return home03_services.render(str(payload.get('text','')),str(payload.get('intent','general')),str(payload.get('mode','')))
@router.post('/api/syvax/oversight')
async def syvax_oversight(payload):return {'mode':syvax_engine.set_mode(str(payload.get('mode','HITL')))}
@router.post('/api/syvax/budget')
async def syvax_budget(payload):return {'home':str(payload.get('home','')),'budget':syvax_engine.set_budget(str(payload.get('home','')),int(payload.get('budget',100)))}
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
@router.post('/api/human-residence/intake-folder')
async def human_residence_intake_folder(payload: dict):
    """Desktop/local folder intake belongs to Human Residence, not Data Stewardship."""
    import os
    folder_path = str(payload.get('folder_path') or '').strip()
    collection_id = str(payload.get('collection_id') or '')
    if not folder_path or not os.path.isdir(folder_path):
        return JSONResponse({'accepted': False, 'error': 'folder_path is unavailable to the local runtime'}, status_code=400)

    sources = []
    for root, _, files in os.walk(folder_path):
        for name in files[:200]:
            full = os.path.join(root, name)
            try:
                with open(full, 'rb') as handle:
                    data = handle.read()
                sources.append({
                    'name': os.path.relpath(full, folder_path),
                    'source_type': 'file',
                    'channel': 'human-residence-folder',
                    'content_base64': base64.b64encode(data).decode('ascii'),
                })
            except OSError:
                continue
            if len(sources) >= 200:
                break
        if len(sources) >= 200:
            break

    if not sources:
        return JSONResponse({'accepted': False, 'error': 'folder contains no readable files'}, status_code=400)

    from ..application.data_foundation_store import data_foundations
    foundation = data_foundations.ingest({
        'sources': sources,
        'collection_id': collection_id or None,
        'supplied_context': {
            'entered_through': 'Human Residence',
            **dict(payload.get('supplied_context') or {}),
        },
    })
    return {
        'accepted': True,
        'foundation_id': foundation.foundation_id,
        'source_count': len(sources),
    }

@router.post('/api/home03/ingest')
async def home03_ingest_legacy():
 return JSONResponse({
  'accepted': False,
  'error': 'Home 03 is not an ingestion boundary. Upload through Human Residence.',
  'redirect': '/api/human-residence/intake',
 }, status_code=410)

@router.get('/api/bloom/capabilities')
async def bloom_capabilities():
    from ..application.bloom_integration import BloomCapability, BloomIntegration
    integration = BloomIntegration()
    capabilities = []
    for capability in BloomCapability:
        mapping = integration.map_capability(capability)
        event = integration.action_to_event(mapping.action)
        agents = integration.event_to_agents(event).character_ids if event else ()
        capabilities.append({
            'capability': capability.value,
            'action': mapping.action.value,
            'event': event.value if event else None,
            'agents': list(agents),
        })
    return {
        'mode': bloom_controller.mode,
        'capabilities': capabilities,
        'petals': bloom_controller.petals(),
    }

@router.post('/api/bloom/activate')
async def bloom_activate(payload: dict):
    try:
        return bloom_controller.activate_capability(
            str(payload.get('capability', '')),
            source=str(payload.get('source', 'human')),
            task_id=str(payload.get('task_id')) if payload.get('task_id') is not None else None,
            context=dict(payload.get('context', {})),
        )
    except ValueError as exc:
        return JSONResponse({'accepted': False, 'error': str(exc)}, status_code=400)

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
