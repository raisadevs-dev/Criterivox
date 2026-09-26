from criterivox.capabilities.foundations import SchemaContract, SkillMetadata
from criterivox.world.level2_part3 import CHALLENGE_ROOMS, KNOWLEDGE_ROOMS, KnowledgeChallengeRuntime

def r(): return KnowledgeChallengeRuntime()

def test_spaces():
    x=r().home_state(); assert len(KNOWLEDGE_ROOMS)==15; assert len(CHALLENGE_ROOMS)==13; assert x["knowledge"]["resident"]=="Viveda"; assert x["challenge"]["resident"]=="Manis"

def test_trajectory_challenge_approval():
    x=r(); p=x.ingest_trajectory({"title":"trajectory","references":["delivery-1"],"steps":["inspect","compare"]}); c=x.challenge_proposal(p.proposal_id,"human-1","Challenge scope","challenge.generalization"); assert c["proposal"]["status"]=="UNDER_CHALLENGE"; assert x.resolve_proposal(p.proposal_id,"APPROVED")["version"]=="2"

def test_ontology_mutation_is_non_destructive():
    x=r(); x.weave_ontology("decision","Decision"); m=x.mutate_ontology("decision",{"relationships":[{"to":"evidence"}]},"reviewed relation",["e-1"]); assert m["status"]=="PROPOSED"; assert x.ontology["decision"]["label"]=="Decision"

def test_skill_package():
    x=r(); x.register_skill(SkillMetadata("s1","1",("reasoning","review"),("human_review",),"active")); assert x.package_skill("s1")["status"]=="PACKAGED"

def test_schema_translation_does_not_fabricate():
    x=r(); z=x.translate_schema({"title":"x"},SchemaContract("knowledge","2",("title","evidence"))); assert z["status"]=="INCOMPATIBLE"; assert z["missing_required"]==["evidence"]

def test_version_and_memsync_conflict():
    x=r(); x.version_knowledge("k","1"); assert x.sync_knowledge("k",{"v":1},"1")["status"]=="SYNCED"; assert x.sync_knowledge("k",{"v":2},"0")["status"]=="CONFLICT"

def test_reflection_utility_migration():
    x=r(); assert x.record_utility("k","reused")["outcome"]=="reused"; assert x.record_reflection("k","observation","proposal")["status"]=="PENDING_CHALLENGE"; assert x.migration_contract("m","1","2")["to_version"]=="2"


def test_structural_transfer_is_bounded():
    x=r(); p=x.ingest_trajectory({'title':'transferable','references':['e1'],'steps':['inspect']}); t=x.transfer_structure(p.proposal_id,'reasoning', ['same scope']); assert t['status']=='BOUNDED_TRANSFER_PROPOSAL'; assert t['provenance']==['e1']
