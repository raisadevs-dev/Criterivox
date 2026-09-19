def validate_message_chips(data):
    allowed={
        "situation_awareness",
        "explanation",
        "workflow",
        "decision",
        "evidence",
        "knowledge",
        "history",
        "current_state",
        "projection",
        "interruption",
        "progress",
        "operations",
    }; seen=set()
    for chip in data.get("chips",[]):
        if chip["id"] in seen:raise ValueError(f"Duplicate chip id: {chip['id']}")
        seen.add(chip["id"])
        if chip["category"] not in allowed:raise ValueError(f"Unknown chip category: {chip['category']}")
        if not chip.get("intent_id"):raise ValueError(f"Chip {chip['id']} missing intent_id")
