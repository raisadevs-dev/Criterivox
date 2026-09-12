# Criterivox Gate 2 Human Collaboration Runtime v1.0

This document records the finalized implementation contract for the Human Residence Collaboration Room.

## Decisions

1. Guest isolation: **A**. Use the current local ephemeral Guest Pass contract now. A production MicroVM boundary may replace the implementation later without changing the lifecycle contract.
2. Collaboration membership: **C**. Support owner-created members and invitation-ready member identifiers. The current runtime creates designated Resident/Guest membership records.
3. Consensus: **C**. Adaptive risk-aware consensus. Thresholds are runtime policy values: low 55%, moderate 70%, high 80%, critical 90%. These are workflow thresholds, not empirical model-performance claims.
4. Multi-key approval: **Owner + N designated Residents**. N is configurable per collaboration session.
5. Guest permissions: read shared threads, see masked options, leave comments; cannot vote, execute, or alter authoritative context.
6. Team context: raw chat -> Syvax classification -> candidate context variable -> human confirmation -> Dharen Context Diff. Unconfirmed discussion never becomes authoritative context.
7. Outcome learning: Outcome -> Medrus/Viveda analysis -> Learning Proposal -> Human Approval -> validated training dataset/model update proposal. No automatic model mutation.

## A-G runtime

### A. Collaboration session model
`CollaborationSession`, `CollaborationMember`, votes, threads, candidate context, Context Diffs, challenges, signatures, outcomes, and learning proposals are durable local-runtime records under `data/runtime/`.

### B. RBAC + differential visibility
Permissions are enforced at the Python boundary. Owner has full room administration; Resident can collaborate, vote, challenge and sign; Guest can only read/comment. Guest responses are masked server-side.

### C. Context pipeline
Raw team messages are classified by Syvax into a candidate variable. A human with `edit_context` permission must confirm or reject it. Accepted candidates produce an explicit Dharen-style Context Diff event and are the only context updates considered authoritative by this room.

### D. Consensus + Manis friction
Votes are one-per-member and replace a member's previous vote. The leading option is compared with an adaptive risk threshold. Failure to reach threshold emits `manis_friction` and requires disagreement review before action.

### E. Multi-signatory Bodhex gate
Owner signature is mandatory. At least N designated Resident signatures are required. Each signature includes a tamper-evident SHA-256 runtime receipt. Dispatch remains locked until the gate is satisfied and is recorded against the Bodhex execution boundary.

### F. Outcome + attribution
Real-world outcomes are stored with the selected option, consensus state, contributors, timestamp, and analysis chain. The outcome is the durable handoff point for Medrus/Viveda analysis.

### G. Learning governance
Medrus/Viveda analysis produces a proposal describing a labeled training-data append and a model-update target. The proposal is `PENDING_HUMAN_APPROVAL` until an authorized Owner approves it. The runtime never silently mutates a production model.

## Browser/Python boundary

Human Residence remains browser-authoritative in IndexedDB, with Python maintaining the local runtime mirror. Guest claiming now exposes a prepare/commit lifecycle so the browser can persist the residence before the guest session is vaporized.

## Security boundary

This is a local/runtime architecture implementation. It is not a production identity provider, HSM, enclave, Firecracker/gVisor deployment, or cryptographic signature service. Runtime hashes are tamper-evident receipts, not proof of hardware-backed identity.
