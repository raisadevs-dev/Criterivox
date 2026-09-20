def validate_message_chips(data):
    allowed = {
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
    }

    seen = set()

    for chip in data.get("chips", []):
        chip_id = chip["id"]

        if chip_id in seen:
            raise ValueError(
                f"Duplicate chip id: {chip_id}"
            )

        seen.add(chip_id)

        category = chip["category"]

        if category not in allowed:
            raise ValueError(
                f"Unknown chip category: {category}"
            )

        if not chip.get("intent_id"):
            raise ValueError(
                f"Chip {chip_id} missing intent_id"
            )