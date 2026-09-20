# Unified Runtime Research Plan

## Hypotheses
1. Persistent checkpoints reduce state loss after interruption compared with transcript-only reconstruction.
2. Structured situation-awareness reduces unsupported current/next claims.
3. Capability-grounded routing reduces unsupported action claims.
4. Provenance-centered explanation improves traceability.
5. Persisted human challenges improve detection/correction of incorrect assumptions.
6. Structured handoff contracts reduce context loss.
7. Separating observed/verified/reusable knowledge reduces propagation of unverified claims.

## Experimental design
Use held-out JSONL scenarios. Compare a transcript-only baseline against registry-grounded routing and the unified runtime. Record task population, prompt distribution, missing-state cases, ambiguity, authorization boundaries, and execution availability.

## Metrics
State-report accuracy; intent accuracy; routing accuracy; interruption recovery; unsupported-claim rate; handoff completeness; provenance completeness; authorization violation rate; decision trace completeness; contradiction handling accuracy; outcome capture completeness.

## Success criteria
Pre-register thresholds per experiment. Do not infer improvement from architecture alone.

## Reproducibility
Keep training/scenario and held-out testing data versioned. Record commit SHA, environment, test command, dataset version and failures.
