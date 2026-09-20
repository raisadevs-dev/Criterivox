from criterivox.character_backbone.language import interpret
from criterivox.character_backbone.unified_runtime import UnifiedCharacterRuntime

def test_language_structures_state_query():
 r=interpret("What is happening?")
 assert r.intent=="QUERY_CURRENT_STATE" and r.requested_output=="status"

def test_language_detects_ambiguity():
 assert interpret("Why and what happens next?").ambiguous

def test_runtime_does_not_fabricate_missing_state():
 r=UnifiedCharacterRuntime().handle("What is happening?",task_id="missing-task")
 assert r.machine["status"]=="NO_AUTHORITATIVE_RECORD"
 assert "No authoritative" in r.human_text

def test_runtime_routes_provenance():
 r=UnifiedCharacterRuntime().handle("Show provenance")
 assert r.machine["capability"]=="trace_provenance"
 assert r.machine["responsible_character"]=="epistre"

def test_runtime_requires_boundary_for_execution():
 r=UnifiedCharacterRuntime().handle("Execute")
 assert r.machine["authorization"]=="REQUIRED"
 assert r.machine["workflow_outcome"]=="no_state_change"

def test_runtime_exposes_unavailable_capability():
 r=UnifiedCharacterRuntime().handle("Execute calendar action")
 assert r.machine["status"]=="CAPABILITY_UNAVAILABLE"

def test_runtime_pause_requires_task_and_changes_state():
 r=UnifiedCharacterRuntime().handle("Pause",task_id="pause-test")
 assert r.machine["status"]=="PAUSED"

def test_registry_has_fifteen_characters():
 from criterivox.character_backbone.loader import load_character_registry
 assert len(load_character_registry().characters)==15
