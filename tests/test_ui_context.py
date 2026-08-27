from criterivox.ui.context import (
    UIContext,
    get_relevant_capabilities,
)


def test_home_context():
    context = UIContext(area="home")

    capabilities = get_relevant_capabilities(context)

    assert capabilities == [
        "Analyze",
        "Explore",
        "Explain",
    ]


def test_dataset_context():
    context = UIContext(
        area="dataset",
        has_dataset=True,
    )

    capabilities = get_relevant_capabilities(context)

    assert "Compare" in capabilities


def test_content_context():
    context = UIContext(
        area="content",
        has_content=True,
    )

    capabilities = get_relevant_capabilities(context)

    assert "Analyze" in capabilities
    assert "Explain" in capabilities