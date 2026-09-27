# Veridat First-Class Capability Migration

Veridat owns verification, grounding and contradiction inspection.

## Verified existing foundation
The repository already provides two authoritative validation layers:
- Set 4 VerificationRecord / record_verification(...)
- S8 EvidenceResearchBureau.verify_claim(...)

S8 verification distinguishes insufficient evidence, explicit contradiction, and grounded-pending-validation. It records provenance and verification artifacts.

## Implemented here
- Character-owned verification facade
- Evidence grounding
- Contradiction inspection
- Verification assessment
- Set 4 persistence facade
- Dedicated Python tests
- Dedicated Dart presentation/workspace/tests
- Navigation and chat routing

## Boundaries
Medrus acquires evidence. Veridat evaluates the recorded evidence for grounding/contradiction and records verification state. Vivren reasons over evidence and alternatives. Viveda consolidates verified knowledge. Veridat does not silently upgrade grounded evidence to universal truth.

The existing S8 bureau and Set 4 store remain shared authoritative infrastructure.
