# Criterivox Work Materials + Level-2 Audit

Status: IMPLEMENTED / PARTIAL by material type on criterivox-work-materials-layer.

## Material contract
src/criterivox/work_materials/contracts.py defines the canonical WorkMaterial structure. Runtime persistence uses the existing Human Residence SQLite boundary and versioned work_materials records. Challenge/change actions use the existing durable decision-event mechanism.

## Material state
| Material | Source | State |
|---|---|---|
| Situation Brief | situation_understanding | IMPLEMENTED |
| Evidence Package | evidence_data_analysis | IMPLEMENTED |
| Analytical Report | analytical_reporting | IMPLEMENTED |
| Reasoning Map | reasoning_hypothesis | IMPLEMENTED where S7 returns an artifact |
| Strategy Set | strategy_construction | IMPLEMENTED |
| Trade-off Analysis | tradeoff_analysis | IMPLEMENTED |
| Action Plan | planning | IMPLEMENTED |
| Verification & Explanation Package | verification_explanation | IMPLEMENTED when verification produces artifacts |
| Outcome Review | outcome_learning / decision outcome | PARTIAL: existing outcome recording exists, material projection is not yet automatic |
| Reusable Knowledge | validated knowledge boundary | PARTIAL: no automatic promotion is claimed |

## Human operations
- Inspect: IMPLEMENTED through material retrieval/presentation.
- Change: IMPLEMENTED for supported material fields; creates a new version and records a durable event.
- Challenge: IMPLEMENTED through durable material challenge events.
- Trace: PARTIAL. Evidence/provenance references are exposed progressively, but a full clickable service-to-runtime trace is not yet unified.
- Re-run: PARTIAL. Material edits explicitly report NOT_RUN; no fake recomputation is shown.
- Export: IMPLEMENTED at service/API boundary for JSON and HTML. A richer browser download UX remains PARTIAL.
- Reuse: PARTIAL. Structured service results remain available for downstream service composition, but a dedicated material-to-service picker is not yet implemented.
- History: IMPLEMENTED at material version/event boundary.

## Level-2 human door audit
The repository contains 94 documented Level-2 operational entries. They remain as internal responsibility/workspace concepts unless explicitly mapped below.

| Existing Level-2 Door/Chip | Type | Human Material | Action | Status |
|---|---|---|---|---|
| Context Quarter operational home | Human Work Door | Situation Brief | Open | Implemented |
| Data Stewardship Quarter operational home | Human Work Door | Evidence Package / Analytical Report | Open | Implemented |
| Intelligence Quarter operational home | Human Work Door | Reasoning Map | Open | Implemented |
| Decision & Challenge Quarter operational home | Human Work Door | Strategy Set / Trade-off Analysis / Action Plan / Results | Open | Implemented |
| Evidence & Experiment Quarter operational home | Human Work Door | Evidence Package / Verification Package | Open | Implemented |
| Knowledge Quarter operational home | Human Work Door | Reusable Knowledge | Inspect deeper | Partial |
| Gateway internal rooms | Internal Workspace | Interaction/routing work | Inspect deeper | Preserved |
| reasoning.* catalog entries | Internal Workspace | Reasoning Map | Inspect deeper | Preserved |
| challenge.* catalog entries | Internal Workspace | Challenge/Review state | Inspect deeper | Preserved |
| decision.* catalog entries | Internal Workspace | Strategy/Trade-off/Plan internals | Inspect deeper | Preserved |
| evidence.* catalog entries | Internal Workspace | Evidence/Verification internals | Inspect deeper | Preserved |
| knowledge.* catalog entries | Internal Workspace | Knowledge internals | Inspect deeper | Preserved |
| Planned/static/research-prototype entries | Internal Workspace | None by default | Internal only | Preserved |

No architectural civilization room was deleted merely to simplify human navigation.

## Presentation boundary
Level 2 now contains an explicit HUMAN WORK DOORS surface. These are actual callbacks into the Work Materials presentation route, not decorative chips. The existing internal room catalog remains below it.

## Truthfulness
Unavailable material is not fabricated. Material status comes from the ServiceResult. Human edits that cannot trigger supported recomputation are stored as changed versions and explicitly marked recomputation: NOT_RUN.

## Known limitations
- The current Flutter material page requires an authenticated Human Residence session.
- A dedicated material-to-service reuse picker is not yet present.
- Outcome Review and Reusable Knowledge require further integration with validated outcome/knowledge state.
- HTML/JSON export is implemented at the API boundary; browser-native download UX is still basic.
- Full clickable Level-3 service/runtime tracing is not yet unified.