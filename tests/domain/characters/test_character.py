import pytest

from criterivox.domain.characters.attention import CharacterAttention
from criterivox.domain.characters.attention_state import AttentionState
from criterivox.domain.characters import (
    AnimationState,
    Character,
    CharacterBehavior,
    CharacterCommunication,
    CharacterHandoff,
    CharacterIdentity,
    CharacterPersonality,
    CharacterResponsibility,
    CharacterRole,
    CharacterState,
    CommunicationCapability,
    ContextualTrigger,
)


def make_character() -> Character:
    return Character(
        identity=CharacterIdentity(
            identifier="dharen",
            name="Dharen",
        ),
        role=CharacterRole(
            identifier="structural_context",
            name="Structural Context",
            description="Provides structural understanding of context.",
        ),
        responsibilities=(
            CharacterResponsibility(
                identifier="context_structure",
                description="Organize contextual information.",
            ),
        ),
        personality=CharacterPersonality(
            communication_style="clear",
            interaction_style="structured",
            tone="calm",
        ),
        behavior=CharacterBehavior(
            activation_priority=1,
            preferred_events=("analysis_requested",),
            contextual_triggers=("analysis",),
            communication_style="clear",
            work_behavior="Structures the task before deeper processing.",
            completion_behavior="Presents a clear contextual frame.",
            warning_behavior="Signals when important context is missing.",
            humor_characteristics=(
                "Dry, restrained humor about messy structure."
            ),
        ),
        communication=CharacterCommunication(
            capabilities=frozenset(
                {
                    CommunicationCapability.ACKNOWLEDGE,
                    CommunicationCapability.STATUS,
                    CommunicationCapability.RESULT,
                    CommunicationCapability.WARNING,
                    CommunicationCapability.HANDOFF,
                }
            )
        ),
        attention=CharacterAttention(
            default_state=AttentionState.QUIET,
            attention_description="Remains quiet until relevant.",
        ),
        handoffs=(
            CharacterHandoff(
                target_character_id="veridat",
                reason="Evidence requires verification.",
            ),
        ),
        contextual_triggers=(
            ContextualTrigger(
                identifier="analysis_requested",
                description="The user requests analytical processing.",
            ),
        ),
    )


def test_character_can_be_created() -> None:
    character = make_character()

    assert character.identity.name == "Dharen"
    assert character.role.name == "Structural Context"
    assert len(character.responsibilities) == 1
    assert character.personality.tone == "calm"


def test_character_requires_responsibility() -> None:
    with pytest.raises(ValueError):
        Character(
            identity=CharacterIdentity("dharen", "Dharen"),
            role=CharacterRole(
                "structural_context",
                "Structural Context",
                "Provides structural understanding of context.",
            ),
            responsibilities=(),
            personality=CharacterPersonality(
                "clear",
                "structured",
                "calm",
            ),
            behavior=CharacterBehavior(
                activation_priority=1,
                preferred_events=("analysis_requested",),
                contextual_triggers=("analysis",),
                communication_style="clear",
                work_behavior="Structures the task.",
                completion_behavior="Reports completion.",
                warning_behavior="Reports warnings.",
                humor_characteristics="Dry humor.",
            ),
            communication=CharacterCommunication(
                capabilities=frozenset(
                    {
                        CommunicationCapability.ACKNOWLEDGE,
                        CommunicationCapability.STATUS,
                        CommunicationCapability.RESULT,
                        CommunicationCapability.WARNING,
                        CommunicationCapability.HANDOFF,
                    }
                )
            ),
            attention=CharacterAttention(
                default_state=AttentionState.QUIET,
                attention_description="Remains quiet until relevant.",
            ),
            handoffs=(),
            contextual_triggers=(),
        )


def test_identity_rejects_empty_name() -> None:
    with pytest.raises(ValueError):
        CharacterIdentity(
            identifier="dharen",
            name="",
        )


def test_role_rejects_empty_description() -> None:
    with pytest.raises(ValueError):
        CharacterRole(
            identifier="structural_context",
            name="Structural Context",
            description="",
        )


def test_character_behavior_is_available() -> None:
    character = make_character()

    assert character.behavior.activation_priority == 1
    assert "analysis_requested" in character.behavior.preferred_events
    assert character.behavior.work_behavior
    assert character.behavior.completion_behavior
    assert character.behavior.warning_behavior
    assert character.behavior.humor_characteristics


def test_character_behavior_rejects_negative_priority() -> None:
    with pytest.raises(ValueError):
        CharacterBehavior(
            activation_priority=-1,
            preferred_events=(),
            contextual_triggers=(),
            communication_style="clear",
            work_behavior="Structures the task.",
            completion_behavior="Reports completion.",
            warning_behavior="Reports warnings.",
            humor_characteristics="Dry humor.",
        )


def test_character_behavior_requires_work_behavior() -> None:
    with pytest.raises(ValueError, match="Work behavior"):
        CharacterBehavior(
            activation_priority=1,
            preferred_events=(),
            contextual_triggers=(),
            communication_style="clear",
            work_behavior="   ",
            completion_behavior="Reports completion.",
            warning_behavior="Reports warnings.",
            humor_characteristics="Dry humor.",
        )


def test_character_behavior_requires_completion_behavior() -> None:
    with pytest.raises(ValueError, match="Completion behavior"):
        CharacterBehavior(
            activation_priority=1,
            preferred_events=(),
            contextual_triggers=(),
            communication_style="clear",
            work_behavior="Structures the task.",
            completion_behavior="   ",
            warning_behavior="Reports warnings.",
            humor_characteristics="Dry humor.",
        )


def test_character_behavior_requires_warning_behavior() -> None:
    with pytest.raises(ValueError, match="Warning behavior"):
        CharacterBehavior(
            activation_priority=1,
            preferred_events=(),
            contextual_triggers=(),
            communication_style="clear",
            work_behavior="Structures the task.",
            completion_behavior="Reports completion.",
            warning_behavior="   ",
            humor_characteristics="Dry humor.",
        )


def test_character_behavior_requires_humor_characteristics() -> None:
    with pytest.raises(ValueError, match="Humor characteristics"):
        CharacterBehavior(
            activation_priority=1,
            preferred_events=(),
            contextual_triggers=(),
            communication_style="clear",
            work_behavior="Structures the task.",
            completion_behavior="Reports completion.",
            warning_behavior="Reports warnings.",
            humor_characteristics="   ",
        )


def test_character_states_are_defined() -> None:
    assert CharacterState.IDLE.value == "idle"
    assert CharacterState.WORK.value == "work"
    assert CharacterState.HANDOFF.value == "handoff"
    assert CharacterState.WARNING.value == "warning"


def test_attention_states_are_defined() -> None:
    assert AttentionState.QUIET.value == "quiet"
    assert AttentionState.FOCUSED.value == "focused"
    assert AttentionState.WAITING.value == "waiting"


def test_animation_states_are_defined() -> None:
    assert AnimationState.IDLE.value == "idle"
    assert AnimationState.WORK.value == "work"
    assert AnimationState.COMPLETE.value == "complete"


def test_character_communication_capability() -> None:
    character = make_character()

    assert character.communication.supports(
        CommunicationCapability.STATUS
    )
    assert character.communication.supports(
        CommunicationCapability.RESULT
    )


def test_character_handoff_is_represented() -> None:
    character = make_character()

    assert len(character.handoffs) == 1
    assert character.handoffs[0].target_character_id == "veridat"


def test_character_contextual_trigger_is_represented() -> None:
    character = make_character()

    assert len(character.contextual_triggers) == 1
    assert (
        character.contextual_triggers[0].identifier
        == "analysis_requested"
    )


def test_handoff_requires_target() -> None:
    with pytest.raises(ValueError):
        CharacterHandoff(
            target_character_id="",
            reason="Evidence requires verification.",
        )


def test_trigger_requires_identifier() -> None:
    with pytest.raises(ValueError):
        ContextualTrigger(
            identifier="",
            description="The user requests analysis.",
        )


def test_communication_capability_can_be_absent() -> None:
    communication = CharacterCommunication(
        capabilities=frozenset(
            {
                CommunicationCapability.STATUS,
            }
        )
    )

    assert not communication.supports(
        CommunicationCapability.WARNING
    )


def test_character_attention_is_available() -> None:
    character = make_character()

    assert character.attention.default_state is AttentionState.QUIET
    assert character.attention.attention_description