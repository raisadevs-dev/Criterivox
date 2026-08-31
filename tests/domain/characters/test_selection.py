from criterivox.domain.characters import (
    CharacterSelector,
    get_all_characters,
)


def test_selector_selects_character_for_preferred_event() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        event="analysis_requested",
    )

    identifiers = {
        selection.character.identity.identifier
        for selection in selections
    }

    assert "Dharen" in identifiers
    assert "Vivren" in identifiers
    assert "Tarkis" in identifiers


def test_selector_scores_preferred_event_higher_than_context_trigger() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        event="analysis_requested",
        context=("context establishment",),
    )

    dharen = next(
        selection
        for selection in selections
        if selection.character.identity.identifier == "Dharen"
    )

    assert dharen.score == 4


def test_selector_selects_character_from_context() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        context=("hypothesis formation",),
    )

    identifiers = {
        selection.character.identity.identifier
        for selection in selections
    }

    assert identifiers == {"Tarkis"}


def test_selector_suppresses_irrelevant_characters() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        context=("hypothesis formation",),
    )

    identifiers = {
        selection.character.identity.identifier
        for selection in selections
    }

    assert "Dharen" not in identifiers
    assert "Syvax" not in identifiers
    assert "Medrus" not in identifiers


def test_selector_returns_empty_when_nothing_is_relevant() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        event="completely_unknown_event",
        context=("completely_unknown_context",),
    )

    assert selections == ()


def test_selector_can_limit_results() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        event="analysis_requested",
        limit=2,
    )

    assert len(selections) == 2


def test_selector_rejects_non_positive_limit() -> None:
    selector = CharacterSelector()

    try:
        selector.select(
            get_all_characters(),
            event="analysis_requested",
            limit=0,
        )
    except ValueError as exc:
        assert str(exc) == "Selection limit must be positive."
    else:
        raise AssertionError("Expected ValueError")


def test_selector_orders_by_score() -> None:
    selector = CharacterSelector()

    selections = selector.select(
        get_all_characters(),
        event="analysis_requested",
        context=("context establishment",),
    )

    scores = [selection.score for selection in selections]

    assert scores == sorted(scores, reverse=True)