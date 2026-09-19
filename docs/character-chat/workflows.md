# Set 3 Governed Workflows

## Prepare
A MOVE request creates a durable command record, resolves artifact.move, identifies Bodhex as the capability owner, and requests explicit human authorization. Preparation does not imply execution.

## Approve
Approval creates an authorization record and event. The action contract is then validated. Missing inputs or an unavailable adapter block execution.

## Execute and verify
A real adapter produces an execution result. Verification separately inspects the target state. Only verified target state becomes VERIFIED.

## Change
A human change request records CHANGE_REQUESTED and marks the operation REEVALUATION_REQUIRED; an old plan is never silently reused.
