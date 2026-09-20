from criterivox.character_backbone.unified_runtime import UnifiedCharacterRuntime

def test_hindi_runtime_routes_and_localizes():
 r=UnifiedCharacterRuntime().handle("क्यों")
 assert r.language.detected_language=="hi"
 assert r.language.intent=="EXPLAIN"
 assert r.machine["response_language"]=="hi"
 assert "क्षमता" not in r.human_text or "registered" not in r.human_text

def test_marathi_runtime_routes_and_localizes():
 r=UnifiedCharacterRuntime().handle("पुढे काय होईल")
 assert r.language.detected_language=="mr"
 assert r.language.intent=="QUERY_NEXT_STATE"

def test_hindi_pause_is_same_canonical_operation():
 r=UnifiedCharacterRuntime().handle("रोकें",task_id="lang-pause")
 assert r.language.intent=="PAUSE"
 assert r.machine["status"]=="PAUSED"

def test_english_hindi_share_capability_semantics():
 en=UnifiedCharacterRuntime().handle("Show provenance")
 hi=UnifiedCharacterRuntime().handle("स्रोत दिखाओ")
 assert en.language.intent==hi.language.intent=="SHOW_PROVENANCE"
 assert en.machine["capability"]==hi.machine["capability"]=="trace_provenance"
