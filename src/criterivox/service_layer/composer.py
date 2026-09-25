from __future__ import annotations
from .contracts import ServicePlan, ServiceRequest, ServiceResult
from .services import SituationService,EvidenceDataService,AnalyticalService,ReasoningService,StrategyService,TradeoffService,DecisionService,PlanningService,VerificationService,OutcomeService

class ServiceComposer:
    """Capability-driven service composition. Characters never select services."""
    def __init__(self):
        self.situation=SituationService()
        self.evidence=EvidenceDataService(evidence=None)
        self.analysis=AnalyticalService()
        self.reasoning=ReasoningService()
        self.strategy=StrategyService()
        self.tradeoffs=TradeoffService()
        self.decision=DecisionService()
        self.planning=PlanningService()
        self.verification=VerificationService(self.evidence.evidence)
        self.outcomes=OutcomeService(self.evidence.evidence)

    def plan(self, req: ServiceRequest, intent: str | None=None) -> ServicePlan:
        text=f"{req.goal} {req.context}".lower()
        intent=intent or ("planning" if any(x in text for x in ("plan","planning","schedule","organize")) else
                          "analysis" if any(x in text for x in ("analyse","analyze","csv","dataset","data","trend","compare")) else
                          "strategy" if any(x in text for x in ("strategy","decide","decision","option","choose")) else "support")
        if intent=="analysis":
            services=("situation_understanding","evidence_data_analysis","analytical_reporting","verification_explanation")
        elif intent=="planning":
            services=("situation_understanding","strategy_construction","tradeoff_analysis","planning")
        elif intent=="strategy":
            services=("situation_understanding","evidence_data_analysis","analytical_reporting","reasoning_hypothesis","strategy_construction","tradeoff_analysis","decision_support","verification_explanation")
        else:
            services=("situation_understanding","evidence_data_analysis","analytical_reporting","verification_explanation")
        return ServicePlan(req.request_id,services,("Selected from request/context semantics; no character determines routing.",))

    def execute(self, req: ServiceRequest) -> tuple[ServicePlan,dict[str,ServiceResult]]:
        situation=self.situation.execute(req)
        results={"situation_understanding":situation}
        if not situation.sufficient: return self.plan(req),results
        plan=self.plan(req,situation.structured_data.get("intent"))
        evidence=self.evidence.execute(req); results["evidence_data_analysis"]=evidence
        if "analytical_reporting" in plan.services:
            analysis=self.analysis.execute(req,evidence.structured_data); results["analytical_reporting"]=analysis
        else: analysis=None
        if "reasoning_hypothesis" in plan.services:
            reasoning=self.reasoning.execute(req,evidence.structured_data); results["reasoning_hypothesis"]=reasoning
        else: reasoning=None
        if "strategy_construction" in plan.services:
            strategy=self.strategy.execute(req,analysis,reasoning); results["strategy_construction"]=strategy
        else: strategy=None
        if "tradeoff_analysis" in plan.services and strategy:
            trade=self.tradeoffs.execute(req,strategy); results["tradeoff_analysis"]=trade
        else: trade=None
        if "decision_support" in plan.services and strategy and trade:
            results["decision_support"]=self.decision.execute(req,situation,evidence,analysis or evidence,strategy,trade)
        if "planning" in plan.services and strategy:
            results["planning"]=self.planning.execute(req,strategy)
        verification_inputs=tuple(results.values())
        if "verification_explanation" in plan.services:
            results["verification_explanation"]=self.verification.execute(req,verification_inputs)
        return plan,results

    def record_outcome(self, req: ServiceRequest, expected, actual):
        return self.outcomes.record(req,expected,actual)

service_composer=ServiceComposer()


# Service composition remains character-independent; presentation adapters consume ServiceResult.
