from criterivox.domain.characters import CharacterState
from criterivox.presentation.adapter import PresentationAdapter


class RecordingAdapter(PresentationAdapter):
    def __init__(self) -> None:
        self.calls: list[tuple[str, CharacterState]] = []

    def present(
        self,
        character_id: str,
        state: CharacterState,
    ) -> None:
        self.calls.append((character_id, state))


def test_presentation_adapter_defines_presentation_boundary() -> None:
    adapter = RecordingAdapter()

    adapter.present(
        "Dharen",
        CharacterState.WORK,
    )

    assert adapter.calls == [
        ("Dharen", CharacterState.WORK),
    ]