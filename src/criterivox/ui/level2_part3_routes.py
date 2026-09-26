"""HTTP boundary for Level-2 Part III."""
from fastapi import APIRouter
from fastapi.responses import JSONResponse
from ..capabilities.foundations import SchemaContract, SkillMetadata
from ..world.level2_part3 import CHALLENGE_ROOMS, KNOWLEDGE_ROOMS, part3_runtime
router=APIRouter(prefix="/api/world/level2/part3",tags=["level2-part3"])

@router.get("/state")
async def state(): return part3_runtime.state()
@router.get("/rooms")
async def rooms(): return {"knowledge":list(KNOWLEDGE_ROOMS),"challenge":list(CHALLENGE_ROOMS),"truth":"LIVE"}
@router.get("/home/{home}")
async def home(home:str):
    if home=="knowledge": return part3_runtime.home_state()["knowledge"]
    if home in {"challenge","decision"}: return part3_runtime.home_state()["challenge"]
    return JSONResponse({"error":"unknown_part3_home"},status_code=404)
@router.get("/room/{room}")
async def room(room: str):
    if room in KNOWLEDGE_ROOMS:
        return {"room": room, "resident": "Viveda", "truth": "LIVE", "boundary": "knowledge-challenge-integration", "action": "inspect"}
    try:
        return part3_runtime.challenge_room_state(room)
    except ValueError:
        return JSONResponse({"error": "unknown_part3_room"}, status_code=404)

@router.post("/trajectory")
async def trajectory(payload:dict): return {"proposal":part3_runtime.ingest_trajectory(payload).__dict__}
@router.post("/ontology/node")
async def ontology_node(payload:dict): return part3_runtime.weave_ontology(str(payload.get("node_id","")),str(payload.get("label","")),payload.get("relationships"),payload.get("source_refs"))
@router.post("/ontology/mutation")
async def ontology_mutation(payload:dict):
    try: return part3_runtime.mutate_ontology(str(payload.get("node_id","")),dict(payload.get("changes") or {}),str(payload.get("reason","")),payload.get("source_refs"))
    except KeyError as exc: return JSONResponse({"error":str(exc)},status_code=404)
@router.post("/skills/register")
async def skill_register(payload:dict):
    return part3_runtime.register_skill(SkillMetadata(str(payload.get("skill_id","")),str(payload.get("version","1")),tuple(str(x) for x in payload.get("taxonomy_path",[])),tuple(str(x) for x in payload.get("constraints",[])),str(payload.get("status","active"))))
@router.get("/skills/{skill_id}/package")
async def skill_package(skill_id:str):
    try: return part3_runtime.package_skill(skill_id)
    except KeyError: return JSONResponse({"error":"skill_not_found"},status_code=404)
@router.post("/schema/translate")
async def schema_translate(payload:dict):
    t=dict(payload.get("target_schema") or {}); target=SchemaContract(str(t.get("schema_id","knowledge")),str(t.get("version","1")),tuple(str(x) for x in t.get("required_fields",[])),tuple(str(x) for x in t.get("optional_fields",[])))
    return part3_runtime.translate_schema(dict(payload.get("source") or {}),target)
@router.post("/knowledge/version")
async def knowledge_version(payload:dict): return part3_runtime.version_knowledge(str(payload.get("knowledge_id","")),str(payload.get("version","1")),[str(x) for x in payload.get("parents",[])],str(payload.get("schema_version","1")),str(payload.get("status","proposed")))
@router.post("/knowledge/sync")
async def knowledge_sync(payload:dict): return part3_runtime.sync_knowledge(str(payload.get("knowledge_id","")),dict(payload.get("incoming") or {}),payload.get("base_version"))
@router.post("/knowledge/transfer")
async def knowledge_transfer(payload: dict):
    try:
        return part3_runtime.transfer_structure(str(payload.get("proposal_id","")), str(payload.get("target_context","")), payload.get("reuse_conditions"))
    except KeyError as exc:
        return JSONResponse({"error": str(exc)}, status_code=404)

@router.post("/knowledge/utility")
async def knowledge_utility(payload:dict): return part3_runtime.record_utility(str(payload.get("knowledge_id","")),str(payload.get("outcome","")),payload.get("evidence_refs"))
@router.post("/knowledge/reflection")
async def knowledge_reflection(payload:dict): return part3_runtime.record_reflection(str(payload.get("knowledge_id","")),str(payload.get("observation","")),str(payload.get("proposal","")))
@router.post("/proposal/challenge")
async def proposal_challenge(payload:dict):
    try: return part3_runtime.challenge_proposal(str(payload.get("proposal_id","")),str(payload.get("actor_id","human")),str(payload.get("instruction","Challenge this knowledge proposal.")),str(payload.get("room","challenge.dogma")))
    except KeyError as exc: return JSONResponse({"error":str(exc)},status_code=404)
@router.post("/proposal/resolve")
async def proposal_resolve(payload:dict):
    try: return {"proposal":part3_runtime.resolve_proposal(str(payload.get("proposal_id","")),str(payload.get("status","")))}
    except KeyError as exc: return JSONResponse({"error":str(exc)},status_code=404)
@router.get("/challenge/{room}")
async def challenge_room(room:str):
    try: return part3_runtime.challenge_room_state(room)
    except ValueError: return JSONResponse({"error":"unknown_challenge_room"},status_code=404)
@router.post("/migration-contract")
async def migration_contract(payload:dict): return part3_runtime.migration_contract(str(payload.get("migration_id","")),str(payload.get("from_version","")),str(payload.get("to_version","")),bool(payload.get("reversible",False)),str(payload.get("notes","")))
