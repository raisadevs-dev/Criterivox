# Anukor First-Class Capability Migration

Anukor owns cross-home transfer assessment and transfer-state recording.

## Verified existing foundation
Set 4 already defines:
- TransferRecord
- Set4Store persistence
- record_transfer(...), explicitly owned by anukor
- character reporting that distinguishes transfer records from message delivery

Anuka remains the owner of AdaptationRecord and context adaptation. Anukor references adaptation requirements; it does not own Anuka's adaptation engine.

## Implemented here
- Transfer compatibility assessment
- Explicit adaptation-required state
- Explicit rejection for incompatible transfers
- Transfer record facade over Set 4
- Dedicated Python tests
- Dedicated Dart presentation/workspace/tests
- Navigation and chat routing

## Truth boundary
A message crossing a UI boundary is not transfer success. A transfer is only represented as recorded when the authoritative transfer record exists. This package does not invent a production delivery adapter where none exists.
