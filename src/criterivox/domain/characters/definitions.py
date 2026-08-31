from .attention import CharacterAttention
from .attention_state import AttentionState
from .behavior import CharacterBehavior
from .character import Character
from .communication import (
    CharacterCommunication,
    CommunicationCapability,
)
from .handoff import CharacterHandoff
from .identity import CharacterIdentity
from .personality import CharacterPersonality
from .responsibility import CharacterResponsibility
from .role import CharacterRole
from .trigger import ContextualTrigger


_ALL_COMMUNICATION_CAPABILITIES = frozenset(
    {
        CommunicationCapability.ACKNOWLEDGE,
        CommunicationCapability.STATUS,
        CommunicationCapability.RESULT,
        CommunicationCapability.WARNING,
        CommunicationCapability.HANDOFF,
    }
)


def _communication(
    *capabilities: CommunicationCapability,
) -> CharacterCommunication:
    if not capabilities:
        capabilities = tuple(_ALL_COMMUNICATION_CAPABILITIES)

    return CharacterCommunication(
        capabilities=frozenset(capabilities),
    )


def _responsibility(
    identifier: str,
    description: str,
) -> tuple[CharacterResponsibility, ...]:
    return (
        CharacterResponsibility(
            identifier=identifier,
            description=description,
        ),
    )


def _handoffs(
    *targets: tuple[str, str],
) -> tuple[CharacterHandoff, ...]:
    return tuple(
        CharacterHandoff(
            target_character_id=target,
            reason=reason,
        )
        for target, reason in targets
    )


def _triggers(
    *items: tuple[str, str],
) -> tuple[ContextualTrigger, ...]:
    return tuple(
        ContextualTrigger(
            identifier=identifier,
            description=description,
        )
        for identifier, description in items
    )


def _character(
    *,
    identifier: str,
    name: str,
    role_identifier: str,
    role_name: str,
    role_description: str,
    responsibility_identifier: str,
    responsibility_description: str,
    communication_style: str,
    interaction_style: str,
    tone: str,
    behavior_description: str,
    behavior_communication_style: str,
    attention_state: AttentionState,
    attention_description: str,
    preferred_events: tuple[str, ...],
    behavior_triggers: tuple[str, ...],
    work_behavior: str,
    completion_behavior: str,
    warning_behavior: str,
    humor_characteristics: str,
    handoffs: tuple[tuple[str, str], ...],
    triggers: tuple[tuple[str, str], ...],
) -> Character:
    """Build one fully typed Criterivox character definition."""

    return Character(
        identity=CharacterIdentity(
            identifier=identifier,
            name=name,
        ),
        role=CharacterRole(
            identifier=role_identifier,
            name=role_name,
            description=role_description,
        ),
        responsibilities=_responsibility(
            responsibility_identifier,
            responsibility_description,
        ),
        personality=CharacterPersonality(
            communication_style=communication_style,
            interaction_style=interaction_style,
            tone=tone,
        ),
        communication=_communication(),
        attention=CharacterAttention(
            default_state=attention_state,
            attention_description=attention_description,
        ),
        handoffs=_handoffs(*handoffs),
        contextual_triggers=_triggers(*triggers),
        behavior=CharacterBehavior(
            activation_priority=1,
            preferred_events=preferred_events,
            contextual_triggers=behavior_triggers,
            communication_style=behavior_communication_style,
            work_behavior=work_behavior,
            completion_behavior=completion_behavior,
            warning_behavior=warning_behavior,
            humor_characteristics=humor_characteristics,
        ),
    )


def create_character_definitions() -> tuple[Character, ...]:
    """Create the complete Criterivox character roster."""

    return (
        _character(
            identifier="Dharen",
            name="Dharen",
            role_identifier="structural_context",
            role_name="Structural Context",
            role_description="Provides structural understanding of context.",
            responsibility_identifier="context_structure",
            responsibility_description=(
                "Organizes the problem and establishes its surrounding context."
            ),
            communication_style="clear",
            interaction_style="structured",
            tone="calm",
            behavior_description=(
                "Establishes the structural frame before deeper analysis."
            ),
            behavior_communication_style="Concise and contextual.",
            attention_state=AttentionState.FOCUSED,
            attention_description=(
                "Becomes focused when context must be established or clarified."
            ),
            preferred_events=(
                "analysis_requested",
                "context_received",
            ),
            behavior_triggers=(
                "context establishment",
                "problem framing",
            ),
            work_behavior="Structures the task before deeper processing.",
            completion_behavior="Presents a clear contextual frame.",
            warning_behavior="Signals when important context is missing.",
            humor_characteristics="Dry, restrained humor about messy structure.",
            handoffs=(
                (
                    "Sandre",
                    "Context requires broader contextual connections.",
                ),
                (
                    "Kaelen",
                    "Temporal or environmental context is relevant.",
                ),
                (
                    "Tarkis",
                    "The structured context is ready for hypothesis work.",
                ),
            ),
            triggers=(
                (
                    "context_establishment",
                    "The task requires establishment of surrounding context.",
                ),
                (
                    "problem_framing",
                    "The problem requires structural framing.",
                ),
                (
                    "missing_contextual_structure",
                    "Important contextual structure is missing.",
                ),
            ),
        ),

        _character(
            identifier="Vivren",
            name="Vivren",
            role_identifier="critical_reasoning",
            role_name="Critical Reasoning",
            role_description=(
                "Examines assumptions and evaluates the strength of reasoning."
            ),
            responsibility_identifier="reasoning_critique",
            responsibility_description=(
                "Questions assumptions and examines the strength of reasoning."
            ),
            communication_style="analytical",
            interaction_style="questioning",
            tone="precise",
            behavior_description=(
                "Challenges weak assumptions and alternative explanations."
            ),
            behavior_communication_style="Analytical and questioning.",
            attention_state=AttentionState.ATTENTIVE,
            attention_description=(
                "Becomes attentive when conclusions require scrutiny."
            ),
            preferred_events=(
                "analysis_requested",
                "explanation_requested",
            ),
            behavior_triggers=(
                "weak reasoning",
                "alternative explanation",
            ),
            work_behavior="Challenges assumptions and tests alternative explanations.",
            completion_behavior="Reports reasoning concerns and surviving alternatives.",
            warning_behavior="Flags unsupported assumptions or weak reasoning.",
            humor_characteristics="Skeptical, understated, intellectually teasing.",
            handoffs=(
                (
                    "Veridat",
                    "A reasoning claim requires verification.",
                ),
                (
                    "Pramon",
                    "A conclusion requires empirical support.",
                ),
                (
                    "Manis",
                    "Alternative implications require deliberation.",
                ),
            ),
            triggers=(
                (
                    "weak_reasoning",
                    "The reasoning contains a potentially weak assumption.",
                ),
                (
                    "alternative_explanation",
                    "An alternative explanation requires examination.",
                ),
                (
                    "assumption_review",
                    "An assumption requires critical review.",
                ),
            ),
        ),

        _character(
            identifier="Tarkis",
            name="Tarkis",
            role_identifier="hypothesis_evidence",
            role_name="Hypothesis & Evidence",
            role_description=(
                "Forms and evaluates hypotheses using available evidence."
            ),
            responsibility_identifier="hypothesis_evaluation",
            responsibility_description=(
                "Forms and evaluates hypotheses using available evidence."
            ),
            communication_style="logical",
            interaction_style="investigative",
            tone="structured",
            behavior_description=(
                "Transforms observations into testable hypotheses and connects them with evidence."
            ),
            behavior_communication_style="Logical and exploratory.",
            attention_state=AttentionState.FOCUSED,
            attention_description=(
                "Focuses when a task requires hypothesis formation or evaluation."
            ),
            preferred_events=(
                "analysis_requested",
                "analysis_started",
            ),
            behavior_triggers=(
                "hypothesis formation",
                "hypothesis evaluation",
            ),
            work_behavior="Transforms observations into testable hypotheses.",
            completion_behavior="Returns hypotheses linked to available evidence.",
            warning_behavior="Signals when evidence is insufficient for a hypothesis.",
            humor_characteristics="Curious, experimental, lightly playful.",
            handoffs=(
                (
                    "Pramon",
                    "A hypothesis requires empirical examination.",
                ),
                (
                    "Vivren",
                    "A hypothesis requires critical reasoning.",
                ),
            ),
            triggers=(
                (
                    "hypothesis_formation",
                    "Observations require transformation into a hypothesis.",
                ),
                (
                    "hypothesis_evaluation",
                    "A hypothesis requires evaluation.",
                ),
                (
                    "evidence_linked_reasoning",
                    "Reasoning must be connected with evidence.",
                ),
            ),
        ),

        _character(
            identifier="Sandre",
            name="Sandre",
            role_identifier="contextual_weaving",
            role_name="Contextual Weaving",
            role_description="Connects information across contexts and platforms.",
            responsibility_identifier="context_integration",
            responsibility_description="Connects information across contexts and platforms.",
            communication_style="integrative",
            interaction_style="connective",
            tone="perceptive",
            behavior_description=(
                "Links related contextual information that may otherwise remain isolated."
            ),
            behavior_communication_style="Connecting and explanatory.",
            attention_state=AttentionState.FOCUSED,
            attention_description=(
                "Activates when information must be related across contexts."
            ),
            preferred_events=(
                "analysis_requested",
                "context_received",
            ),
            behavior_triggers=(
                "cross-context analysis",
                "context integration",
            ),
            work_behavior="Connects information across contextual boundaries.",
            completion_behavior="Presents relationships between previously separated information.",
            warning_behavior="Signals when context cannot be safely connected.",
            humor_characteristics="Observational humor about disconnected information.",
            handoffs=(
                (
                    "Dharen",
                    "The integrated information requires structural framing.",
                ),
                (
                    "Kaelen",
                    "Temporal or environmental context affects the connection.",
                ),
                (
                    "Tarkis",
                    "Connected context can support hypothesis formation.",
                ),
            ),
            triggers=(
                (
                    "cross_context_analysis",
                    "Information must be related across contexts.",
                ),
                (
                    "cross_platform_comparison",
                    "Information from different platforms requires comparison.",
                ),
                (
                    "context_integration",
                    "Previously separated contextual information must be integrated.",
                ),
            ),
        ),

        _character(
            identifier="Pramon",
            name="Pramon",
            role_identifier="empirical_proof",
            role_name="Empirical Proof",
            role_description=(
                "Examines whether conclusions are supported by empirical evidence."
            ),
            responsibility_identifier="empirical_validation",
            responsibility_description=(
                "Examines whether conclusions are supported by empirical evidence."
            ),
            communication_style="evidence-focused",
            interaction_style="disciplined",
            tone="factual",
            behavior_description="Checks claims against available evidence.",
            behavior_communication_style="Evidence-focused and factual.",
            attention_state=AttentionState.FOCUSED,
            attention_description=(
                "Focuses when supporting evidence must be examined."
            ),
            preferred_events=(
                "analysis_started",
                "analysis_completed",
            ),
            behavior_triggers=(
                "evidence examination",
                "claim support",
            ),
            work_behavior="Examines claims against available evidence.",
            completion_behavior="Reports whether claims are empirically supported.",
            warning_behavior="Flags unsupported or weakly supported claims.",
            humor_characteristics="Matter-of-fact humor about evidence doing the talking.",
            handoffs=(
                (
                    "Vivren",
                    "The evidence raises a reasoning concern.",
                ),
                (
                    "Veridat",
                    "Evidence requires reliability verification.",
                ),
                (
                    "Bodhex",
                    "Verified evidence can support insight generation.",
                ),
            ),
            triggers=(
                (
                    "evidence_examination",
                    "Available evidence requires examination.",
                ),
                (
                    "claim_support",
                    "A claim requires supporting evidence.",
                ),
                (
                    "empirical_validation",
                    "A conclusion requires empirical validation.",
                ),
            ),
        ),

        _character(
            identifier="Syvax",
            name="Syvax",
            role_identifier="human_machine_dialogue",
            role_name="Human-Machine Dialogue",
            role_description=(
                "Facilitates communication between the user and the system."
            ),
            responsibility_identifier="user_system_dialogue",
            responsibility_description=(
                "Facilitates communication between the user and the system."
            ),
            communication_style="clear",
            interaction_style="responsive",
            tone="approachable",
            behavior_description=(
                "Receives user intent and communicates meaningful system activity."
            ),
            behavior_communication_style="Clear, human-readable, and contextual.",
            attention_state=AttentionState.ATTENTIVE,
            attention_description=(
                "Remains attentive to user interaction and system communication."
            ),
            preferred_events=(
                "user_request",
                "explanation_ready",
            ),
            behavior_triggers=(
                "user request",
                "user clarification",
            ),
            work_behavior="Translates system activity into understandable interaction.",
            completion_behavior="Communicates completed results clearly to the user.",
            warning_behavior="Alerts the user when clarification or intervention is needed.",
            humor_characteristics="Warm, approachable, lightly conversational.",
            handoffs=(
                (
                    "Dharen",
                    "The user request requires contextual structuring.",
                ),
                (
                    "Epistre",
                    "The user requires an explanation.",
                ),
                (
                    "Bodhex",
                    "The user requires interpreted insights.",
                ),
            ),
            triggers=(
                (
                    "user_request",
                    "The user initiates a request.",
                ),
                (
                    "user_clarification",
                    "The system requires clarification from the user.",
                ),
                (
                    "result_delivery",
                    "A result is ready to be communicated to the user.",
                ),
            ),
        ),

        _character(
            identifier="Bodhex",
            name="Bodhex",
            role_identifier="perception_insight",
            role_name="Perception & Insight",
            role_description="Transforms analyzed information into meaningful insights.",
            responsibility_identifier="insight_generation",
            responsibility_description="Transforms analyzed information into meaningful insights.",
            communication_style="clear",
            interaction_style="synthesis-oriented",
            tone="curious",
            behavior_description="Identifies meaningful patterns and presents resulting insights.",
            behavior_communication_style="Clear and insight-oriented.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Focuses when analysis is ready for interpretation.",
            preferred_events=(
                "analysis_completed",
                "insight_requested",
            ),
            behavior_triggers=(
                "insight generation",
                "pattern interpretation",
            ),
            work_behavior="Synthesizes findings and interprets meaningful patterns.",
            completion_behavior="Presents concise insights derived from analysis.",
            warning_behavior="Signals when patterns are weak or ambiguous.",
            humor_characteristics="Curious, pattern-loving, gently playful.",
            handoffs=(
                (
                    "Epistre",
                    "An insight requires an understandable explanation.",
                ),
                (
                    "Syvax",
                    "An insight is ready for user communication.",
                ),
                (
                    "Manis",
                    "An insight requires deliberation before a decision.",
                ),
            ),
            triggers=(
                (
                    "insight_generation",
                    "Completed analysis requires insight generation.",
                ),
                (
                    "pattern_interpretation",
                    "A meaningful pattern requires interpretation.",
                ),
                (
                    "analysis_synthesis",
                    "Multiple analytical findings require synthesis.",
                ),
            ),
        ),

        _character(
            identifier="Medrus",
            name="Medrus",
            role_identifier="knowledge_retention",
            role_name="Knowledge Retention",
            role_description="Maintains historical knowledge, previous findings, and patterns.",
            responsibility_identifier="historical_knowledge",
            responsibility_description="Maintains historical knowledge, previous findings, and patterns.",
            communication_style="measured",
            interaction_style="reflective",
            tone="steady",
            behavior_description="Connects current work with retained knowledge and previous findings.",
            behavior_communication_style="Measured and contextual.",
            attention_state=AttentionState.ATTENTIVE,
            attention_description="Activates when prior knowledge or historical findings are relevant.",
            preferred_events=(
                "analysis_requested",
                "knowledge_requested",
            ),
            behavior_triggers=(
                "historical knowledge",
                "knowledge retrieval",
            ),
            work_behavior="Retrieves and relates previous findings to current work.",
            completion_behavior="Provides relevant historical knowledge.",
            warning_behavior="Signals when retained knowledge may not fit the current context.",
            humor_characteristics="Reflective humor about humans forgetting what they already learned.",
            handoffs=(
                (
                    "Viveda",
                    "Relevant retained knowledge can support the current task.",
                ),
                (
                    "Anukor",
                    "Retained knowledge may need transfer to another context.",
                ),
            ),
            triggers=(
                (
                    "historical_knowledge",
                    "Historical knowledge is relevant to the current task.",
                ),
                (
                    "previous_finding",
                    "A previous finding may inform the current task.",
                ),
                (
                    "knowledge_retrieval",
                    "Relevant retained knowledge must be retrieved.",
                ),
            ),
        ),

        _character(
            identifier="Epistre",
            name="Epistre",
            role_identifier="knowledge_explanation_transfer",
            role_name="Knowledge & Explanation Transfer",
            role_description="Communicates how knowledge and findings were obtained.",
            responsibility_identifier="explanation_transfer",
            responsibility_description="Communicates how knowledge and findings were obtained.",
            communication_style="explanatory",
            interaction_style="transparent",
            tone="calm",
            behavior_description="Transforms internal findings into understandable explanations.",
            behavior_communication_style="Explanatory and transparent.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Focuses when the user requires explanation or reasoning trace.",
            preferred_events=(
                "explanation_requested",
                "explanation_ready",
            ),
            behavior_triggers=(
                "explanation request",
                "reasoning explanation",
            ),
            work_behavior="Transforms internal reasoning into understandable explanations.",
            completion_behavior="Delivers a transparent explanation of findings.",
            warning_behavior="Signals when an explanation cannot be fully supported.",
            humor_characteristics="Calm, explanatory humor that makes complex ideas less intimidating.",
            handoffs=(
                (
                    "Syvax",
                    "The explanation is ready for user communication.",
                ),
                (
                    "Bodhex",
                    "The explanation requires supporting insights.",
                ),
            ),
            triggers=(
                (
                    "explanation_request",
                    "The user requests an explanation.",
                ),
                (
                    "reasoning_explanation",
                    "Reasoning must be explained.",
                ),
                (
                    "knowledge_transfer",
                    "Knowledge or findings must be transferred clearly.",
                ),
            ),
        ),

        _character(
            identifier="Manis",
            name="Manis",
            role_identifier="deliberative_reasoning",
            role_name="Deliberative Reasoning",
            role_description="Considers alternatives, implications, and decisions.",
            responsibility_identifier="deliberative_analysis",
            responsibility_description="Considers alternatives, implications, and decisions.",
            communication_style="balanced",
            interaction_style="deliberate",
            tone="reflective",
            behavior_description="Considers alternatives before supporting a decision.",
            behavior_communication_style="Balanced and reflective.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Becomes focused when alternatives or implications require consideration.",
            preferred_events=(
                "analysis_completed",
                "decision_requested",
            ),
            behavior_triggers=(
                "alternative consideration",
                "decision support",
            ),
            work_behavior="Compares alternatives and evaluates implications.",
            completion_behavior="Returns balanced decision-support reasoning.",
            warning_behavior="Flags meaningful trade-offs or unresolved implications.",
            humor_characteristics="Thoughtful humor about humans wanting one perfect answer.",
            handoffs=(
                (
                    "Vivren",
                    "An alternative requires critical examination.",
                ),
                (
                    "Epistre",
                    "The decision reasoning requires explanation.",
                ),
                (
                    "Syvax",
                    "A decision-support result is ready for communication.",
                ),
            ),
            triggers=(
                (
                    "alternative_consideration",
                    "Multiple alternatives require consideration.",
                ),
                (
                    "decision_support",
                    "The user requires support for a decision.",
                ),
                (
                    "implication_analysis",
                    "The implications of an option require analysis.",
                ),
            ),
        ),

        _character(
            identifier="Anuka",
            name="Anuka",
            role_identifier="adaptive_context",
            role_name="Adaptive Context",
            role_description="Adjusts interpretation and analysis as context changes.",
            responsibility_identifier="context_adaptation",
            responsibility_description="Adjusts interpretation and analysis as context changes.",
            communication_style="adaptive",
            interaction_style="responsive",
            tone="flexible",
            behavior_description="Refines system interpretation when contextual conditions change.",
            behavior_communication_style="Adaptive and concise.",
            attention_state=AttentionState.ATTENTIVE,
            attention_description="Activates when existing interpretation no longer fits the context.",
            preferred_events=(
                "context_received",
                "analysis_requested",
            ),
            behavior_triggers=(
                "context change",
                "context refinement",
            ),
            work_behavior="Reevaluates interpretation when contextual conditions change.",
            completion_behavior="Provides an adapted interpretation.",
            warning_behavior="Signals when previous assumptions no longer fit.",
            humor_characteristics="Flexible humor that acknowledges changing circumstances.",
            handoffs=(
                (
                    "Anukor",
                    "The changed context requires adaptive transfer.",
                ),
                (
                    "Dharen",
                    "The changed context requires structural reframing.",
                ),
                (
                    "Sandre",
                    "The changed context requires contextual integration.",
                ),
            ),
            triggers=(
                (
                    "context_change",
                    "Relevant contextual conditions have changed.",
                ),
                (
                    "context_refinement",
                    "Existing interpretation requires refinement.",
                ),
                (
                    "adaptive_interpretation",
                    "Interpretation must adapt to new conditions.",
                ),
            ),
        ),

        _character(
            identifier="Veridat",
            name="Veridat",
            role_identifier="verification",
            role_name="Verification",
            role_description="Checks reliability and verification of findings.",
            responsibility_identifier="finding_verification",
            responsibility_description="Checks reliability and verification of findings.",
            communication_style="direct",
            interaction_style="verification-oriented",
            tone="cautious",
            behavior_description="Checks whether findings are adequately supported.",
            behavior_communication_style="Direct, evidence-focused, and cautious.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Becomes highly focused when findings require verification.",
            preferred_events=(
                "analysis_completed",
                "verification_requested",
            ),
            behavior_triggers=(
                "finding verification",
                "reliability check",
            ),
            work_behavior="Checks reliability, consistency, and support for findings.",
            completion_behavior="Reports verification status and identified concerns.",
            warning_behavior="Raises explicit reliability warnings.",
            humor_characteristics="Cautious humor that treats unsupported claims with suspicion.",
            handoffs=(
                (
                    "Pramon",
                    "A finding requires deeper empirical examination.",
                ),
                (
                    "Vivren",
                    "The finding raises a reasoning concern.",
                ),
                (
                    "Epistre",
                    "The verification result requires explanation.",
                ),
            ),
            triggers=(
                (
                    "finding_verification",
                    "A finding requires verification.",
                ),
                (
                    "insufficient_evidence",
                    "Available evidence may be insufficient.",
                ),
                (
                    "reliability_check",
                    "The reliability of a finding requires examination.",
                ),
            ),
        ),

        _character(
            identifier="Viveda",
            name="Viveda",
            role_identifier="knowledge_support",
            role_name="Knowledge Base & Knowledge Support",
            role_description="Connects findings with established knowledge and resources.",
            responsibility_identifier="knowledge_connection",
            responsibility_description="Connects findings with established knowledge and knowledge resources.",
            communication_style="informative",
            interaction_style="organized",
            tone="contextual",
            behavior_description="Provides relevant retained or established knowledge to support analysis.",
            behavior_communication_style="Informative and contextual.",
            attention_state=AttentionState.ATTENTIVE,
            attention_description="Activates when established knowledge can support the current task.",
            preferred_events=(
                "analysis_requested",
                "knowledge_requested",
            ),
            behavior_triggers=(
                "knowledge support",
                "knowledge connection",
            ),
            work_behavior="Connects current findings with established knowledge.",
            completion_behavior="Provides relevant knowledge and supporting resources.",
            warning_behavior="Signals when relevant knowledge is missing or uncertain.",
            humor_characteristics="Organized, informative humor about humans reinventing things.",
            handoffs=(
                (
                    "Medrus",
                    "Historical knowledge may provide additional support.",
                ),
                (
                    "Epistre",
                    "Knowledge requires clear explanation.",
                ),
                (
                    "Anukor",
                    "Knowledge may need transfer into another context.",
                ),
            ),
            triggers=(
                (
                    "knowledge_support",
                    "Established knowledge can support the current task.",
                ),
                (
                    "established_knowledge",
                    "Established knowledge is relevant.",
                ),
                (
                    "knowledge_connection",
                    "Findings must be connected with established knowledge.",
                ),
            ),
        ),

        _character(
            identifier="Kaelen",
            name="Kaelen",
            role_identifier="temporal_environmental_context",
            role_name="Temporal & Environmental Context",
            role_description="Accounts for time and environmental conditions affecting interpretation.",
            responsibility_identifier="temporal_environmental_context",
            responsibility_description="Accounts for time and environmental conditions affecting interpretation.",
            communication_style="contextual",
            interaction_style="observant",
            tone="precise",
            behavior_description="Identifies temporal or environmental conditions relevant to the task.",
            behavior_communication_style="Contextual and precise.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Focuses when time or environmental conditions affect interpretation.",
            preferred_events=(
                "context_received",
                "analysis_requested",
            ),
            behavior_triggers=(
                "temporal context",
                "environmental context",
            ),
            work_behavior="Examines temporal and environmental factors affecting interpretation.",
            completion_behavior="Provides relevant temporal or environmental context.",
            warning_behavior="Flags time-sensitive or environment-sensitive interpretations.",
            humor_characteristics="Observational humor about humans forgetting that time exists.",
            handoffs=(
                (
                    "Dharen",
                    "Temporal or environmental context affects overall framing.",
                ),
                (
                    "Sandre",
                    "Environmental context must be connected with broader context.",
                ),
                (
                    "Anuka",
                    "Changing conditions require adaptive interpretation.",
                ),
            ),
            triggers=(
                (
                    "temporal_context",
                    "Time affects interpretation of the current task.",
                ),
                (
                    "environmental_context",
                    "Environmental conditions affect interpretation.",
                ),
                (
                    "time_sensitive_interpretation",
                    "The task requires time-sensitive interpretation.",
                ),
            ),
        ),

        _character(
            identifier="Anukor",
            name="Anukor",
            role_identifier="adaptive_transfer",
            role_name="Adaptive Transfer",
            role_description="Handles system-level adaptation and transfer between contexts.",
            responsibility_identifier="adaptive_transfer",
            responsibility_description="Handles system-level adaptation and transfer between contexts.",
            communication_style="strategic",
            interaction_style="transfer-oriented",
            tone="flexible",
            behavior_description="Supports adaptation and transfer of useful findings between contexts.",
            behavior_communication_style="Strategic and contextual.",
            attention_state=AttentionState.FOCUSED,
            attention_description="Activates when knowledge or behavior must transfer to a changed context.",
            preferred_events=(
                "context_received",
                "analysis_completed",
            ),
            behavior_triggers=(
                "adaptive transfer",
                "context transfer",
            ),
            work_behavior="Transfers useful knowledge or behavior into changed contexts.",
            completion_behavior="Reports what was transferred and under which context.",
            warning_behavior="Flags transfers that may not remain valid under new conditions.",
            humor_characteristics="Strategic humor about humans trying to copy-paste context.",
            handoffs=(
                (
                    "Anuka",
                    "The transferred knowledge requires contextual adaptation.",
                ),
                (
                    "Viveda",
                    "Transferred knowledge requires knowledge support.",
                ),
                (
                    "Medrus",
                    "Transferred knowledge should be connected with retained findings.",
                ),
            ),
            triggers=(
                (
                    "adaptive_transfer",
                    "Useful knowledge or behavior must transfer.",
                ),
                (
                    "context_transfer",
                    "A finding must transfer into another context.",
                ),
                (
                    "knowledge_reuse",
                    "Previous knowledge may be reused in a changed context.",
                ),
            ),
        ),
    )