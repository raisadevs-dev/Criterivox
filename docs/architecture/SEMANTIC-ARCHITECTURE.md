# Criterivox Semantic Architecture

## Rule

Production folders describe enduring responsibility, not the sprint in which code was created.

## Python

- `agents/`: character-owned computational packages.
- `capabilities/`: reusable capability surfaces and feature runtimes.
- `mechanisms/`: reusable computational mechanisms, including reasoning, evidence, and learning.
- `execution/`: execution state, ledgers, and execution-time mechanisms.
- `orchestration/`: cross-component workflow coordination.
- `context/`: shared context machinery.
- `runtime/characters/`: shared character backbone and lifecycle/runtime infrastructure.
- `interaction/`: interaction and language boundaries.
- `human/`: human-side residence and collaboration infrastructure.
- `world/`: Bloom and civilization/world systems.
- `presentation_contracts/`: backend-facing presentation contracts.
- `infrastructure/`: providers and runtime infrastructure.
- `application/`: remaining application adapters whose responsibility has not yet justified a narrower package.

## Dart

- `agents/`: character presentation surfaces.
- `workspaces/`: reusable human-facing workspaces grouped by responsibility.
- `world/`: Bloom, civilization, homes, and navigation.
- `human/`: residence, access, collaboration, and profile surfaces.
- `interaction/`: chat and interaction surfaces.
- `runtime/character/`: shared character rendering/runtime.
- `presentation/`: shared presentation primitives and adapters.
- `app/`: application shell and entrypoint.

## Migration rule

A move is complete only when imports, routes, tests, compatibility exports, and documentation references use the semantic destination. A directory rename without dependency repair is not considered a migration.

## Sprint-name removal

The production Python and Dart source/test trees no longer use `s5`, `s6`, `s7`, or `s8` as architectural directory or filename names. Historical sprint documentation and CI workflow names may retain those identifiers because they describe historical delivery stages rather than runtime ownership.
