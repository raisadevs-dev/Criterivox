from criterivox.ui.bloom import BloomInteraction, BloomState


def test_bloom_opens():
    bloom = BloomInteraction()

    bloom.open()

    assert bloom.state == BloomState.OPEN


def test_bloom_primary_selection():
    bloom = BloomInteraction()

    bloom.open()
    bloom.select_primary("Analyze")

    assert bloom.state == BloomState.PRIMARY_SELECTED
    assert bloom.selected_capability == "Analyze"


def test_bloom_context_expansion():
    bloom = BloomInteraction()

    bloom.open()
    bloom.select_primary("Analyze")
    bloom.expand_context()

    assert bloom.state == BloomState.CONTEXT_EXPANDED


def test_invalid_context_expansion():
    bloom = BloomInteraction()

    bloom.open()
    bloom.expand_context()

    assert bloom.state == BloomState.ERROR


def test_bloom_close_resets_state():
    bloom = BloomInteraction()

    bloom.open()
    bloom.select_primary("Analyze")
    bloom.close()

    assert bloom.state == BloomState.CLOSED
    assert bloom.selected_capability is None