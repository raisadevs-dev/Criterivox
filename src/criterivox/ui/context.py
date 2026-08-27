"""Context used to determine relevant Bloom capabilities."""

from dataclasses import dataclass


@dataclass(frozen=True)
class UIContext:
    """Current user-interface context."""

    area: str = "home"
    has_dataset: bool = False
    has_content: bool = False

CAPABILITIES = {
    "home": [
        "Analyze",
        "Explore",
        "Explain",
    ],
    "dataset": [
        "Analyze",
        "Compare",
        "Explore",
        "Explain",
    ],
    "content": [
        "Analyze",
        "Compare",
        "Explain",
    ],
}

def get_relevant_capabilities(context: UIContext) -> list[str]:
    """Return capabilities relevant to the current UI context."""

    if context.has_dataset:
        return CAPABILITIES["dataset"]

    if context.has_content:
        return CAPABILITIES["content"]

    return CAPABILITIES.get(
        context.area,
        CAPABILITIES["home"],
    )

