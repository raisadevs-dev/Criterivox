"""Guest Pass API: memory-only evaluation sessions and ownership handover."""
from fastapi import APIRouter
from fastapi.responses import JSONResponse

from ..human.guest_pass import GuestPassManager
from ..application.human_residence_store import human_residences

router = APIRouter()
guest_passes = GuestPassManager(ttl_seconds=15 * 60)

@router.post('/api/guest-pass/session')
async def create_guest_session():
    session = guest_passes.create()
    return {'accepted': True, 'session_id': session.session_id, 'created_at': session.created_at.isoformat(), 'expires_at': session.expires_at.isoformat(), 'state': 'ISOLATED_EPHEMERAL_STATE'}

@router.get('/api/guest-pass/session/{session_id}')
async def get_guest_session(session_id: str):
    session = guest_passes.get(session_id)
    if session is None:
        return JSONResponse({'accepted': False, 'error': 'guest_session_expired'}, status_code=410)
    return {'accepted': True, 'session_id': session.session_id, 'created_at': session.created_at.isoformat(), 'expires_at': session.expires_at.isoformat(), 'goal': session.goal, 'context': session.context, 'trace': session.trace, 'decisions': session.decisions, 'state': 'ISOLATED_EPHEMERAL_STATE'}

@router.post('/api/guest-pass/session/{session_id}/input')
async def update_guest_input(session_id: str, payload: dict):
    try:
        session = guest_passes.update(session_id, goal=str(payload.get('goal', '')).strip(), data=payload.get('data'), context=dict(payload.get('context', {})))
    except KeyError:
        return JSONResponse({'accepted': False, 'error': 'guest_session_expired'}, status_code=410)
    guest_passes.append_trace(session_id, {'character': 'dharen', 'action': 'FRAME_CONTEXT', 'reason': 'Structured Goal + Data + Context inside ephemeral session.'})
    return {'accepted': True, 'session_id': session.session_id, 'missing_fields': [k for k, v in {'goal': session.goal, 'data': session.data, 'context': session.context}.items() if not v], 'trace': session.trace}

@router.post('/api/guest-pass/session/{session_id}/trace')
async def guest_trace(session_id: str, payload: dict):
    if guest_passes.get(session_id) is None:
        return JSONResponse({'accepted': False, 'error': 'guest_session_expired'}, status_code=410)
    guest_passes.append_trace(session_id, payload)
    return {'accepted': True}

@router.post('/api/guest-pass/session/{session_id}/claim')
async def claim_guest_session(session_id: str, payload: dict):
    try:
        state = guest_passes.claim(session_id)
    except KeyError:
        return JSONResponse({'accepted': False, 'error': 'guest_session_expired'}, status_code=410)
    residence_id = str(payload.get('residence_id') or f"res-{__import__('time').time_ns()}")
    owner_id = str(payload.get('owner_id') or f"local-{__import__('time').time_ns()}")
    display_name = str(payload.get('display_name') or 'My Criterivox House').strip()
    record = human_residences.upsert({'residence_id': residence_id, 'owner_id': owner_id, 'display_name': display_name, 'email': payload.get('email'), 'residence_type': 'private', 'created_at': payload.get('created_at'), 'members': [{'role': 'owner', 'owner_id': owner_id}], 'metadata': {'rooms': ['private', 'collaboration'], 'claimed_from_guest': state['claimed_from_guest'], 'guest_decision_thread': {'goal': state['goal'], 'data': state['data'], 'context': state['context'], 'trace': state['trace'], 'decisions': state['decisions']}}})
    return {'accepted': True, 'ownership_transfer': 'completed', 'residence': record, 'migrated': {'goal': state['goal'], 'data': state['data'], 'context': state['context'], 'trace': state['trace'], 'decisions': state['decisions']}, 'browser_authority': 'IndexedDB', 'python_mirror': 'local'}

@router.post('/api/guest-pass/session/{session_id}/leave')
async def leave_guest_session(session_id: str):
    return {'accepted': guest_passes.vaporize(session_id), 'state': 'VAPORIZED_EPHEMERAL_STATE'}
