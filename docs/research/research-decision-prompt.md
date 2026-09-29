# CRITERIVOX — S5 Research-Specific Decision Record Prompt

## Purpose

Use this prompt to collect only the research/domain decisions that S5 must not invent through engineering assumptions. The output becomes a traceable research decision record for Criterivox S5 and downstream implementation.

## Instruction

Act as the **research authority for Criterivox Sprint 5: Data Foundation + Sandre Data Stewardship**.

Review the existing Criterivox S5 Research Material Package and the cited primary research sources. Do **not** redesign the software. Do **not** invent unsupported research conclusions. Do **not** convert engineering heuristics into research findings.

For every decision below, provide:

1. **Decision** — the recommended research-grounded rule.
2. **Evidence** — exact source(s), section/table/page where possible.
3. **Rationale** — why the evidence supports the decision.
4. **Scope** — where the rule applies and where it does not.
5. **Exceptions** — known cases that need special handling.
6. **Confidence** — High / Medium / Low, with justification.
7. **Open questions** — anything that still cannot be resolved from the evidence.
8. **Implementation consequence** — what S5 should do differently because of this decision.
9. **Verification method** — how the implementation can later be tested against the decision.

### Decision 1 — Normalization Policy

Determine the research-supported normalization policy for platform/content data.

Resolve:
- Which values may be normalized safely.
- Which platform-native meanings must remain unchanged.
- Unit conversion rules, if any.
- Terminology/category mappings, if any.
- Whether normalization should create a derived value while preserving the original.
- Cases where normalization must be refused or marked uncertain.

### Decision 2 — Duplicate Semantics

Determine what constitutes a duplicate or duplicate candidate.

Resolve:
- Exact duplicates versus probable duplicates.
- Which identifiers/fields can establish identity.
- Whether cross-platform records can ever be duplicates.
- What evidence is required before merging.
- Whether suspected duplicates must remain separate pending confirmation.

### Decision 3 — Anomaly Semantics

Determine what qualifies as a research/domain anomaly rather than merely a statistical outlier.

Resolve:
- Which anomaly types are meaningful.
- Whether statistical outliers are sufficient evidence.
- Required context before flagging an anomaly.
- Whether anomalies can ever be automatically removed.
- How anomaly findings should preserve provenance and uncertainty.

### Decision 4 — Confidence Semantics

Determine what confidence means for research-derived interpretation.

Resolve:
- What a confidence score represents.
- What evidence can contribute to confidence.
- Whether confidence is calibrated or only ordinal.
- Appropriate confidence categories or thresholds, if supported.
- When low confidence must require human clarification.
- What must never be represented as research-backed confidence.

### Decision 5 — Final Platform Scope

Determine the platform scope supported by the research package for S5 and downstream work.

For each platform, identify:
- Supported research relevance.
- Required platform-native fields.
- Comparable/common fields.
- Platform-specific fields that must not be collapsed into a generic field.
- Known limitations or unavailable information.

Do not add platforms merely because they are technically convenient.

### Decision 6 — Experimental Targets

Determine which downstream experimental targets the prepared data is intended to support.

Resolve:
- Target research questions/hypotheses.
- Required variables.
- Outcome/target variables, if any.
- Required context variables.
- Constraints on train/test or temporal separation, if supported by the research methodology.
- Information that S5 must preserve so later experiments remain reproducible.

Do not design S7 models here.

### Decision 7 — Exact Context Definition

Define **context** for Criterivox in research-grounded terms.

Separate, where evidence supports it:
- User-supplied context.
- Source-provided context.
- System-derived information.
- Research interpretation.
- Confirmed user information.

State what belongs in context and what must remain a data value, provenance record, derived feature, or interpretation.

### Decision 8 — Missingness Taxonomy

Determine the research/domain-supported meaning of missing or unavailable information.

Resolve distinctions such as:
- Unknown.
- Not provided.
- Not applicable.
- Not measured.
- Not observed.
- Withheld.
- Unavailable.
- Extraction failed.

Only retain categories that are justified by the research evidence. If the research does not justify a distinction, explicitly mark it unresolved rather than inventing one.

## Required Final Decision Matrix

Return a table with these columns:

| Decision Area | Final Rule | Evidence | Confidence | Implementation Impact | Verification | Open Questions |
|---|---|---|---|---|---|---|

## Required Traceability Records

For every finalized decision, create this record:

```text
Research Source:
Research Finding / Definition:
Decision Made:
Reason:
Affected S5 Component:
Affected Data Field / Contract:
Implementation Change Required:
Test / Verification Required:
Status: FINAL | PROVISIONAL | UNRESOLVED
```

## Hard Rules

- Never fabricate a source, page, statistic, definition, or methodology.
- Never silently resolve conflicting research sources.
- If evidence is insufficient, mark the decision **UNRESOLVED**.
- Keep original platform/source meaning intact unless the evidence explicitly supports transformation.
- Do not treat an engineering heuristic as research evidence.
- Do not define model architecture, XAI methods, or S7 training behavior.
- Do not remove anomalies or suspicious observations merely to make a dataset cleaner.
- Preserve provenance for every research-derived transformation.
- Distinguish researcher-provided material from published research evidence.
- Every FINAL decision must be traceable to evidence.

## Output

Produce one versioned research decision document titled:

**CRITERIVOX S5 — Research-Specific Data Foundation Decisions**

Include:
1. Decision matrix.
2. Evidence register.
3. Detailed decision records for all eight areas.
4. Traceability records.
5. Unresolved questions.
6. Change-impact summary for S5.
7. Verification/test implications.
8. Decision date and source version/date.
