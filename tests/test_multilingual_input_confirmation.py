from criterivox.application.conversation import ConversationInterpretation
from criterivox.application.language_intake import detect_language_profile


def test_hinglish_is_first_class_code_mixed_input():
    profile = detect_language_profile(
        "Mere hisaab se option B sensible hai, but please check the evidence."
    )

    assert profile.primary_language == "hinglish"
    assert profile.code_mixed is True
    assert profile.transliterated is True
    assert "Latin" in profile.scripts


def test_devanagari_hindi_preserves_script_profile():
    profile = detect_language_profile("यह विकल्प ठीक है, लेकिन प्रमाण जाँचो।")

    assert profile.primary_language == "hi"
    assert "Devanagari" in profile.scripts
    assert profile.transliterated is False


def test_interpretation_always_carries_language_and_semantic_summary():
    interpretation = ConversationInterpretation(
        "analyze",
        "Analyze the supplied task.",
        0.9,
        route_target="dharen",
    )

    assert interpretation.language_profile is not None
    assert interpretation.semantic_summary
    assert "Dharen" in interpretation.semantic_summary
