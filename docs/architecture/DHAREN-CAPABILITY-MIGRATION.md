# Dharen First-Class Capability Migration

**Branch:** `character-capability-bundles`

Dharen is the context-architecture worker. This migration separates Dharen-owned computation and character-specific presentation from shared context infrastructure.

## Dharen-owned computation

- deterministic context framing
- scope and priority ordering
- context token-budget allocation
- context clash detection
- context poisoning detection
- bounded context frame construction

Dharen's learned ranking remains in `Dharen/ml.py` and extends the deterministic agent rather than replacing its safety boundary.

## Shared and intentionally retained

The following remain shared because they support the broader context system or Anuka:

- context models
- token allocator
- ContextIntelligenceEngine
- ContextRuntime
- AnukaAgent
- replay/state/fork infrastructure
- global character identity/visual/residence registries

This avoids turning every shared runtime primitive into a fake character-owned implementation.

## Dart ownership

Dharen-specific presentation now lives under:

`presentation/lib/Dharen/`

with:

- context capability presentation
- Dharen workspace
- Dharen-specific chat prompts

Global character registries remain centralized.

## Tests

Dharen-specific presentation coverage is under:

`presentation/test/Dharen/`

Existing deterministic context tests remain under the shared context test area because they validate the shared context boundary contract as well as Dharen behavior.

## Boundary

Dharen owns context construction and boundary control. Anuka owns adaptive context change. They are not collapsed into one capability bundle.
