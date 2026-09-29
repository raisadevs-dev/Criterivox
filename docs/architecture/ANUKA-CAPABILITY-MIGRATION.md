# Anuka First-Class Capability Migration

**Branch:** `character-capability-bundles`

Anuka is the Context Adaptor. Her responsibility begins after a Dharen context frame exists and a change condition requires adaptation.

## Anuka-owned capabilities

- conditional activation gates
- context drift comparison
- adaptive state transitions
- state versioning
- sandbox/counterfactual forks
- checkpoints
- adaptive handoff payloads
- learned adaptation classification

## Boundary with Dharen

Dharen constructs the operational context boundary.

Anuka does not rebuild Dharen's framing, scope, or budget allocator. Anuka receives the resulting frame and determines whether/how the context should adapt when requirements, evidence, hypotheses, constraints, drift, or downstream compatibility change.

## Shared infrastructure

The following remain shared:

- ContextFrame and related domain models
- ContextRuntime
- ContextIntelligenceEngine
- replay/state infrastructure
- DynamicTokenAllocator
- global character identity/visual/residence registries

## Dart ownership

Anuka-specific presentation now lives under `presentation/lib/Anuka/`.

The global character system still owns identity, visual profile, animation and navigation registration. The generic chat page routes Anuka prompts to her presentation contract rather than storing them itself.

## Tests

Focused Anuka tests are under `tests/Anuka/` and `presentation/test/Anuka/`. Existing S6 integration tests remain because they verify the cross-character runtime activation contract.

## Truth boundary

Anuka's learned model remains advisory. Deterministic activation and adaptation behavior remain authoritative.
