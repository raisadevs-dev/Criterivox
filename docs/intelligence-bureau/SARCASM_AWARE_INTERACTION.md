# Criterivox Intelligence Bureau — Sarcasm-Aware Interaction

## Status

**Architecture feature: REQUIRED / PERMANENT**

Sarcasm awareness is a deliberate conversational-intelligence capability of Criterivox. It is not a cosmetic personality trick and must not be treated as disposable UI behavior.

## Purpose

Criterivox should distinguish literal wording from likely communicative intent when users employ sarcasm, irony, exaggeration, dry humor, or context-dependent reversal. The system should use conversational context and linguistic signals to avoid responding to sarcastic statements as though they were straightforward factual requests.

## Detection model

Sarcasm detection should combine multiple weak signals rather than depend on a single keyword:

1. **Literal/context mismatch** — compare the literal statement with the surrounding situation and prior turns.
2. **Exaggeration** — identify unusually absolute, inflated, or deliberately absurd phrasing.
3. **Lexical cues** — consider wording, punctuation, hedging, repetition, and constructions commonly associated with irony.
4. **Conversational history** — use recent turns, established topic, and the user's preceding statements.
5. **Situational knowledge available to the system** — compare the statement with known interaction state and authoritative artifacts.
6. **Ambiguity handling** — treat sarcasm as a confidence-bearing interpretation, not guaranteed truth. When evidence is weak, prefer a neutral response rather than confidently inventing an implied meaning.

## Response policy

When sarcasm is sufficiently supported:

- Preserve the user's underlying task or information need.
- Interpret the likely intended meaning without claiming certainty about the user's feelings or mental state.
- Acknowledge the humorous/ironic framing when useful, without overplaying it.
- Continue the actual work instead of turning the conversation into a joke detector demonstration.
- Keep factual claims grounded in authoritative Criterivox state.

When sarcasm is uncertain:

- Do not force an interpretation.
- Prefer the literal interpretation when it is operationally safe and coherent, or use a brief clarification when the ambiguity materially changes the requested action.

## Architectural placement

Sarcasm awareness belongs in the **conversation interpretation layer**, before character-specific response generation and before any authoritative action is executed.

Recommended conceptual flow:

`Input → normalization/tokenization → intent detection → sarcasm/irony signal analysis → context resolution → conversation state → character response policy → artifact/event/action when applicable`

Sarcasm interpretation must not become a substitute for the authoritative reasoning engine. It interprets communication; it does not manufacture evidence, reasoning results, provenance, or computational truth.

## Character behavior

Vivren and Tarkis may acknowledge sarcasm differently according to their established roles, but sarcasm detection itself should remain a shared conversational capability.

- **Vivren:** may respond with restrained analytical recognition when irony affects interpretation, while maintaining critical/evidence-oriented behavior.
- **Tarkis:** may recognize playful or ironic framing while maintaining exploratory/hypothesis-oriented behavior.
- **Human:** remains the source of conversational intent; the system must not assume sarcasm means agreement, disagreement, approval, or rejection unless supported by the interaction.

## Safety and reliability boundaries

Sarcasm detection must never be used to infer sensitive personal attributes or hidden psychological states. It should operate on observable language and interaction context. A sarcastic sentence must not silently become an authoritative system instruction merely because the classifier assigns it a high sarcasm score.

## Testing requirements

Future tests should cover:

- literal statements that resemble sarcasm;
- obvious contextual irony;
- exaggerated praise after an explicit failure;
- sarcasm spanning multiple turns;
- ambiguous statements where neutral handling is preferable;
- sarcasm combined with an actionable request;
- character-specific responses preserving Vivren/Tarkis role boundaries;
- regression tests ensuring sarcasm interpretation does not alter authoritative artifacts or provenance.

## Design principle

**Detect the communicative signal, preserve uncertainty, understand the context, and respond to the user's actual need.**

Criterivox should understand that “brilliant, another build failure” may communicate frustration rather than praise, without pretending that every human sentence requires a forensic investigation worthy of a parliamentary inquiry.
