import pytest

from criterivox.domain.characters.attention import CharacterAttention
from criterivox.domain.characters.attention_state import AttentionState


def test_character_attention_can_be_created() -> None:
    attention = CharacterAttention(
        default_state=AttentionState.QUIET,
        attention_description="Remains quiet until relevant to the task.",
    )

    assert attention.default_state is AttentionState.QUIET
    assert (
        attention.attention_description
        == "Remains quiet until relevant to the task."
    )


def test_character_attention_requires_description() -> None:
    with pytest.raises(ValueError, match="Attention description"):
        CharacterAttention(
            default_state=AttentionState.QUIET,
            attention_description="   ",
        )