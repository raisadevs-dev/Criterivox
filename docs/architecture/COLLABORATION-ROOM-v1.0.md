# Criterivox Gate 2 Collaboration Room v1.0

The Collaboration Room is the multi-human + multi-agent war room for shared decision making. It complements the Private Room rather than replacing it.

## Human roles

- **House Owner**: full workspace administration, privacy controls, and multi-key authorization.
- **Resident**: scoped collaborative decision-making, goal/data input, voting and challenges.
- **Guest**: read-only masked access to explicitly shared decision threads.

## Runtime boundaries

1. **RBAC / Differential Data Shield**: visibility is represented as `PUBLIC_TO_ROOM`, `RESIDENT_ONLY`, or `OWNER_CONFIDENTIAL`.
2. **Syvax → Dharen context filtering**: team discussion is not automatically committed to working memory. A message must be classified into the room context stream first.
3. **Consensus**: votes are attributable room state. The current UI uses the supplied 70% threshold as a workflow trigger, not as an empirical model-quality claim.
4. **Manis friction alignment**: sub-70% consensus exposes targeted challenge prompts before dispatch.
5. **Multi-key dispatch**: Owner + Resident signatures are required by default. Unlocking the UI does not itself execute a Bodhex action. A production execution adapter must enforce the same gate server-side.
6. **Outcome attribution**: team outcomes retain selected option, consensus, real-world result and contributor names for downstream Medrus/Viveda learning.

## Persistence boundary

The room state is persisted through the existing `HumanResidenceStore`: browser-local IndexedDB is the local authority and the Python Human Residence API is the local runtime mirror. No password, authentication secret, or production identity credential is stored by this feature.

## Current implementation status

Implemented in `presentation/lib/collaboration_room_page.dart` and wired into the Gate 2 shell. The page provides the collaboration controls, but production-grade server-side authorization, cryptographic signatures, and real Bodhex execution remain separate security/runtime boundaries and are not falsely represented as complete by the UI.
