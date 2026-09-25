# Criterivox Human Situation Understanding & Decision Support

**Branch:** `ui-stabilization-system-behavior`

## Capability

The Decision Desk now accepts an ordinary-language situation instead of requiring Criterivox terminology. The human-facing path is:

`Situation description → Situation Understanding → Safety/Urgency → Existing Decision Orchestrator → Human-readable support → Optional deeper inspection`

The new application boundary is `HumanSituationOrchestrator`. It composes existing Syvax intent routing and the existing `DecisionOrchestrator`; it does not replace them.

## Situation model

`Situation` records the user description, goal, context, people/entities, constraints, options, evidence, uncertainties, time sensitivity, safety level, desired outcome, user-reported behavior, and image role/count metadata. Fields are optional and incomplete situations are valid.

## Safety and urgency

Safety routing occurs before ordinary decision strategy generation.

- **Ordinary:** normal decision/planning support.
- **Sensitive:** interpersonal harm, bullying, harassment, intimidation, coercion, or similar signals. The system asks a small set of materially relevant questions.
- **Immediate:** a possible current danger signal. The system prioritizes moving toward safety, contacting a trusted nearby person/adult or appropriate real-world assistance, and avoiding retaliation/confrontation. It does not continue ordinary strategy generation first.

For children and teenagers, the support path explicitly treats trusted adults and appropriate school/support staff as important real-world support. Criterivox is not a substitute for responsible adults.

## Image-input boundary

Images may be attached to the Decision Desk and are assigned an explicit role such as photograph of people, document photo, screenshot, diagram, or other.

A photograph of people is contextual input only. The human-situation layer does not identify people from faces or infer personality, intent, morality, dangerousness, mental state, relationships, or bullying behavior from appearance. Behavioral claims remain grounded in the user's report or legitimate evidence.

The image role/count is passed as metadata only; image bytes are not sent to Ollama by this capability.

## Existing capability integration

Authenticated situations flow through the existing `DecisionOrchestrator`, which already connects:

- Syvax intent/plan routing,
- Sandre / data-foundation ingestion,
- Dharen context,
- Medrus / evidence boundary when external research is authorized,
- Tarkis reasoning,
- Pramon decision options,
- Manis challenge,
- human decision persistence,
- existing Results Journal storage.

The existing human decision record remains the persistence authority. Outcomes are only recorded when supplied by the human/system; no outcome is fabricated.

Guest/unauthenticated use can still understand a situation and produce the deterministic decision-support fallback without pretending that a persisted decision record exists.

## Ollama

Ollama is an optional local language/synthesis layer in `OllamaLanguageLayer`.

It is used only when the local Ollama endpoint is reachable and configured. It receives the structured situation and user description for human-readable synthesis. It is not the evidence source, decision authority, identity authority, or computational engine.

If Ollama is unavailable, Criterivox uses the deterministic human-readable synthesis already produced by the application layer. No silent fake LLM result is generated.

## Decision Desk

The existing Decision Desk is the primary human-facing surface. It now provides:

- ordinary-language situation entry,
- optional context/data,
- optional image attachment with explicit image role,
- safety-first clarification,
- understandable situation summary,
- what matters,
- next actions,
- uncertainties,
- option cards,
- human-authority boundary,
- Results Journal navigation.

No competing decision interface was introduced.

## Progressive disclosure

Default presentation stays human-readable. Internal task IDs, agent routing, raw traces and implementation details are not required to understand the answer. Existing evidence/reasoning/trace surfaces remain available through deeper inspection.

## Human authority

Criterivox distinguishes:

1. what the human reported,
2. what the system inferred/structured,
3. what evidence is actually available,
4. what remains uncertain,
5. what next actions can be considered.

The human can correct the situation, answer clarifying questions, reject suggestions, inspect evidence, explore another option, or decide what happens next.

## Validation

The repository contains tests covering:

- general decision clarification,
- interpersonal/bullying reports,
- people-photo safety boundary,
- explicit safety answers without question loops,
- immediate-safety routing,
- deterministic fallback when Ollama is unavailable,
- existing Syvax-backed decision support,
- image-role preservation.

Fresh local Flutter/Python execution remains environment-dependent when the repository connector cannot execute the local toolchain; such runs are not represented as passed merely because test files exist.
