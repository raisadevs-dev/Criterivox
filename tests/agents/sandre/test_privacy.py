from criterivox.Sandre.privacy import PrivacyMasker


def test_sensitive_field_detection_and_explicit_masking_preserve_shape():
    rows=[{"name":"Ada","email":"ada@example.test","score":1}]
    masker=PrivacyMasker()
    assert masker.detect_sensitive_fields(rows)==("email",)
    result=masker.mask(rows, fields=("email",))
    assert result.rows[0]["email"]=="[MASKED]"
    assert result.rows[0]["name"]=="Ada"
    assert result.source_preserved is True
