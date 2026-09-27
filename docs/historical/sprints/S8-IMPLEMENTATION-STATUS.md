# S8 Implementation Status

## Branch

`s8-xai-evidence-bureau` remains the S8 implementation branch. The current implementation is deliberately standalone and sibling to S7.

## Standalone boundary

S8 is an independent Evidence Research Bureau. Its dedicated launcher is `s8-start-evidence-research-bureau.ps1`, with Flutter entrypoint `presentation/lib/s8_main.dart`. It does not boot or depend on the actual Criterivox application shell.

The Fixtures Lab is independently runnable through `scripts/s8_fixtures_lab.ps1` / `scripts/s8_fixtures_lab.py` and uses synthetic acceptance fixtures. This separation is intentional.

## Implemented gates

- Portable typed artifact/event contracts.
- Evidence-linked verification with explicit insufficient/contradictory/pending states.
- Bi-temporal records, temporal retrieval and invalidation.
- Explicit source → transformation → downstream dependency relationships.
- Dependency-aware downstream impact/re-evaluation.
- Provenance and explanation artifacts.
- SHA-256 payload integrity receipts with explicit coverage metadata and tamper status.
- Local SQLite artifact/event persistence and IndexedDB browser adapter.
- Tenant/context isolation and explicit consequential-operation authorization.
- Human challenge → authorization → revision lineage.
- Contradiction and multidimensional uncertainty artifacts.
- Memory consolidation metadata preservation.
- Local layered NLP boundary and artifact-grounded Debate Arena interpretation.
- S7 adapter boundary without hidden runtime dependency.
- Reproducibility/evaluation records.
- Human-facing XAI evaluation protocol with append-only dimensional responses and no universal explainability score.
- Standalone four-room Flutter presentation surface.
- Tap-to-open, draggable character profile cards.
- Flutter-rendered character costume, bodysuit, neck cloth/stole, glasses, insignia/pendants, wrist tools and active-state evidence/knowledge slates, with no external character image assets.
- Dedicated S8 launcher and deterministic Fixtures Lab.
- Dedicated S8 Python/Flutter validation workflow.

## Definition-of-Done boundary

The standalone S8 implementation gates are represented in code, tests, fixtures, documentation and CI. The actual Criterivox application integration is intentionally **not** a completion requirement for this boundary. No local test result is claimed without execution evidence; GitHub Actions is the authoritative environment-backed validation gate.

## Explicit non-goals

- No mandatory online LLM.
- No character-owned computation.
- No Syvax dependency.
- No Global Intelligence Home.
- No forced contradiction resolution.
- No unsupported universal confidence threshold.
- No hidden chain-of-thought.
- No implicit integration with the main Criterivox application.
