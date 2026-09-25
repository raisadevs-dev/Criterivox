from __future__ import annotations
import csv, io, json, math, os, statistics
from dataclasses import asdict
from typing import Any, Mapping

from criterivox.application.situation_understanding import SituationUnderstandingService
from criterivox.application.situation import SafetyLevel
from criterivox.application.data_foundation_store import DataFoundationStore
from criterivox.context.engine import ContextIntelligenceEngine
from criterivox.context.models import ContextInput, ContextItem
from criterivox.s7.orchestrator import ReasoningResearchBureau
from criterivox.s8.bureau import EvidenceResearchBureau
from criterivox.s8.models import ArtifactKind
from .contracts import ServiceRequest, ServiceResult, OutcomeRecord

class ServiceBase:
    service_type = "base"
    purpose = ""
    def result(self, req, *, status="OK", content=None, structured=None, **kw):
        return ServiceResult(self.service_type, req.request_id, status, self.purpose,
            content or {}, structured or {}, **kw)

class SituationService(ServiceBase):
    service_type="situation_understanding"
    purpose="Determine the human goal, situation, constraints, ambiguity and required downstream work."
    def __init__(self): self.engine=SituationUnderstandingService(); self.context_engine=ContextIntelligenceEngine()
    def execute(self, req):
        u=self.engine.understand(req.goal, context=req.context, supplied_data=req.supplied_data)
        if u.situation.safety is SafetyLevel.IMMEDIATE:
            return self.result(req,status="INSUFFICIENT",content={"situation":asdict(u.situation),"questions":list(u.clarifying_questions)},
                structured={"intent":u.intent}, uncertainty=("Immediate safety context requires human/real-world intervention before ordinary analysis.",),
                limitations=("Criterivox does not replace responsible adults or emergency services.",),
                challengeable=("situation description","safety assessment"), editable=("goal","context","supplied_data"),
                authorization_state="human-required")
        items=tuple(ContextItem(k,v) for k,v in {"goal":u.situation.goal,"context":u.situation.context,"safety":u.situation.safety.value,"intent":u.intent}.items())
        state=self.context_engine.build(ContextInput(request=req.goal,items=items,hard_constraints=u.situation.constraints))
        return self.result(req,status="CLARIFICATION_REQUIRED" if u.needs_clarification else "OK",
            content={"situation":asdict(u.situation),"intent":u.intent,"questions":list(u.clarifying_questions),"context_frame_id":state.frame.frame_id},
            structured={"intent":u.intent,"context_state":state.active_context},
            uncertainty=tuple(u.situation.uncertainties), limitations=tuple(u.notes),
            challengeable=("goal","constraints","context"), editable=("goal","context","supplied_data"),
            downstream_dependencies=("evidence_data_analysis","analytical_reporting") if not u.needs_clarification else ())

class EvidenceDataService(ServiceBase):
    service_type="evidence_data_analysis"
    purpose="Convert supplied material into validated analytical inputs with provenance and quality information."
    def __init__(self, store=None, evidence=None): self.store=store or DataFoundationStore(); self.evidence=evidence or EvidenceResearchBureau()
    def execute(self, req):
        if not req.supplied_data.strip():
            return self.result(req,status="INSUFFICIENT",content={"reason":"No supplied material was provided."},
                uncertainty=("No user/system evidence was supplied.",), limitations=("Analysis can proceed only from the request/context unless evidence is supplied.",),
                editable=("supplied_data",))
        raw=req.supplied_data.strip(); rows=[]; kind="text"
        try:
            if raw.startswith("[") or raw.startswith("{"):
                obj=json.loads(raw); rows=obj if isinstance(obj,list) else [obj]; kind="json"
            elif "," in raw and "\n" in raw:
                rows=list(csv.DictReader(io.StringIO(raw))); kind="csv"
        except (json.JSONDecodeError,csv.Error):
            rows=[]
        foundation=self.store.ingest({"sources":[{"name":"Service Layer supplied material","source_type":"text","channel":"service-layer","content":raw,"processing_status":"received"}],"collection_id":req.request_id,"supplied_context":{"goal":req.goal,"context":req.context}})
        source=self.evidence.add_artifact(ArtifactKind.EVIDENCE,{"request_id":req.request_id,"kind":kind,"row_count":len(rows),"content_preview":raw[:2000],"foundation_id":foundation.foundation_id},tenant_id=req.actor_id,context_id=req.request_id)
        quality={"missing_values":0,"row_count":len(rows),"field_count":len(rows[0]) if rows and isinstance(rows[0],dict) else 0,"parse_kind":kind}
        prov=self.evidence.add_artifact(ArtifactKind.PROVENANCE,{"foundation_id":foundation.foundation_id,"source_artifact_id":source.artifact_id,"input_channel":"service-layer"},source_ids=(source.artifact_id,),tenant_id=req.actor_id,context_id=req.request_id)
        return self.result(req,content={"foundation_id":foundation.foundation_id,"evidence_artifact_id":source.artifact_id,"quality":quality},
            structured={"rows":rows,"kind":kind}, evidence_refs=(source.artifact_id,), provenance_refs=(prov.artifact_id,),
            artifact_refs=(source.artifact_id,prov.artifact_id), uncertainty=("Parsing is deterministic and does not establish semantic correctness.",),
            challengeable=("parsed evidence","data quality"), editable=("supplied_data",), downstream_dependencies=("analytical_reporting",))

class AnalyticalService(ServiceBase):
    service_type="analytical_reporting"
    purpose="Perform actual deterministic analysis over available structured material."
    def execute(self, req, evidence=None):
        rows=list((evidence or {}).get("rows",[])); numeric={}; findings=[]; limitations=[]
        if not rows:
            return self.result(req,status="INSUFFICIENT",content={"findings":[]},uncertainty=("No structured rows were available for computation.",))
        keys=sorted({k for r in rows if isinstance(r,dict) for k in r})
        for k in keys:
            vals=[]
            for r in rows:
                try:
                    x=float(r.get(k)); vals.append(x) if math.isfinite(x) else None
                except (TypeError,ValueError): pass
            if vals:
                numeric[k]={"count":len(vals),"mean":statistics.fmean(vals),"min":min(vals),"max":max(vals),"median":statistics.median(vals)}
                findings.append(f"{k}: {len(vals)} numeric observations; mean={numeric[k]['mean']:.4g}, range={numeric[k]['min']:.4g}..{numeric[k]['max']:.4g}")
        if not numeric: limitations.append("No numeric fields were available; analysis is limited to structural counts.")
        return self.result(req,content={"findings":findings,"row_count":len(rows),"fields":keys},
            structured={"numeric_summary":numeric,"row_count":len(rows),"field_count":len(keys)},
            uncertainty=tuple(limitations), challengeable=("numeric summary","field interpretation"),editable=("supplied_data",),
            downstream_dependencies=("reasoning_hypothesis","verification_explanation"))

class ReasoningService(ServiceBase):
    service_type="reasoning_hypothesis"
    purpose="Use the existing S7 reasoning bureau to construct inspectable reasoning, hypotheses, evaluation and bounded results."
    def __init__(self, bureau=None): self.bureau=bureau or ReasoningResearchBureau()
    def execute(self, req, context_data=None):
        ctx={"service_request_id":req.request_id,"goal":req.goal,"context":req.context,"evidence":context_data or {}}
        session=self.bureau.start(req.goal,ctx)
        if session.status.value=="waiting_for_information":
            return self.result(req,status="INSUFFICIENT",content={"session_id":session.session_id,"missing_information":list(session.missing_information)},execution_ref=session.session_id)
        snap=self.bureau.snapshot(session.session_id)
        return self.result(req,content={"session_id":session.session_id,"result_artifact":next((a for a in snap["artifacts"] if a["kind"]=="result"),None)},
            structured={"capabilities":snap["capabilities"],"artifacts":snap["artifacts"],"branches":snap["branches"]},
            artifact_refs=tuple(a["artifact_id"] for a in snap["artifacts"]),execution_ref=session.session_id,
            uncertainty=("External factual truth remains unverified without evidence.",),
            challengeable=tuple(a["artifact_id"] for a in snap["artifacts"] if a["kind"] in {"reasoning","hypothesis","evaluation","objection","result"}),
            editable=("reasoning branches","hypotheses"), downstream_dependencies=("strategy_construction","verification_explanation"))

class StrategyService(ServiceBase):
    service_type="strategy_construction"
    purpose="Construct multiple feasible, human-reviewable courses of action from the understood situation and evidence."
    def execute(self, req, analysis=None, reasoning=None):
        options=[]
        confidence=analysis.get("structured_data",{}).get("numeric_summary",{}) if analysis else {}
        options.append({"id":"rapid","objective":req.goal,"actions":["Take the smallest reversible next step","Review the observed result"],"prerequisites":["Sufficient information"],"benefits":["fast feedback"],"risks":["higher uncertainty"],"assumptions":["The next step is reversible"]})
        options.append({"id":"validated","objective":req.goal,"actions":["Validate assumptions","Act at checkpoints","Review outcome"],"prerequisites":["Evidence available"],"benefits":["stronger validation"],"risks":["more time"],"assumptions":["Evidence remains relevant"]})
        return self.result(req,content={"options":options},structured={"analysis_basis":confidence},alternatives=tuple(options),
            challengeable=("option assumptions","prerequisites","risk statements"),editable=("options",),downstream_dependencies=("tradeoff_analysis","decision_support"))

class TradeoffService(ServiceBase):
    service_type="tradeoff_analysis"
    purpose="Expose differences between options without inventing unsupported universal scores."
    def execute(self, req, strategy):
        options=strategy.get("content",{}).get("options",[])
        rows=[]
        for o in options:
            rows.append({"id":o["id"],"benefits":o["benefits"],"risks":o["risks"],"prerequisites":o["prerequisites"],"assumptions":o["assumptions"],"uncertainty":"qualitative; no unsupported numeric score"})
        return self.result(req,content={"tradeoffs":rows},structured={"options_compared":len(rows)},alternatives=tuple(rows),challengeable=("benefits","risks","assumptions"),editable=("constraints","assumptions"),downstream_dependencies=("decision_support",))

class DecisionService(ServiceBase):
    service_type="decision_support"
    purpose="Assemble evidence, findings, alternatives and trade-offs into a human-controlled decision space."
    def execute(self, req, situation, evidence, analysis, strategy, tradeoffs):
        return self.result(req,content={"situation":situation.content,"evidence":evidence.content,"analysis":analysis.content,"strategy":strategy.content,"tradeoffs":tradeoffs.content},
            structured={"human_authority_required":True},alternatives=tuple(strategy.content.get("options",[])),
            challengeable=("situation","analysis","strategy","tradeoffs"),editable=("goal","context","options"),
            authorization_state="human-decision-required",downstream_dependencies=("planning",))

class PlanningService(ServiceBase):
    service_type="planning"
    purpose="Turn an accepted or human-modified strategy into an executable plan using explicit dependencies and checkpoints."
    def execute(self, req, strategy):
        opts=strategy.content.get("options",[])
        if not opts: return self.result(req,status="INSUFFICIENT",content={"reason":"No strategy is available for planning."})
        plan=[]
        for o in opts:
            plan.append({"strategy_id":o["id"],"tasks":[{"id":f"{o['id']}-1","action":a,"dependency":None if i==0 else f"{o['id']}-{i}","checkpoint":True} for i,a in enumerate(o["actions"],1)]})
        return self.result(req,content={"plans":plan},structured={"requires_human_acceptance":True},editable=("task sequence","dependencies"),authorization_state="human-acceptance-required")

class VerificationService(ServiceBase):
    service_type="verification_explanation"
    purpose="Expose claims, evidence, provenance, limitations and verification state through existing S8 artifacts."
    def __init__(self,evidence=None): self.evidence=evidence or EvidenceResearchBureau()
    def execute(self, req, source_results):
        refs=tuple(a for r in source_results for a in r.artifact_refs)
        if not refs:
            return self.result(req,status="INSUFFICIENT",content={"reason":"No artifact/evidence references available."})
        verification=self.evidence.verify_claim(req.goal,refs[:8],tenant_id=req.actor_id,context_id=req.request_id)
        explanation=self.evidence.add_artifact(ArtifactKind.EXPLANATION,{"claim":req.goal,"verification_status":verification.status,"evidence_ids":verification.evidence_ids,"limitations":verification.limitations},source_ids=verification.evidence_ids,tenant_id=req.actor_id,context_id=req.request_id,status="inspectable")
        return self.result(req,content={"verification":asdict(verification),"explanation_artifact_id":explanation.artifact_id},
            structured={"verification_status":verification.status},evidence_refs=verification.evidence_ids,artifact_refs=(explanation.artifact_id,),
            uncertainty=tuple(verification.limitations),challengeable=("claim","evidence references","verification status"),editable=("claim","evidence references"))

class OutcomeService(ServiceBase):
    service_type="outcome_learning"
    purpose="Record expected versus actual outcomes and expose a validated-learning boundary without claiming autonomous learning."
    def __init__(self,evidence=None): self.evidence=evidence or EvidenceResearchBureau()
    def record(self, req, expected, actual):
        deviations=tuple(k for k in set(expected)|set(actual) if expected.get(k)!=actual.get(k))
        artifact=self.evidence.add_artifact(ArtifactKind.MEMORY,{"request_id":req.request_id,"expected":expected,"actual":actual,"deviations":deviations,"validated":False,"learning_policy":"review before reuse"},tenant_id=req.actor_id,context_id=req.request_id,status="pending_review")
        return OutcomeRecord(f"OUT-{req.request_id}",req.request_id,expected,actual,deviations,False),artifact.artifact_id
