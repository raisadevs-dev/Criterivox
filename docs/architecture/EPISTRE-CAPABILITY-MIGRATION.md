# Epistre First-Class Capability Migration

Epistre owns explanation and provenance lineage.

## Verified existing foundation
S8 EvidenceResearchBureau.explain(...) already creates an authoritative EXPLANATION artifact from an inspectable artifact. The explanation preserves subject artifact, kind, sources, parents, status, content hash, limitations and provenance availability.

## Implemented here
- Character-owned explanation facade
- Explanation assessment
- Source and parent lineage tracing
- Explanation limitations
- Provenance availability reporting
- Dedicated Python tests
- Dedicated Dart presentation/workspace/tests
- Navigation and chat routing

## Boundaries
Sandre owns data-foundation lineage and transformation records. Veridat owns verification. Epistre explains and traces recorded artifacts; it does not establish truth and does not expose hidden chain-of-thought.

The S8 EvidenceResearchBureau remains the authoritative shared explanation/provenance infrastructure.
