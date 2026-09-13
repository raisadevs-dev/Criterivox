# S6 — CONTEXT INTELLIGENCE BACKLOG

**Branch:** `s6-home03-syvax-bloom-complete`  
**Status:** IN PROGRESS — implementation/handoff foundation exists; verification and quality gates remain.  
**Rule:** Do not mark S6 complete merely because code or documentation exists. Passing tests, CI evidence, generated ML artifacts, runtime inference, and end-to-end recovery evidence are separate acceptance claims.

## 1. Sprint 6 Final Direction

S6 extends the S5 Data Foundation into an operational Context Intelligence layer. S5 remains authoritative. S6 owns contextual framing, prioritisation, compression, adaptation, persistence, transfer, protection, replay and experimental state.

```text
Human Residence
      ↓
Syvax gateway / interaction
      ↓
S5 DataFoundation + provenance
      ↓
Dharen — Context Master
      ↓
ContextFrame
      ├── normal flow
      └── trigger → Anuka — Context Adaptor
                    ↓
             adaptive state / fork
                    ↓
       downstream Criterivox workers
                    ↓
          result / evidence / challenge
                    ↓
             Human Residence
```

## 2. Historical Work Pulled Forward Into S6

### S6-BL-01 — Reuse S5 as authoritative foundation
- Keep complete serialized `DataFoundation` as the S6 input binding.
- Preserve provenance, explicit missingness, validation and canonical representation.
- Preserve browser-first residency and revision-aware recovery.
- Verify S5 → S6 integration does not reduce the foundation to summary counters.

**Status:** IMPLEMENTED; verification remains.

### S6-BL-02 — Reactivate and refine Sandre
- Keep Sandre as Data Stewardship responsibility upstream of Dharen.
- Preserve confirmation-gated stewardship and provenance-aware handling.
- Verify Sandre state and S5 foundation remain independent of presentation buffers.

**Status:** IMPLEMENTED; regression verification remains.

### S6-BL-03 — Reactivate and refine Kaelen
- Keep Kaelen responsible for build/experimentation work and short-lived scratchpad state.
- Preserve separation between build work, authoritative foundation and durable context.
- Verify experimental work cannot silently mutate authoritative state.

**Status:** IMPLEMENTED/ARCHITECTURALLY DEFINED; verification remains.

### S6-BL-04 — Pull Bloom forward from earlier sprints
- Treat Bloom as the capability-discovery/world surface, not a duplicate work area.
- Keep character/home presentation separate from computational contracts.
- Ensure Bloom exposes available capabilities without becoming an authority for data/context state.
- Verify navigation and character discovery remain compatible with S6 state.

**Status:** IMPLEMENTED/REFINED; UI verification remains.

### S6-BL-05 — Pull Syvax forward from earlier sprints
- Keep Syvax as dialogue host, interaction gateway, routing/orchestration and presentation boundary.
- Syvax must not become the intelligence authority.
- Presentation must project authoritative state rather than create it.
- Verify human intent → Syvax → domain event → S5/S6 flow and result projection.

**Status:** IMPLEMENTED/REFINED; end-to-end verification remains.

## 3. Human Residence Integration

### S6-BL-06 — Human Residence as external decision participant
- Model Human Residence as the human-side environment rather than another autonomous worker home.
- Support goal → data/context → Criterivox → options/decision → challenge → accept/reject → action → real-world result → feedback.
- Preserve human agency and decision authority.
- Persist only the contextual/result state required by the defined contracts.
- Verify returned real-world results can become new evidence/context without bypassing provenance.

**Status:** ARCHITECTURALLY DEFINED; verification/UI completion remains.

## 4. SOLID and Modular Architecture

### S6-BL-07 — Apply SOLID principles across S6
- Single Responsibility: separate context framing, prioritisation, compression, firewalling, adaptation, persistence, replay and handoff services.
- Open/Closed: add context strategies, model adapters and presentation projections through stable interfaces.
- Liskov Substitution: interchangeable strategy/model implementations must preserve contract invariants.
- Interface Segregation: keep runtime, persistence, ML, presentation and context interfaces narrow.
- Dependency Inversion: domain/context logic must depend on abstractions rather than Flutter, WebSocket or concrete ML implementations.
- Record architectural exceptions where legacy boundaries cannot yet be refactored safely.

**Status:** TO TEST/REFINE.

### S6-BL-08 — Modular boundaries for next work
Target modules:

```text
S5 Data Foundation
S6 Context Core
Context Policies / Strategies
Dharen Agent
Anuka Agent
Persistence / IndexedDB
Runtime Protocol
Sandbox / Replay
ML Training / Evaluation
ML Inference Adapter
Presentation Contract
Syvax / UI
Bloom / Discovery
Human Residence
Verification / Test Fixtures
```

No module should require knowledge of unrelated presentation or infrastructure details.

**Status:** IN PROGRESS.

## 5. Smart Testing and Verification

### S6-BL-09 — Unit and contract verification
- ContextFrame invariants.
- Priority/tier ordering.
- Hard/soft constraint preservation.
- Provenance preservation.
- Firewall behavior.
- Anuka trigger matrix.
- Token budgeting.
- Checkpoint serialization/deserialization.
- Sandbox isolation and promotion/discard.
- Runtime message contracts.

**Status:** IN PROGRESS.

### S6-BL-10 — Integration verification
- Browser/IndexedDB → WebSocket → Python foundation recovery.
- Python restart with newer browser revision must not overwrite browser authority.
- S5 DataFoundation → Dharen → ContextFrame → downstream handoff.
- Trigger → Anuka → adaptive state/fork.
- Sandbox create → run → inspect → compare → promote/discard.
- Syvax request → domain event → computation → presentation projection.

**Status:** REQUIRED.

### S6-BL-11 — Smart test matrix
Tests must cover:
- happy paths;
- malformed state;
- stale revisions;
- conflicting context;
- missing context;
- low token budgets;
- high-priority constraints under pressure;
- adaptive triggers;
- sandbox isolation;
- replay determinism where applicable;
- browser/runtime disconnect and recovery;
- character presentation failure without domain-state corruption.

**Status:** REQUIRED.

## 6. Learned Evidence Collection and ML Verification

### S6-BL-12 — Evidence collection protocol
Separate:
- implementation evidence;
- training evidence;
- evaluation evidence;
- runtime inference evidence;
- research evidence;
- human-validated evidence;
- weak/public-data labels.

Every learned-model claim must identify its evidence class and artifact/reference.

**Status:** REQUIRED.

### S6-BL-13 — Reproducible ML training
- Preserve explicit train/validation/test splits.
- Preserve dataset/version/provenance information.
- Record training configuration and random seed where supported.
- Generate and retain model artifacts.
- Record evaluation metrics without inventing thresholds.

**Status:** CODE PATH EXISTS; generated-artifact verification remains.

### S6-BL-14 — Runtime inference verification
- Load generated Dharen/Anuka/supporting compression artifacts.
- Execute inference through the actual runtime boundary.
- Verify deterministic rules remain authoritative over learned predictions.
- Record inference evidence and failure behavior.

**Status:** REQUIRED.

## 7. UI Refinement

### S6-BL-15 — Refine Syvax presentation
- Show meaningful semantic state without making UI state authoritative.
- Improve loading/error/recovery states.
- Preserve accessibility and reduced-motion behavior.
- Keep context metrics understandable and non-decorative.

### S6-BL-16 — Refine Bloom discovery
- Clearly distinguish capabilities, workers and homes.
- Avoid presenting character personality as evidence of intelligence.
- Make active/available computational responsibility discoverable.

### S6-BL-17 — Refine Human Residence
- Clearly distinguish human goal, challenge, decision, action and result.
- Make the human/system boundary understandable.
- Avoid implying autonomous authority where the human retains the decision.

**Status:** REQUIRED/ITERATIVE.

## 8. S6 Research/Architecture Decisions to Preserve

- S5 remains authoritative; S6 consumes the complete DataFoundation.
- Character ≠ underlying ML/model.
- Dharen = computational Context Master.
- Anuka = conditional Context Adaptor.
- Anuka is trigger-driven, not a mandatory linear next step.
- Syvax = interaction/gateway/orchestration/presentation boundary.
- Bloom = capability-discovery surface.
- Human Residence = human-side decision environment, not another autonomous worker home.
- Deterministic scope, safety and firewall rules remain above learned components.
- Context is durable state, not a transient prompt decoration.
- Browser-first residency is retained for foundation/context recovery.
- Sandbox state is isolated until explicit promotion.
- Training code, trained artifacts, runtime inference and CI evidence are separate claims.
- S6 completion requires verification evidence, not documentation alone.

## 9. Current Exit Gate

S6 remains **NOT COMPLETE** until the remaining evidence gates are closed:

- [ ] SOLID/modular refactor and architecture checks completed where needed.
- [ ] Smart unit/contract test matrix passes.
- [ ] Full integration/regression suite passes.
- [ ] Fresh CI evidence exists for the final revision.
- [ ] ML training completes and artifacts are retained.
- [ ] Runtime inference using generated artifacts is demonstrated.
- [ ] Browser sandbox E2E verification passes.
- [ ] Python restart/browser revision recovery regression passes.
- [ ] Learned evidence collection records are complete.
- [ ] Syvax/Bloom/Human Residence UI refinement and verification pass.
- [ ] Final documentation/ADR/backlog status is updated from actual evidence.

**Definition of Done:** implementation + tests + verification evidence + reproducible ML evidence + UI verification + documentation consistency.
