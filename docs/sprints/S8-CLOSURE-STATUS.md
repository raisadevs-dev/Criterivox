# S8 Closure Status

## Independence boundary

S8 is implemented as an independently runnable Evidence Research Bureau. Its dedicated entrypoint is `presentation/lib/s8_main.dart`, launched by `s8-start-evidence-research-bureau.ps1`.

The launcher does **not** start `CriterivoxShell`. The S8 Fixtures Lab is similarly independent and uses synthetic/local fixtures only. This separation remains intentional until a future sprint defines an explicit integration contract.

## Closed standalone completion gates

- Four-room presentation boundary and standalone Flutter entrypoint.
- Artifact-first evidence/provenance/verification/explanation model.
- SQLite local authoritative persistence and IndexedDB presentation adapter.
- Tenant/context isolation and explicit consequential-operation authorization.
- Temporal retrieval and invalidation representation.
- Explicit source → transformation → downstream dependency relationships and dependency-aware re-evaluation.
- Contradiction and uncertainty as explicit unresolved/unknown states.
- Human challenge → authorization → revision lineage.
- Integrity receipts, tamper status and coverage metadata.
- Memory consolidation preserving epistemic metadata.
- Local layered NLP boundary and artifact-grounded Debate Arena interpretation.
- Contract-only S7 ↔ S8 artifact exchange without S7 runtime imports.
- Reproducibility/evaluation records.
- Human-facing XAI evaluation protocol for understandability, traceability, uncertainty comprehension, evidence linkage, intervention clarity and limitation awareness, without a universal explainability score.
- Deterministic Fixtures Lab with member/upstream identity, missing evidence, contradiction, uncertainty, temporal, tamper, human authorization and cross-context isolation scenarios.
- Dedicated S8 PowerShell launcher and Fixtures Lab launcher.
- Dedicated S8 Python/Flutter validation workflow.
- Tap-to-open, draggable character profile cards.
- Flutter-only character presentation details for Medrus, Epistre and Veridat, including layered wardrobe, fitted inner suit/bodysuit, neck cloth/stole, glasses, insignia/pendants, wrist tools and active-state evidence/knowledge slates. No external character image assets are required.

## Validation truth status

The repository contains the corrected S8 validation workflow and the implementation/tests required by the standalone definition of done. The current branch must still receive a fresh GitHub Actions run after the latest commits before the sprint is described as **CI-green**. No passing CI result is claimed until that run reports success.

## Remaining work outside S8 standalone closure

1. Actual production S7 ↔ S8 handoff after both bureau contracts are explicitly finalized.
2. Production live-data adapter.
3. Empirical human-understanding study with collected participant data.
4. Advanced graph-rendering/performance work where later research justifies it.

These are not missing baseline S8 implementation gates and are deliberately deferred rather than silently folded into the standalone bureau.

## Intentionally not integrated

The actual Criterivox application shell is not part of the S8 standalone runtime. Integration remains a future contract-driven operation, not an implicit dependency.
