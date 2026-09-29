from criterivox.application.global_chat import home_for_character, interpret_global_chat


def test_global_chat_detects_character_report_request():
    intent = interpret_global_chat("show me Vivren's report")
    assert intent.intent == "report"
    assert intent.character_id == "vivren"
    assert intent.confidence >= 0.9


def test_global_chat_keeps_language_detection_silent():
    intent = interpret_global_chat("Mujhe Tarkis ka report chahiye")
    assert intent.intent == "report"
    assert intent.character_id == "tarkis"
    assert intent.language_profile.primary_language in {"hinglish", "hi-Latn", "en"}


def test_global_chat_routes_status_without_forcing_confirmation():
    intent = interpret_global_chat("what is happening with Dharen?")
    assert intent.intent in {"current", "status"}
    assert intent.character_id == "dharen"


def test_character_home_mapping_is_backend_owned():
    assert home_for_character("vivren") == "reasoning"
    assert home_for_character("sandre") == "data"
    assert home_for_character("epistre") == "evidence"
