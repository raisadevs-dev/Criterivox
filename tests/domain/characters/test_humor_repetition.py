from criterivox.domain.characters.humor_repetition import (
    HumorRecord,
    HumorRepetitionController,
)


def make_record() -> HumorRecord:
    return HumorRecord(
        character_id="Dharen",
        situation="waiting",
        characteristics="Dry, restrained humor about messy structure.",
    )


def test_first_humor_record_is_allowed() -> None:
    controller = HumorRepetitionController()

    assert controller.allow(make_record())


def test_same_record_is_blocked_after_recording() -> None:
    controller = HumorRepetitionController()
    record = make_record()

    controller.record(record)

    assert not controller.allow(record)


def test_different_character_is_allowed() -> None:
    controller = HumorRepetitionController()
    record = make_record()

    controller.record(record)

    different = HumorRecord(
        character_id="Vivren",
        situation="waiting",
        characteristics="Skeptical, understated, intellectually teasing.",
    )

    assert controller.allow(different)


def test_different_situation_is_allowed() -> None:
    controller = HumorRepetitionController()
    record = make_record()

    controller.record(record)

    different = HumorRecord(
        character_id="Dharen",
        situation="completion",
        characteristics=record.characteristics,
    )

    assert controller.allow(different)


def test_record_is_preserved() -> None:
    controller = HumorRepetitionController()
    record = make_record()

    controller.record(record)

    assert controller.last_record == record


def test_reset_clears_repetition_history() -> None:
    controller = HumorRepetitionController()
    record = make_record()

    controller.record(record)
    controller.reset()

    assert controller.last_record is None
    assert controller.allow(record)


def test_invalid_record_is_rejected_by_allow() -> None:
    controller = HumorRepetitionController()

    try:
        controller.allow("invalid")  # type: ignore[arg-type]
    except TypeError as error:
        assert str(error) == "Record must be a HumorRecord."


def test_invalid_record_is_rejected_by_record() -> None:
    controller = HumorRepetitionController()

    try:
        controller.record("invalid")  # type: ignore[arg-type]
    except TypeError as error:
        assert str(error) == "Record must be a HumorRecord."