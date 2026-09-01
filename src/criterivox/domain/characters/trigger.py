from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ContextualTrigger:
    """A condition that can make a character relevant to a context."""

    identifier: str
    description: str

    def __post_init__(self) -> None:
        if not self.identifier.strip():
            raise ValueError("Trigger identifier cannot be empty.")

        if not self.description.strip():
            raise ValueError("Trigger description cannot be empty.")