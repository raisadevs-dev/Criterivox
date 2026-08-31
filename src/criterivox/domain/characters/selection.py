from __future__ import annotations

from dataclasses import dataclass

from .character import Character


@dataclass(frozen=True, slots=True)
class CharacterSelection:
    """Result of contextual character selection."""

    character: Character
    score: int


class CharacterSelector:
    """Select characters that are relevant to the current context."""

    def select(
        self,
        characters: tuple[Character, ...],
        *,
        event: str | None = None,
        context: tuple[str, ...] = (),
        limit: int | None = None,
    ) -> tuple[CharacterSelection, ...]:
        """Return relevant characters ordered by contextual relevance."""

        normalized_event = (
            event.strip().lower()
            if event is not None
            else None
        )

        normalized_context = {
            item.strip().lower()
            for item in context
            if item.strip()
        }

        selections: list[CharacterSelection] = []

        for character in characters:
            score = self._score(
                character,
                event=normalized_event,
                context=normalized_context,
            )

            if score > 0:
                selections.append(
                    CharacterSelection(
                        character=character,
                        score=score,
                    )
                )

        selections.sort(
            key=lambda selection: (
                -selection.score,
                selection.character.behavior.activation_priority,
                selection.character.identity.identifier,
            )
        )

        if limit is not None:
            if limit < 1:
                raise ValueError("Selection limit must be positive.")

            selections = selections[:limit]

        return tuple(selections)

    @staticmethod
    def _score(
        character: Character,
        *,
        event: str | None,
        context: set[str],
    ) -> int:
        behavior = character.behavior

        score = 0

        if event is not None and event in {
            item.strip().lower()
            for item in behavior.preferred_events
        }:
            score += 3

        character_triggers = {
            item.strip().lower()
            for item in behavior.contextual_triggers
        }

        score += sum(
            1
            for item in context
            if item in character_triggers
        )

        return score