# S8 Ledger Traceability

The supplied S8 implementation specification names three authoritative ledgers:

1. Architecture Decision Ledger
2. UI/UX + Functional Specification Ledger
3. Technology Stack / Internal Implementation Decision Ledger

The project research material confirms that these are intentionally separate and that they cover architecture/boundaries/artifacts, four-room UX/functionality, and Flutter/Python/persistence/provenance/verification/security/testing respectively.

## Implementation rule

Until the full ledger text is available to the implementation environment, this document treats only decisions directly supported by the supplied S8 material as locked implementation constraints. Unsupported details are left as validation gates rather than silently invented.

## Verified S8 constraints used by implementation

- S8 is a sibling XAI/Evidence Research Bureau.
- Four rooms: Medrus, Epistre, Veridat, Presentation + Human Intervention.
- Characters represent genuine system activity and are not computational engines.
- Authoritative artifacts/events/state bridge computation and presentation.
- Evidence, verification, provenance, temporal knowledge, contradiction, uncertainty and integrity are first-class concerns.
- Human inspection/intervention is first-class.
- S7 integration must use explicit contracts/adapters.
- Syvax and the future Global Intelligence Home are not S8 computational dependencies.
- Unsupported thresholds/scores are not promoted into architecture.

## Validation still required against the actual ledger documents

- exact persistence/storage split and migration rules
- exact local NLP/LLM boundary
- exact authorization and tenant model
- exact memory/write-protection semantics
- exact cryptographic receipt/chain semantics
- exact contradiction reconciliation behavior
- exact UI navigation/information-density rules
- exact Debate Arena and human-intervention contract
- exact S7 adapter contract
