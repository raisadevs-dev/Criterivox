# S8 Closure Status

## Independence boundary

S8 is implemented as an independently runnable Evidence Research Bureau. Its dedicated entrypoint is `presentation/lib/s8_main.dart`, launched by `s8-start-evidence-research-bureau.ps1`.

The launcher does **not** start `CriterivoxShell`. The S8 Fixtures Lab is similarly independent and uses synthetic/local fixtures only. This separation is intentional and remains in force until a future sprint defines an explicit integration contract.

## Implemented completion gates

- Four-room presentation boundary and standalone Flutter entrypoint.
- Artifact-first evidence/provenance/verification/explanation model.
- SQLite local authoritative persistence and IndexedDB presentation adapter.
- Tenant/context isolation and explicit consequential-operation authorization.
- Temporal retrieval and invalidation representation.
- Contradiction and uncertainty as explicit unresolved/unknown states.
- Human challenge → authorization → revision lineage.
- Integrity receipts and tamper status.
- Memory consolidation preserving epistemic metadata.
- Local layered NLP boundary and artifact-grounded Debate Arena interpretation.
- S7 adapter boundary without a hidden runtime dependency.
- Reproducibility/evaluation records.
- Deterministic S8 Fixtures Lab and PowerShell launcher.
- Dedicated S8 validation workflow for Python and Flutter.

## Validation status

The first repository CI run against commit `ab0a1d921a96814231ae4c484d51d8f521705bd9` did **not** pass. The Python job stopped during dependency installation because the workflow selected Python 3.11 while the repository declares `requires-python = ">=3.13,<3.14"`. The Flutter job reached analysis but failed before tests because the existing presentation tree uses APIs newer than the pinned Flutter 3.24.5 SDK, including `Color.withValues` and `Color.toARGB32`; S8 also had one nullable IndexedDB factory call in `s8_artifact_store.dart`.

The validation workflow has now been corrected to Python 3.13 and Flutter 3.29.3, and the IndexedDB adapter now explicitly handles an unavailable factory. These changes are committed after the failed run. A new CI run is therefore required before declaring S8 validation green. No passing result is claimed here until GitHub Actions reports one.

## Remaining truth-status gates

- Complete and validate the full epistemic lifecycle, including richer transformation relationships and dependency-aware downstream re-evaluation.
- Exercise adversarial memory/write protection and cross-tenant/context isolation through acceptance fixtures.
- Complete the structured human correction loop with explicit authorization and inspectable original/revised lineage.
- Expand the Fixtures Lab beyond smoke scenarios into member-language, temporal, contradiction, missing-context, tamper, authorization-denial and revised-state assertions.
- Validate the concrete S7↔S8 artifact-exchange contract against the actual S7 boundary without creating a runtime dependency.
- Implement the human-understanding/XAI research evaluation protocol, not merely the recording primitive.
- Validate selective cryptographic integrity coverage beyond the baseline artifact hash where research requirements justify it.
- Run the corrected CI and repair any remaining implementation failures.

## Intentionally not integrated

The actual Criterivox application shell is not part of the S8 standalone runtime. Integration remains a future contract-driven operation, not an implicit dependency.
