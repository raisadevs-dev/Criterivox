from criterivox.character_backbone.language import interpret

def test_hindi_current_state():
 r=interpret("अभी क्या हो रहा है")
 assert r.detected_language=="hi"
 assert r.response_language=="hi"
 assert r.intent=="QUERY_CURRENT_STATE"

def test_marathi_next_state():
 r=interpret("पुढे काय होईल")
 assert r.detected_language=="mr"
 assert r.intent=="QUERY_NEXT_STATE"

def test_devanagari_explain():
 r=interpret("का समजावून सांगा")
 assert r.detected_language=="mr"
 assert r.intent=="EXPLAIN"

def test_english_remains_canonical():
 r=interpret("What happens next?")
 assert r.detected_language=="en"
 assert r.intent=="QUERY_NEXT_STATE"

def test_code_switching_keeps_canonical_intent():
 r=interpret("आत्ता current status काय आहे")
 assert r.intent=="QUERY_CURRENT_STATE"
 assert r.detected_language in {"hi","mr"}

def test_language_does_not_create_separate_runtime_semantics():
 en=interpret("What is happening?")
 hi=interpret("अभी क्या हो रहा है")
 assert en.intent==hi.intent=="QUERY_CURRENT_STATE"
