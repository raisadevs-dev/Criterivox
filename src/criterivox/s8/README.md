# S8 — XAI / Evidence Research Bureau

Portable sibling research bureau for evidence, verification, provenance, temporal knowledge and human-readable explanation.

## Boundary

```text
S8 computational mechanisms
        ↓
authoritative artifacts / events / state
        ↓
Medrus / Epistre / Veridat presentation
        ↓
human inspection / questioning / challenge / intervention
```

The characters are presentation actors, not computational engines. S8 has no dependency on Syvax or the future Global Intelligence Home.

## Current portable core

`EvidenceResearchBureau` provides an explicit artifact/event model, evidence-linked verification, contradiction-aware status, bi-temporal fact records, provenance artifacts, and inspectable explanation artifacts. Missing evidence is represented as `insufficient_evidence`; contradictions remain explicit.

The implementation is intentionally deterministic and dependency-light until the technology ledger requires a particular external or local mechanism. No unsupported permanent threshold or score is introduced.

## Intended room mapping

- **Medrus Room:** knowledge retention, temporal/historical evidence and memory-oriented inspection.
- **Epistre Room:** explanation, provenance and audit narrative.
- **Veridat Room:** grounding, verification, contradiction and truth-boundary inspection.
- **Presentation + Human Intervention Room:** overview, artifact inspection, provenance, verification, contradiction, uncertainty/limitations, questions, challenges and interventions.

## Integration

S7 remains a sibling bureau. Cross-bureau communication must use explicit artifacts/events/contracts and adapters rather than character dependencies.
