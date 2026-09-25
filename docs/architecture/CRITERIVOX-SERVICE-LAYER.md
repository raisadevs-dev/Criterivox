# Criterivox Service Layer

**Status:** IMPLEMENTED on `criterivox-service-layer`.

The Service Layer is the reusable composition boundary between heterogeneous human requests/situations and existing computational capabilities.

## Boundary

Human request/context -> service selection -> S5/S6/S7/S8/S9 capability reuse -> execution -> ServiceResult -> human authority/downstream presentation.

Characters and homes are not service owners. S9 explicitly prohibits capability ownership by characters; S7/S8 remain authoritative for reasoning/evidence artifacts.

## Service contracts

`ServiceRequest`, `ServicePlan`, `ServiceResult`, and `OutcomeRecord` live in `src/criterivox/service_layer/contracts.py`.

A ServiceResult records status, purpose, structured result, evidence/provenance references, uncertainty, limitations, alternatives, challengeable/editable elements, downstream dependencies, artifact references, execution reference and authorization state.

## Implemented services

| Service | State | Existing capability reused |
|---|---|---|
| Situation Understanding | IMPLEMENTED | S6 ContextIntelligenceEngine + existing situation understanding |
| Evidence/Data Analysis | IMPLEMENTED | S5 DataFoundationStore + S8 artifact/provenance |
| Analytical Reporting | IMPLEMENTED | deterministic computation over supplied structured data |
| Reasoning/Hypothesis | IMPLEMENTED | S7 ReasoningResearchBureau |
| Strategy Construction | IMPLEMENTED | structured strategy contract |
| Trade-off Analysis | IMPLEMENTED | qualitative option comparison |
| Decision Support | IMPLEMENTED | human-authority result boundary |
| Planning | IMPLEMENTED | strategy-to-task/checkpoint representation |
| Verification/Explanation | IMPLEMENTED | S8 EvidenceResearchBureau |
| Outcome/Learning hook | IMPLEMENTED | S8 memory artifact marked pending review |

## Composition

Composition is request-driven. Analysis, strategy, planning and verification are not universally activated. The current planner uses deterministic request semantics and the existing situation-intent result. This is an initial service-selection mechanism, not a claim of universal intent understanding.

## Human authority

Decision Support and Planning results are explicitly human-controlled. Outcome records are not treated as autonomous learning; they remain pending review.

## Insufficiency

Services may return `INSUFFICIENT`, `CLARIFICATION_REQUIRED`, `FAILED`, or `UNSUPPORTED`. Missing evidence is not converted into a finding.

## Presentation

The existing Human Residence / Decision Desk path remains the application entry boundary. No Level 1/Level 2 redesign or Work Materials Layer was introduced in this branch. The service result contract is intended to be consumed by that later layer.

## Truth boundary

This branch does not claim a universal service implementation. Deterministic analytical computation is limited to supplied structured material; external factual verification still depends on S8 evidence and available sources; autonomous learning is not claimed.
