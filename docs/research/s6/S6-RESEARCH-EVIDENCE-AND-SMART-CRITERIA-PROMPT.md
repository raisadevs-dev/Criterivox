# CRITERIVOX — S6 RESEARCH EVIDENCE + SMART CRITERIA COLLECTION PROMPT

## Purpose

Collect traceable research evidence and decision criteria for the S6/S7 intelligence and interaction features already identified in Criterivox. This is a research collection task, not a software-design task.

Do not invent evidence, citations, benchmarks, standards, user-study results, licensing conclusions, or claims of novelty.

## Features under investigation

1. Context Provenance Graph — S6 BASE VISUAL REQUIREMENT
2. Context Diff
3. Evidence Debt / evidence completeness
4. Context Memory with Expiration / recheck conditions
5. Agent Observability Timeline
6. Controlled Multi-Agent Handoff
7. MCP-ready capability boundary
8. Human Challenge Checkpoints, explicitly FUTURE
9. English/Hindi interaction language mode
10. 2D skeletal character runtime: DragonBones-style / Spine-style data model versus an actual production runtime

## Required evidence labels

Every conclusion must be labelled exactly as one of:

- EVIDENCE
- DECISION
- ASSUMPTION
- HYPOTHESIS
- IMPLEMENTED
- FUTURE
- UNKNOWN

Never silently convert one label into another.

## A. Context Provenance Graph

Investigate:

- provenance models for data/AI pipelines
- lineage graphs and traceability
- provenance granularity
- transformation provenance
- provenance verification
- immutable versus append-only provenance
- provenance visualization usability
- provenance requirements in scientific/research workflows

Smart criteria:

- traceability from source to interpretation
- distinguish source, transformation, context, interpretation and evidence
- identify missing provenance links
- human readability
- auditability
- storage cost
- privacy/security implications
- whether graph visualization improves traceability or merely increases interface complexity

Criterivox requirement:

`SOURCE → DATA FOUNDATION → CONTEXT → INTERPRETATION` is the base visual traceability chain for S6. Do not treat it as an optional dashboard decoration.

## B. Context Diff

Investigate:

- dataset/context version comparison
- semantic diff versus structural diff
- temporal/contextual comparison
- change detection in analytical workflows
- human comprehension of change visualizations

Smart criteria:

- distinguish added, removed, unchanged and changed values
- preserve uncertainty when semantic equivalence cannot be established
- avoid presenting structural difference as causal difference
- identify which changed dimension could affect interpretation
- preserve prior context instead of overwriting it

## C. Evidence Debt

Investigate:

- evidence quality/completeness frameworks
- provenance-aware confidence and uncertainty
- evidence gaps in decision support
- data quality dimensions relevant to evidence
- human interpretation of confidence/completeness indicators

Evaluate whether a completeness percentage is scientifically defensible. If not, determine what the percentage can legitimately mean.

Required output:

- proposed evidence-completeness definition
- formula or measurement method, if supported
- limitations
- tag taxonomy
- thresholds, only when evidence supports thresholds

Current Criterivox tags:

- HIGH
- MEDIUM
- LOW
- UNKNOWN

Do not treat thresholds as validated until research supports them.

## D. Context Memory with Expiration

Investigate:

- temporal validity of contextual knowledge
- data freshness and staleness
- TTL/revalidation patterns
- knowledge expiration
- temporal provenance
- recheck triggers
- domain-specific validity periods

Smart criteria:

- explicit creation/update time
- explicit validity interval when justified
- expiration versus revalidation distinction
- reason for recheck
- dependency on changing context
- no silent conversion of expired information into false information

Do not choose a universal TTL without evidence.

## E. Agent Observability Timeline

Investigate:

- observability for agentic/AI workflows
- traces, spans, events and structured logs
- multi-agent task tracing
- human-readable agent activity timelines
- reproducibility and debugging
- privacy/security of agent traces

Smart criteria:

- who acted
- what happened
- when it happened
- why it happened
- input/context identifier
- evidence involved
- output/handoff
- failure/recovery event
- correlation/task identifier

## F. Controlled Multi-Agent Handoff

Investigate:

- multi-agent orchestration and delegation
- explicit handoff protocols
- task ownership
- context transfer
- authorization and approval boundaries
- auditability
- failure recovery

Required handoff fields to evaluate:

- from
- to
- reason
- task/context identifier
- evidence references
- request
- constraints
- expected output
- status
- approval/authorization where relevant

Do not claim autonomous multi-agent safety merely because these fields exist.

## G. MCP-ready capability boundary

Investigate:

- MCP architecture and tool/resource/prompt boundaries
- capability discovery
- tool input/output contracts
- authorization
- provenance
- transport independence
- security implications

Determine whether a protocol-neutral internal capability boundary is a sound precursor to a future MCP adapter.

Do not add an MCP dependency merely because MCP is trending.

## H. Human Challenge Checkpoints

This is FUTURE work.

Investigate:

- human-in-the-loop decision checkpoints
- challenge/approve/reject/mark-uncertain interaction
- explanation and disagreement capture
- governance and auditability

Do not implement autonomous approval logic in S6.

## I. English/Hindi language mode

Investigate:

- localization versus translation of every application string
- language switching UX
- mixed-language technical applications
- localized labels with canonical technical terminology
- Hindi technical terminology and user comprehension
- persistence of language preference
- accessibility and text expansion

Criterivox requirement:

The app should NOT become a duplicated English/Hindi copy of every word.

Localize first:

- navigation labels
- buttons
- onboarding prompts
- help/guidance
- short user-facing explanations

Keep canonical/stable where precision matters:

- character names
- character IDs
- research labels
- evidence-status tags
- code identifiers
- dataset/source IDs
- precise technical terms when translation would reduce clarity

Permit mixed-language explanations when the technical English term is clearer than an uncertain Hindi translation.

## J. 2D skeletal character runtime

Investigate and compare:

- DragonBones JavaScript/TypeScript runtime
- Spine web runtimes
- JSON/binary skeleton formats
- bones, slots, skins and animation tracks
- state blending/cross-fading
- WebGL versus Canvas rendering
- Flutter Web `HtmlElementView` / platform-view embedding
- local/offline asset delivery
- authoring workflow and export reproducibility
- accessibility/reduced-motion behavior
- licensing requirements and distribution implications

Smart criteria:

- offline/local operation
- deterministic state-to-animation mapping
- state blending
- asset size and performance
- authoring/editability
- reproducible exports
- browser compatibility
- accessibility
- licensing cost/constraints
- ability to replace the renderer without changing Python/domain contracts

Important discipline:

The current Criterivox runtime is an original lightweight skeletal runtime using DragonBones/Spine-style concepts. Do not claim that it is the official DragonBones or Spine runtime. Determine whether adopting an actual production runtime is justified by evidence and licensing requirements.

## Source quality rules

Prefer, in order:

1. peer-reviewed research papers
2. standards/specifications from recognized standards bodies
3. official technical documentation
4. official project repositories and licenses
5. reputable research/engineering reports
6. systematic reviews or high-quality surveys
7. credible practitioner sources for implementation observations
8. community discussions only for user-experience signals, never as sole evidence for research claims

For every source record:

- title
- authors/organization
- publication date
- URL/DOI
- source type
- exact claim supported
- limitations
- Criterivox feature affected
- evidence label

## Recency

Prioritize 2024–2026 evidence for rapidly changing AI/agent/tooling topics. Older foundational work is acceptable when it is still authoritative and directly relevant.

## Anti-buzzword rule

A feature is not justified because it is popular.

For every proposed feature answer:

1. What problem does it solve?
2. What evidence shows the problem matters?
3. What existing approaches solve part of it?
4. What remains unresolved?
5. What measurable criterion should Criterivox satisfy?
6. What could make the feature harmful, misleading or noisy?
7. What is the smallest implementation that can test the research hypothesis?
8. What evidence would make us reject or redesign the feature?

## Final output structure

Produce one traceable research package with:

1. Executive evidence table
2. Feature-by-feature evidence matrix
3. Definitions
4. Candidate criteria
5. Measurement methods
6. Known limitations
7. Contradictory evidence
8. Open research questions
9. Decisions that can safely be implemented now
10. Decisions that require validation
11. Features that must remain FUTURE
12. Source bibliography with URLs/DOIs
13. Research-to-implementation traceability matrix

## Mandatory conclusion discipline

If evidence is insufficient, write:

`UNKNOWN — evidence is insufficient to justify this criterion.`

If a criterion is only a design hypothesis, write:

`HYPOTHESIS — proposed for validation, not established fact.`

If the repository already implements the mechanism, write:

`IMPLEMENTED — repository mechanism exists; effectiveness is not yet validated.`

Do not use words such as “proven”, “best”, “optimal”, “state-of-the-art”, or “novel” unless the collected evidence directly supports them.
