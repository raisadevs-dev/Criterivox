"""Canonical Level-2 Part-III Knowledge/Challenge integration layer."""
from __future__ import annotations
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
import hashlib, json
from pathlib import Path
from typing import Any
from criterivox.capabilities.foundations import KnowledgeVersion, MigrationContract, SchemaContract, SkillMetadata
from criterivox.human.collaboration_engine import CollaborationEngine

ROOT = Path("data/runtime")
STORE = ROOT / "knowledge_challenge_integration.json"
KNOWLEDGE_ROOMS = ("knowledge.hall","knowledge.trajectory","knowledge.ontology","knowledge.transfer","knowledge.friction","knowledge.skills","knowledge.packaging","knowledge.mutation","knowledge.schema","knowledge.utility","knowledge.decay","knowledge.memsync","knowledge.garden","knowledge.policy","knowledge.versioning")
CHALLENGE_ROOMS = ("challenge.hall","challenge.assumption","challenge.intent","challenge.socratic","challenge.dogma","challenge.sycophancy","challenge.drift","challenge.bias","challenge.generalization","challenge.crm","challenge.sme","challenge.tools","challenge.vigilance")

def _now(): return datetime.now(timezone.utc).isoformat()
def _digest(value): return hashlib.sha256(json.dumps(value, sort_keys=True, default=str).encode()).hexdigest()

@dataclass
class KnowledgeProposal:
    proposal_id: str
    kind: str
    title: str
    source_refs: list[str]
    assumptions: list[str]
    limitations: list[str]
    payload: dict[str, Any]
    status: str = "PROPOSED"
    challenge_ids: list[str] = field(default_factory=list)
    created_at: str = field(default_factory=_now)
    version: str = "1"

class KnowledgeChallengeRuntime:
    """Viveda workflow + Manis challenge integration over existing runtimes."""
    def __init__(self):
        self.proposals={}; self.ontology={}; self.skills={}; self.skill_health={}
        self.versions={}; self.translations=[]; self.mutations=[]; self.utility=[]
        self.sync_conflicts=[]; self.reflections=[]; self.collaboration=CollaborationEngine()
        self._load()
    def _load(self):
        ROOT.mkdir(parents=True, exist_ok=True)
        if not STORE.exists(): return
        try:
            raw=json.loads(STORE.read_text())
            self.ontology=raw.get("ontology",{}); self.skill_health=raw.get("skill_health",{})
            self.versions=raw.get("versions",{}); self.translations=raw.get("translations",[])
            self.mutations=raw.get("mutations",[]); self.utility=raw.get("utility",[])
            self.sync_conflicts=raw.get("sync_conflicts",[]); self.reflections=raw.get("reflections",[])
            self.proposals={k:KnowledgeProposal(**v) for k,v in raw.get("proposals",{}).items()}
            self.skills={k:SkillMetadata(**v) for k,v in raw.get("skills",{}).items()}
        except (OSError,ValueError,TypeError): pass
    def _save(self):
        ROOT.mkdir(parents=True, exist_ok=True); tmp=STORE.with_suffix(".tmp")
        tmp.write_text(json.dumps({"proposals":{k:asdict(v) for k,v in self.proposals.items()},"ontology":self.ontology,"skills":{k:asdict(v) for k,v in self.skills.items()},"skill_health":self.skill_health,"versions":self.versions,"translations":self.translations,"mutations":self.mutations,"utility":self.utility,"sync_conflicts":self.sync_conflicts,"reflections":self.reflections},indent=2,default=str)); tmp.replace(STORE)
    def home_state(self):
        return {"knowledge":{"resident":"Viveda","rooms":list(KNOWLEDGE_ROOMS),"active_proposals":len([p for p in self.proposals.values() if p.status!="REJECTED"]),"skills":len(self.skills),"ontology_nodes":len(self.ontology)},"challenge":{"resident":"Manis","rooms":list(CHALLENGE_ROOMS),"active_challenge_links":sum(len(p.challenge_ids) for p in self.proposals.values())},"truth":"LIVE","architecture":"knowledge-challenge-integration-over-existing-runtimes"}
    def ingest_trajectory(self, trajectory):
        refs=[str(x) for x in trajectory.get("references",[])]; title=str(trajectory.get("title") or "Distilled trajectory")
        pattern={"steps":list(trajectory.get("steps",[])),"conditions":list(trajectory.get("conditions",[])),"outcomes":list(trajectory.get("outcomes",[])),"success_signals":list(trajectory.get("success_signals",[]))}
        p=KnowledgeProposal(f"knowledge-{_digest([title,pattern,refs])[:16]}","trajectory_pattern",title,refs,[str(x) for x in trajectory.get("assumptions",[])],[str(x) for x in trajectory.get("limitations",[])],{"pattern":pattern,"source_digest":_digest(trajectory)})
        self.proposals[p.proposal_id]=p; self._save(); return p
    def weave_ontology(self,node_id,label,relationships=None,source_refs=None):
        if not node_id.strip() or not label.strip(): raise ValueError("node_id_and_label_required")
        r={"node_id":node_id,"label":label,"relationships":list(relationships or []),"source_refs":list(source_refs or []),"status":"PROPOSED","updated_at":_now()}
        self.ontology[node_id]=r; self._save(); return r
    def mutate_ontology(self,node_id,changes,reason,source_refs=None):
        if node_id not in self.ontology: raise KeyError("ontology_node_not_found")
        m={"mutation_id":f"mutation-{_digest([node_id,changes,reason,_now()])[:16]}","node_id":node_id,"before":dict(self.ontology[node_id]),"proposed_changes":dict(changes),"reason":reason,"source_refs":list(source_refs or []),"status":"PROPOSED","created_at":_now()}
        self.mutations.append(m); self._save(); return m
    def register_skill(self,skill):
        self.skills[skill.skill_id]=skill; self.skill_health.setdefault(skill.skill_id,{"skill_id":skill.skill_id,"uses":0,"contradictions":0,"last_validated":_now(),"status":skill.status}); self._save(); return asdict(skill)
    def package_skill(self,skill_id):
        skill=self.skills[skill_id]; return {"package_id":f"skillpkg-{_digest(asdict(skill))[:16]}","skill":asdict(skill),"health":dict(self.skill_health.get(skill_id,{})),"dependencies":list(skill.constraints),"provenance":{"source":"viveda","created_at":_now()},"status":"PACKAGED"}
    def translate_schema(self,source,target):
        missing=target.validate(source); r={"translation_id":f"translation-{_digest([source,asdict(target)])[:16]}","target_schema":asdict(target),"source_fields":sorted(source),"missing_required":list(missing),"status":"COMPATIBLE" if not missing else "INCOMPATIBLE","created_at":_now()}
        self.translations.append(r); self._save(); return r
    def version_knowledge(self,knowledge_id,version,parents=None,schema_version="1",status="proposed"):
        r=asdict(KnowledgeVersion(knowledge_id,version,tuple(parents or []),schema_version,status)); self.versions.setdefault(knowledge_id,[]).append(r); self._save(); return r
    def sync_knowledge(self,knowledge_id,incoming,base_version=None):
        h=self.versions.get(knowledge_id,[]); cur=h[-1] if h else None; conflict=bool(cur and base_version and cur.get("version")!=base_version)
        r={"knowledge_id":knowledge_id,"base_version":base_version,"current_version":cur.get("version") if cur else None,"status":"CONFLICT" if conflict else "SYNCED","incoming_digest":_digest(incoming),"created_at":_now()}
        if conflict: self.sync_conflicts.append(r)
        self._save(); return r
    def record_utility(self,knowledge_id,outcome,evidence_refs=None):
        r={"knowledge_id":knowledge_id,"outcome":outcome,"evidence_refs":list(evidence_refs or []),"created_at":_now()}; self.utility.append(r); self._save(); return r
    def record_reflection(self,knowledge_id,observation,proposal):
        r={"reflection_id":f"reflection-{_digest([knowledge_id,observation,proposal,_now()])[:16]}","knowledge_id":knowledge_id,"observation":observation,"proposal":proposal,"status":"PENDING_CHALLENGE","created_at":_now()}; self.reflections.append(r); self._save(); return r
    def challenge_proposal(self,proposal_id,actor_id,instruction,room="challenge.dogma"):
        p=self.proposals[proposal_id]
        if room not in CHALLENGE_ROOMS: raise ValueError("unknown_challenge_room")
        sid=self.collaboration.get_or_create(f"knowledge-{proposal_id}",actor_id,actor_id)["session"]["session_id"]
        c=self.collaboration.challenge(sid,actor_id,instruction); p.challenge_ids.append(c["id"]); p.status="UNDER_CHALLENGE"; self._save()
        return {"proposal":asdict(p),"challenge":c,"collaboration_session_id":sid}
    def resolve_proposal(self,proposal_id,status):
        if status not in {"APPROVED","REJECTED","REVISED"}: raise ValueError("invalid_proposal_status")
        p=self.proposals[proposal_id]; p.status=status
        if status=="APPROVED": p.version=str(int(p.version)+1)
        self._save(); return asdict(p)
    def challenge_room_state(self,room):
        if room not in CHALLENGE_ROOMS: raise ValueError("unknown_challenge_room")
        return {"room":room,"resident":"Manis","truth":"LIVE","engine":"HumanAuthority + CollaborationEngine","duplicate_engine":False,"proposal_count":len(self.proposals)}
    def migration_contract(self,migration_id,from_version,to_version,reversible=False,notes=""):
        return asdict(MigrationContract(migration_id,from_version,to_version,reversible,notes))
    def state(self):
        return {**self.home_state(),"proposals":[asdict(x) for x in self.proposals.values()],"ontology":list(self.ontology.values()),"skills":[asdict(x) for x in self.skills.values()],"skill_health":list(self.skill_health.values()),"versions":self.versions,"translations":self.translations[-20:],"mutations":self.mutations[-20:],"utility":self.utility[-20:],"sync_conflicts":self.sync_conflicts[-20:],"reflections":self.reflections[-20:]}

part3_runtime=KnowledgeChallengeRuntime()
