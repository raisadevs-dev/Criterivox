from __future__ import annotations
import json, sqlite3
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Mapping
from uuid import uuid4
ROOT=Path(__file__).resolve().parents[3]
STORE_PATH=ROOT/"data"/"s8"/"character_operations.sqlite3"
def now(): return datetime.now(timezone.utc).isoformat()
def uid(prefix): return f"{prefix}-{uuid4()}"
@dataclass(frozen=True)
class JourneyRecord:
    journey_id:str; originating_conversation:str|None; problem:str; status:str="ACTIVE"; task_ids:tuple[str,...]=(); event_lineage:tuple[str,...]=(); created_at:str=""; updated_at:str=""; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class EvidenceRecord:
    evidence_id:str; journey_id:str; task_id:str|None; question:str; source_reference:str; source_type:str; observation:str; extracted_claims:tuple[str,...]=(); interpretation:str|None=None; collected_by:str="medrus"; collection_method:str="recorded"; timestamp:str=""; temporal_scope:str|None=None; provenance:Mapping[str,Any]=field(default_factory=dict); verification_status:str="RAW"; contradiction_refs:tuple[str,...]=(); uncertainty:tuple[str,...]=(); limitations:tuple[str,...]=()
@dataclass(frozen=True)
class VerificationRecord:
    verification_id:str; target_type:str; target_id:str; verification_method:str; source_refs:tuple[str,...]; checks:tuple[str,...]; contradictions:tuple[str,...]; temporal_validity:str; integrity_status:str; verifier:str; timestamp:str; result:str; uncertainty:tuple[str,...]=(); limitations:tuple[str,...]=(); provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class ReasoningExplanation:
    reasoning_id:str; journey_id:str; question:str; conclusion:str; supporting_evidence:tuple[str,...]; relevant_context:tuple[str,...]; assumptions:tuple[str,...]; alternatives:tuple[str,...]; rejected_alternatives:tuple[str,...]; contradictions:tuple[str,...]; decision_factors:tuple[str,...]; uncertainty:tuple[str,...]; limitations:tuple[str,...]; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class HypothesisRecord:
    hypothesis_id:str; journey_id:str; question:str; statement:str; origin:str; supporting_evidence:tuple[str,...]=(); contradicting_evidence:tuple[str,...]=(); assumptions:tuple[str,...]=(); alternatives:tuple[str,...]=(); status:str="PROPOSED"; test_reference:str|None=None; verification_reference:str|None=None; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class ChallengeRecord:
    challenge_id:str; journey_id:str; target_type:str; target_id:str; human_input:str; challenge_type:str; objection:str; affected_assumptions:tuple[str,...]=(); affected_evidence:tuple[str,...]=(); requested_change:str|None=None; created_at:str=""; resolution_status:str="OPEN"; resolution:str|None=None; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class DecisionRecord:
    decision_id:str; journey_id:str; options:tuple[str,...]; recommendation:str|None; recommendation_basis:tuple[str,...]; selected_option:str|None; human_actor:str|None; human_modification:str|None; rationale:str|None; constraints:tuple[str,...]; evidence_refs:tuple[str,...]; uncertainty:tuple[str,...]; authorization_state:str; timestamp:str; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class OutcomeRecord:
    outcome_id:str; journey_id:str; task_id:str|None; decision_reference:str|None; plan_reference:str|None; execution_reference:str|None; expected_outcome:str; actual_outcome:str|None; observed_evidence:tuple[str,...]; deviations:tuple[str,...]; success_status:str; verification_status:str; lessons:tuple[str,...]; created_at:str; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class KnowledgeRecord:
    knowledge_id:str; journey_id:str; subject:str; statement:str; source_artifacts:tuple[str,...]; evidence_refs:tuple[str,...]; verification_refs:tuple[str,...]; context_conditions:tuple[str,...]; applicability:tuple[str,...]; limitations:tuple[str,...]; uncertainty:tuple[str,...]; maturity:str; created_at:str; updated_at:str; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class AdaptationRecord:
    adaptation_id:str; journey_id:str; source_context:str; previous_version:str|None; new_version:str|None; trigger:str; affected_artifacts:tuple[str,...]; adaptation_action:str; status:str; provenance:Mapping[str,Any]=field(default_factory=dict)
@dataclass(frozen=True)
class TransferRecord:
    transfer_id:str; journey_id:str; source_home:str; destination_home:str; source_artifact:str; source_context:str|None; target_context:str|None; compatibility:str; adaptation_required:bool; adaptation_reference:str|None; status:str; provenance:Mapping[str,Any]=field(default_factory=dict)
class Set4Store:
    def __init__(self, path=STORE_PATH):
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        self.path = str(path)
        self._init_schema()

    def _connect(self):
        connection = sqlite3.connect(self.path)
        connection.row_factory = sqlite3.Row
        return connection

    def _init_schema(self):
        with self._connect() as connection:
            connection.execute(
                "CREATE TABLE IF NOT EXISTS set4_records("
                "record_id TEXT PRIMARY KEY,record_type TEXT NOT NULL,"
                "journey_id TEXT NOT NULL,task_id TEXT,owner TEXT,status TEXT,"
                "payload_json TEXT NOT NULL,created_at TEXT NOT NULL,updated_at TEXT NOT NULL)"
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS idx_set4_journey "
                "ON set4_records(journey_id,created_at)"
            )

    def save(self, record_type, payload, *, journey_id, task_id=None, owner=None, status=None, record_id=None):
        rid = record_id or str(payload.get("id") or uid("S4"))
        stamp = now()
        with self._connect() as connection:
            connection.execute(
                "INSERT OR REPLACE INTO set4_records VALUES(?,?,?,?,?,?,?,?,?)",
                (
                    rid, record_type, journey_id, task_id, owner, status,
                    json.dumps(dict(payload), default=str, sort_keys=True),
                    stamp, stamp,
                ),
            )
        return rid

    def get(self, record_id):
        with self._connect() as connection:
            row = connection.execute(
                "SELECT * FROM set4_records WHERE record_id=?", (record_id,)
            ).fetchone()
        return None if row is None else {
            **json.loads(row["payload_json"]),
            "_record_type": row["record_type"],
            "_journey_id": row["journey_id"],
            "_task_id": row["task_id"],
            "_status": row["status"],
            "_owner": row["owner"],
        }

    def list(self, *, journey_id=None, record_type=None):
        query = "SELECT * FROM set4_records"
        clauses = []
        values = []
        if journey_id is not None:
            clauses.append("journey_id=?")
            values.append(journey_id)
        if record_type is not None:
            clauses.append("record_type=?")
            values.append(record_type)
        if clauses:
            query += " WHERE " + " AND ".join(clauses)
        query += " ORDER BY created_at"
        with self._connect() as connection:
            rows = connection.execute(query, values).fetchall()
        return [
            {
                **json.loads(row["payload_json"]),
                "_record_type": row["record_type"],
                "_journey_id": row["journey_id"],
                "_task_id": row["task_id"],
                "_status": row["status"],
                "_owner": row["owner"],
            }
            for row in rows
        ]

class Set4Runtime:
    RECORD_TYPES=("journey","chat","context","data","evidence","reasoning","hypothesis","contradiction","challenge","decision","action_plan","authorization","execution","outcome","verification","knowledge","adaptation","transfer","event")
    def __init__(self,store=None):self.store=store or Set4Store()
    def _record(self,kind,payload,journey_id,**kw):return self.store.save(kind,payload,journey_id=journey_id,**kw)
    def event(self,event_type,journey_id,*,actor,task_id=None,inputs=None,outputs=None,caused_by=None,parent_event=None):
        eid=uid("S4E");p={"id":eid,"event_type":event_type,"journey_id":journey_id,"task_id":task_id,"actor":actor,"timestamp":now(),"inputs":dict(inputs or {}),"outputs":dict(outputs or {}),"caused_by":caused_by,"parent_event":parent_event,"provenance":{"source":"set4-runtime"}};return self._record("event",p,journey_id,task_id=task_id,owner=actor,record_id=eid)
    def create_journey(self,problem,*,conversation_id=None,task_id=None,journey_id=None):
        jid=journey_id or uid("JRN");s=now();r=JourneyRecord(jid,conversation_id,problem,created_at=s,updated_at=s);self._record("journey",asdict(r),jid,task_id=task_id,owner="syvax",status="ACTIVE",record_id=jid);self.event("JOURNEY_CREATED",jid,actor="syvax",task_id=task_id,inputs={"problem":problem});return r
    def chat(self,journey_id,*,character,message,task_id=None):return self._record("chat",{"id":uid("CHAT"),"character":character,"message":message,"timestamp":now()},journey_id,task_id=task_id,owner=character)
    def record_evidence(self,r):
        if r.verification_status=="VERIFIED" and not r.provenance.get("verification_id"):raise ValueError("Evidence cannot be VERIFIED without a verification reference.")
        return self._record("evidence",asdict(r),r.journey_id,task_id=r.task_id,owner=r.collected_by,status=r.verification_status,record_id=r.evidence_id)
    def _journey_for(self,target_id):
        x=self.store.get(target_id);return x["_journey_id"] if x else "UNBOUND"
    def record_verification(self,r,*,task_id=None):return self._record("verification",asdict(r),self._journey_for(r.target_id),task_id=task_id,owner=r.verifier,status=r.result,record_id=r.verification_id)
    def record_reasoning(self,r):return self._record("reasoning",asdict(r),r.journey_id,owner="vivren",record_id=r.reasoning_id)
    def record_hypothesis(self,r):
        if r.status=="VERIFIED":raise ValueError("Hypotheses cannot be marked VERIFIED directly.")
        return self._record("hypothesis",asdict(r),r.journey_id,owner="tarkis",status=r.status,record_id=r.hypothesis_id)
    def record_challenge(self,r):return self._record("challenge",asdict(r),r.journey_id,owner="manis",status=r.resolution_status,record_id=r.challenge_id)
    def record_decision(self,r):
        if r.selected_option and not r.human_actor:raise ValueError("A selected decision must identify the human decision-maker.")
        return self._record("decision",asdict(r),r.journey_id,owner="pramon",record_id=r.decision_id)
    def record_outcome(self,r):
        if r.success_status=="SUCCESSFUL" and r.verification_status!="VERIFIED":raise ValueError("SUCCESSFUL outcome requires VERIFIED status.")
        return self._record("outcome",asdict(r),r.journey_id,task_id=r.task_id,owner="veridat",status=r.success_status,record_id=r.outcome_id)
    def record_knowledge(self,r):
        if r.maturity in {"VERIFIED","REUSABLE"} and not r.verification_refs:raise ValueError("Verified/reusable knowledge requires verification references.")
        return self._record("knowledge",asdict(r),r.journey_id,owner="viveda",status=r.maturity,record_id=r.knowledge_id)
    def record_adaptation(self,r):return self._record("adaptation",asdict(r),r.journey_id,owner="anuka",status=r.status,record_id=r.adaptation_id)
    def record_transfer(self,r):return self._record("transfer",asdict(r),r.journey_id,owner="anukor",status=r.status,record_id=r.transfer_id)
    def dependency_status(self,journey_id,changed_record_id):
        rows=self.store.list(journey_id=journey_id);affected=[str(x.get("id")) for x in rows if changed_record_id in json.dumps(x,sort_keys=True) and x.get("id")!=changed_record_id];return {"changed":[changed_record_id],"affected":[x for x in affected if x!="None"],"status":"REQUIRES_REVIEW" if affected else "VALID"}
    def inspect_journey(self,journey_id):
        rows=self.store.list(journey_id=journey_id)
        if not rows:return {"journey_id":journey_id,"status":"NOT_RECORDED"}
        grouped={k:[] for k in self.RECORD_TYPES}
        for row in rows:grouped.setdefault(row["_record_type"],[]).append(row)
        return {"journey_id":journey_id,"journey":grouped["journey"][0] if grouped["journey"] else None,"stages":{k:(v or [{"status":"NOT_RECORDED"}]) for k,v in grouped.items()},"record_count":len(rows)}
    def character_answer(self,character_id,question,*,journey_id=None):
        rows=self.store.list(journey_id=journey_id) if journey_id else []
        answers={"syvax":"I can explain recorded journey and routing state; I will not invent evidence or execution records.","dharen":"I can report recorded context and dependencies; I will not claim context that is not stored.","sandre":"I can report recorded data sources and provenance; I cannot invent source provenance.","kaelen":"I can explain recorded transformations and experimental outputs; experimental material is not automatically canonical.","anuka":"I can report recorded context adaptations and triggers; I do not silently adapt context.","vivren":"I can provide structured reasoning summaries with evidence, assumptions, alternatives, contradictions, uncertainty and limitations. Hidden chain-of-thought is not exposed.","tarkis":"I can report hypotheses and alternatives with their status. A hypothesis remains distinct from a verified finding.","pramon":"I can report recommendations and decision structure. A human-selected option is only claimed when a human decision record exists.","bodhex":"I can report prepared action contracts and execution records. Preparing an action is not execution.","medrus":"I can report evidence records, observations and limitations. Acquisition is not verification.","epistre":"I can trace recorded provenance and explanation lineage. Incomplete lineage remains incomplete.","manis":"I can report persisted human challenges. I cannot make the human decision.","viveda":"I can report consolidated knowledge and its evidence and verification references.","anukor":"I can report recorded cross-home transfers, compatibility, adaptation and rejection. Sending a message is not transfer success."}
        if character_id=="veridat":
            ver=[r for r in rows if r["_record_type"]=="verification"]
            return "Recorded verification: "+"; ".join(str(x.get("result")) for x in ver) if ver else "No authoritative verification record exists for this journey yet."
        return answers.get(character_id,"No grounded responsibility record is available for this character.")
