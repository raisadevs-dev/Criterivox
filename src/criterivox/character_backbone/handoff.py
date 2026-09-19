from .models import HandoffContract
def validate_handoff(handoff:HandoffContract, character_ids:set[str], capability_ids:set[str]):
    if handoff.sender not in character_ids or handoff.receiver not in character_ids:raise ValueError("Handoff sender/receiver must be registered.")
    if handoff.requested_capability not in capability_ids:raise ValueError("Handoff capability is not registered.")
    if not handoff.task_id or not handoff.journey_id:raise ValueError("Handoff task_id and journey_id are required.")
