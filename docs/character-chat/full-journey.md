# Criterivox Set 4: Full Journey Inspection

Set 4 adds a durable, inspectable journey record over the existing Set 1–3 character/runtime boundary. The journey is a reference graph, not a second chat history.

Recorded lifecycle:

problem → context → data → evidence → reasoning → hypothesis → challenge → decision → plan → authorization → action → execution → outcome → verification → knowledge → adaptation → transfer

A stage is reported as NOT_RECORDED when no durable record exists. The inspector does not infer missing stages from prose.

Python runtime and SQLite records are authoritative. Flutter only renders the state it receives. Character animation does not establish computational activity.

Set4Runtime.inspect_journey(journey_id) returns grouped stage records and explicit missing stages.

Current boundary: Set 4 provides durable record types and inspection primitives. Automatic migration of every upstream S5/S6/S7/S8 artifact into every journey remains PARTIAL until adapter-level reconciliation exists.
