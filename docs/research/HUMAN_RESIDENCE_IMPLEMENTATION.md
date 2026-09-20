# Human Residence Work Engine

## Implemented boundary

Human Residence is a persistent human-owned work surface over the existing StateRuntime. Flutter is the human window; Python owns the authoritative work record and journey linkage.

## Lifecycle

`DRAFT → INTERPRETING → AWAITING_CONFIRMATION → CONFIRMED → WORKING → READY_FOR_HUMAN → UNDER_REVIEW → CHALLENGED/REWORKING → DECISION_READY → AUTHORIZED → COMPLETED`

The human confirmation gate is mandatory before the work runner starts.

## Materials

Original uploaded bytes are retained with SHA-256 provenance. Deterministic extraction currently covers:
- TXT, Markdown, CSV, JSON, YAML, XML and text files
- DOCX
- XLSX
- image files are retained while visual/OCR extraction is explicitly reported unavailable

Extraction never replaces the original source.

## Human governance

TAKE changes ownership of review, not the decision.

Challenge and evidence requests are durable events. Decisions record the selected option, modification, actor, timestamp and human authority. Authorization is a separate state transition. No external action adapter is invented.

## Interruption

Pause/resume are explicit API operations backed by StateRuntime checkpoints. Timeline and artifact endpoints expose durable records rather than reconstructed chat history.

## Multilingual boundary

The existing deterministic language layer supports English, Hindi and Marathi. Residence interpretation stores detected language and canonical intent separately from the human-facing material. Internal work state remains language-independent.

## Current limitations

This pass does not claim unrestricted NLU, OCR/vision understanding, production authentication, distributed background execution after a Python process restart, or external action execution. Unsupported capabilities remain explicit rather than simulated.

## Verification

Automated lifecycle tests cover interpretation confirmation, material extraction status, correction re-entry, TAKE, challenge/rework, decision and authorization. CI execution still needs to be observed in the repository's GitHub Actions environment.
