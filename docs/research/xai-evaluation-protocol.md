# Criterivox S8 XAI Evaluation Protocol

## Purpose
Evaluate whether S8 explanations are understandable and inspectable without treating a universal confidence score or threshold as truth.

## Evaluation dimensions

Each participant/task record may capture:

1. **Understanding**: can the human restate what happened and the stated limitations?
2. **Traceability**: can the human trace a result to supporting evidence and provenance?
3. **Problem detection**: can the human locate a weak, missing, contradictory, invalidated, or tampered artifact?
4. **Challenge quality**: can the human target the relevant artifact, relationship, path, or supporting material?
5. **Correction traceability**: can the human provide evidence/context or an alternative and inspect the resulting revision lineage?
6. **Uncertainty comprehension**: can the human identify why the state is uncertain and what information could resolve it?
7. **Authorization awareness**: can the human distinguish inspection from consequential intervention?

## Task families

- grounded evidence with provenance
- insufficient evidence
- competing/contradictory evidence
- temporal validity and invalidation
- integrity/tamper indication
- human challenge and authorized revision
- cross-context access denial

## Recorded research artifacts

For every study run, retain the task stimulus, participant/task identifier, relevant S8 artifact IDs, explanation/provenance IDs, intervention IDs where applicable, observed response, limitations, execution receipt, and evaluation notes.

Synthetic Fixtures Lab material is test stimulus only and must remain marked synthetic. It is not research evidence.

## Interpretation

Results are reported descriptively by task and dimension. The protocol does not define an unsupported universal pass threshold. Thresholds, sampling plans, participant counts, and statistical parameters remain study-specific research decisions and must be documented with the experiment record.
