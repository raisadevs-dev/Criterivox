# Criterivox Unified Character-Chat Runtime Refactor — Research Record

## Scope
This record covers the implementation on `criterivox-refactor`. It distinguishes implemented behavior from research hypotheses.

## Concrete contributions
| Contribution | Mechanism | Implementation | Test evidence | Limitation |
|---|---|---|---|---|
| Capability-grounded character routing | deterministic language → capability registry | `character_backbone/language.py`, `capability_discovery.py` | unified runtime tests | not every capability is executable |
| Unified past/present/next reporting | authoritative checkpoint/event state | existing `state_runtime.py` + unified runtime | state-awareness tests + new tests | no state means explicit boundary |
| Interruption-tolerant state | persisted checkpoints + runtime pause/resume | existing S6/S9 runtime | existing interruption paths + new pause test | only supported long-running workflows can pause |
| Human challenge persistence | Set4 challenge records | `governance.py` | governance tests | downstream re-evaluation still depends on implemented capability |
| Recommendation/decision/execution separation | decision/action contracts and authorization states | S9/Set4 + unified runtime | boundary tests | external adapters remain limited |
| Structured provenance boundary | S8 artifacts/events + registry contracts | existing S8/Set4 | provenance routing tests | provenance completeness depends on upstream artifacts |

## Potential research contributions
These are POTENTIAL, not proven:
- Does persistent state improve interruption recovery?
- Does structured situation awareness improve human understanding?
- Does capability grounding reduce unsupported action claims?
- Does provenance-centered explanation improve decision traceability?
- Does persisted human challenge improve error detection?
- Does structured A2A handoff reduce context loss?
- Does separating outcomes from reusable knowledge improve knowledge reliability?

Required evidence: controlled baselines, held-out scenarios, human studies where appropriate, predefined metrics.

## Research questions
See `docs/research/UNIFIED_RUNTIME_RESEARCH_PLAN.md`.

## Benchmark plan
Baselines: conversational-only character chat; registry-grounded deterministic router; unified runtime.
Metrics: intent accuracy, routing accuracy, unsupported-claim rate, state-report accuracy, interruption recovery, handoff completeness, provenance completeness, authorization violation rate, decision-trace completeness, contradiction handling, outcome capture.
No benchmark numbers are claimed by this record.

## Architecture claimed vs implementation
| Capability | Architecture | Implemented | Tested | Evidence |
|---|---|---|---|---|
| Structured language layer | Yes | Yes | Yes | unit tests |
| 15-character registry | Yes | Yes | Yes | registry test |
| Capability discovery | Yes | Yes | Yes | routing tests |
| Past/present/next state | Yes | Yes | Yes | state runtime/tests |
| Pause/resume | Yes | Yes | Partial | runtime supports it; broad long-running coverage remains |
| Execution lineage | Yes | Yes | Partial | S8/S9 records; end-to-end coverage incomplete |
| Human challenge | Yes | Yes | Partial | persisted Set4 record; downstream re-evaluation incomplete |
| Decision governance | Yes | Yes | Partial | decision records exist; full authorization/action journey incomplete |
| External execution | Yes | Partial | Partial | bounded local filesystem adapter only |
| Calendar execution | Yes | No | No | CAPABILITY_UNAVAILABLE |
| Knowledge consolidation | Yes | Partial | Partial | record contract exists; validation/evaluation pipeline incomplete |
| Anukor transfer | Yes | Partial | Partial | transfer record exists; applicability/retest engine incomplete |

## Negative results / limitations
- Natural language remains deterministic and model-independent; no new LLM was introduced.
- Character chat still contains legacy response paths for some profiles and therefore is not yet a universal capability execution surface.
- External provider adapters are not fabricated.
- A2A structured contracts exist, but not every character collaboration is wired through a single transport.
- The presentation layer can expose the runtime boundary, but backend state remains authoritative.

## Reproducibility
Install repository requirements, run `pytest -q tests/test_unified_character_runtime.py tests/test_state_awareness_set2.py`, then run the repository's existing validation suites. No external model provider is required for the deterministic runtime tests.

## Future experiments
Measure interruption recovery after controlled pause points, unsupported-claim rate under ambiguous prompts, handoff context retention, provenance completeness, human challenge effectiveness, and knowledge reuse validity.
