# Criterivox Test Dataset & Fixture Laboratory

A reusable synthetic-data laboratory for Criterivox integration, acceptance, regression, and research experiments.

## Architectural boundary

Production S7 does **not** ingest arbitrary datasets as its normal interface. S7 consumes internal structured requests/context emitted by Criterivox components such as Dharen, Anuka, Syvax, Tarkis, and future components.

This laboratory exists to simulate those upstream outputs:

```text
Fixture Laboratory
      ↓
synthetic upstream request/context
      ↓
S7 Reasoning Research Bureau
      ↓
artifacts / events / branches / evaluations
```

Generated data is test stimulus, not production intelligence and not a source of fabricated research evidence.

## Generator

```bash
python tools/research-fixtures/generate.py
```

For automation:

```bash
python tools/research-fixtures/generate.py --non-interactive --scenario reasoning --component Dharen --count 5 --formats json,csv,xlsx
```

Supported scenarios:

- `reasoning`
- `hypothesis`
- `contradiction`
- `insufficient_context`
- `intervention`

The generator writes JSON, CSV and XLSX representations plus a manifest under `tools/research-fixtures/generated/`.

## Design rules

1. Fixtures must be deterministic enough for regression when a seed is supplied.
2. Every fixture identifies its simulated upstream component.
3. Context and provenance are explicit.
4. Contradictions and insufficient information are intentional test conditions.
5. Human intervention can be represented as input stimulus.
6. The generator never claims that synthetic observations are real-world evidence.
7. An eventual OpenAI-assisted generator may help create synthetic material, but OpenAI must remain outside the S7 reasoning engine and the fixture manifest must record generated material as synthetic.
8. The laboratory is reusable by future Criterivox components, not S7-only infrastructure.

## Future extensions

Add domain-specific generators for provenance, branch continuation, comparison matrices, tabular observations, cross-component handoffs, recovery/restart, schema drift, and negative/failure cases. Keep each generator upstream-facing and synthetic.
