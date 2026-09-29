from criterivox.agents.bodhex import BodhexActionPreparer

def test_bodhex_action_preparation_keeps_authorization_boundary():
    result=BodhexActionPreparer().prepare("prepare an action",conversation_id="test")
    assert result["classification"]=="AUTH_REQUIRED"
    assert result["approval"]["state"]=="APPROVAL_REQUESTED"
