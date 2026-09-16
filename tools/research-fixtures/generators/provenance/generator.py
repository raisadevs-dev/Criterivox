from datetime import datetime, timezone


def generate(component: str) -> dict:
    return {"origin_component": component, "origin_kind": "synthetic_fixture", "generated_at": datetime.now(timezone.utc).isoformat(), "synthetic": True}
