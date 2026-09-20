from criterivox.character_backbone.governance import GovernanceService

def test_human_challenge_is_persisted():
 g=GovernanceService()
 r=g.challenge("J-test","recommendation","REC-1","I disagree with this assumption","ASSUMPTION","The source is stale")
 assert r.workflow_outcome=="challenge_persisted"

def test_decision_requires_human_actor():
 g=GovernanceService()
 r=g.decision("J-test",["A","B"],"A","human-1","because evidence supports A")
 assert r.workflow_outcome=="decision_recorded"
