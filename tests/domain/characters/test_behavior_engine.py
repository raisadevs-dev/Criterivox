import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.behavior_engine import (
    BehaviorDecision,
    BehaviorEngine,
)
from criterivox.domain.characters.state import CharacterState
from criterivox.domain.characters.state_manager import (
    CharacterStateManager,
    InvalidStateTransition,
)


def make_engine() -> BehaviorEngine:
    character = get_character("Dharen")
    return BehaviorEngine(character)


def test_behavior_engine_starts_idle() -> None:
    engine = make_engine()

    assert engine.state_manager.current_state is CharacterState.IDLE


def test_receive_moves_idle_to_receive() -> None:
    engine = make_engine()

    decision = engine.receive()

    assert isinstance(decision, BehaviorDecision)
    assert decision.character_id == "Dharen"
    assert decision.current_state is CharacterState.IDLE
    assert decision.next_state is CharacterState.RECEIVE


def test_work_uses_character_specific_behavior() -> None:
    engine = make_engine()

    engine.receive()
    decision = engine.work()

    assert decision.current_state is CharacterState.RECEIVE
    assert decision.next_state is CharacterState.WORK
    assert (
        decision.behavior
        == engine.character.behavior.work_behavior
    )


def test_work_to_communicate() -> None:
    engine = make_engine()

    engine.receive()
    engine.work()

    decision = engine.communicate()

    assert decision.current_state is CharacterState.WORK
    assert decision.next_state is CharacterState.COMMUNICATE
    assert decision.behavior


def test_work_to_handoff() -> None:
    engine = make_engine()

    engine.receive()
    engine.work()

    decision = engine.handoff()

    assert decision.current_state is CharacterState.WORK
    assert decision.next_state is CharacterState.HANDOFF
    assert decision.behavior


def test_work_to_warning_uses_character_warning_behavior() -> None:
    engine = make_engine()

    engine.receive()
    engine.work()

    decision = engine.warning()

    assert decision.current_state is CharacterState.WORK
    assert decision.next_state is CharacterState.WARNING
    assert (
        decision.behavior
        == engine.character.behavior.warning_behavior
    )


def test_communicate_to_complete_uses_completion_behavior() -> None:
    engine = make_engine()

    engine.receive()
    engine.work()
    engine.communicate()

    decision = engine.complete()

    assert decision.current_state is CharacterState.COMMUNICATE
    assert decision.next_state is CharacterState.COMPLETE
    assert (
        decision.behavior
        == engine.character.behavior.completion_behavior
    )


def test_invalid_behavior_transition_is_rejected() -> None:
    engine = make_engine()

    with pytest.raises(InvalidStateTransition):
        engine.work()

    assert engine.state_manager.current_state is CharacterState.IDLE


def test_reset_returns_engine_to_idle() -> None:
    engine = make_engine()

    engine.receive()
    engine.work()

    decision = engine.reset()

    assert decision.next_state is CharacterState.IDLE
    assert engine.state_manager.current_state is CharacterState.IDLE


def test_behavior_engine_preserves_shared_state_manager() -> None:
    character = get_character("Dharen")
    state_manager = CharacterStateManager()

    engine = BehaviorEngine(
        character=character,
        state_manager=state_manager,
    )

    engine.receive()

    assert state_manager.current_state is CharacterState.RECEIVE
    assert engine.state_manager is state_manager


def test_role_specific_behavior_is_taken_from_character_definition() -> None:
    dharen = get_character("Dharen")
    vivren = get_character("Vivren")

    dharen_engine = BehaviorEngine(dharen)
    vivren_engine = BehaviorEngine(vivren)

    dharen_engine.receive()
    vivren_engine.receive()

    dharen_decision = dharen_engine.work()
    vivren_decision = vivren_engine.work()

    assert (
        dharen_decision.behavior
        == dharen.behavior.work_behavior
    )
    assert (
        vivren_decision.behavior
        == vivren.behavior.work_behavior
    )
    assert (
        dharen_decision.behavior
        != vivren_decision.behavior
    )


def test_all_15_characters_can_use_behavior_engine() -> None:
    characters = (
        "Dharen",
        "Vivren",
        "Tarkis",
        "Sandre",
        "Pramon",
        "Syvax",
        "Bodhex",
        "Medrus",
        "Epistre",
        "Manis",
        "Anuka",
        "Veridat",
        "Viveda",
        "Kaelen",
        "Anukor",
    )

    for identifier in characters:
        engine = BehaviorEngine(get_character(identifier))

        receive_decision = engine.receive()
        work_decision = engine.work()

        assert receive_decision.next_state is CharacterState.RECEIVE
        assert work_decision.next_state is CharacterState.WORK
        assert work_decision.behavior