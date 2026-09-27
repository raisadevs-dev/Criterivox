# Manis First-Class Capability Migration

Manis owns structured human challenge and oversight.

## Verified existing foundation
The collaboration runtime already implements the authoritative challenge write path:
- CollaborationEngine.challenge(...)
- challenge permission enforcement
- persisted collaboration session challenges
- Manis agent attribution
- challenge events used by the human-residence decision flow

Set 4 also defines ChallengeRecord and record_challenge(...) with owner `manis`.

## Boundary
Pramon structures alternatives. Manis challenges assumptions, evidence, reasoning, trade-offs and scope from the human side. Manis does not select a strategy and does not execute it.

The shared CollaborationEngine remains shared human-collaboration infrastructure. Manis owns the challenge facade and presentation surface.

## Presentation
The dedicated Manis workspace embeds the existing PrivateRoomPage because that page already contains the authoritative human challenge bench and challenge persistence flow. This avoids creating a fake second challenge system.
