from criterivox.Anuka.ml import AnukaMLAgent


def test_anuka_ml_agent_is_ready():
    agent = AnukaMLAgent()
    assert agent.is_ready is True
