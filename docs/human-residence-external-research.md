# Human Residence external research and research instrumentation

Human Residence is the intake and decision boundary. When the human enables **Allow Google external research**, the backend decision orchestrator calls Google Programmable Search and attaches returned evidence to the decision trace.

## Configuration

Set these server-side environment variables:

- `CRITERIVOX_GOOGLE_API_KEY`
- `CRITERIVOX_GOOGLE_CX`

The human's Criterivox email may be used as participant identity only when the human separately enables Criterivox research participation. It is not used as a Google credential. Passwords, authentication tokens and provider credentials are outside the research instrumentation boundary.

## Runtime flow

```
Human Residence
  -> Decision Orchestrator
  -> supplied-data Data Foundation
  -> human research permission
  -> Google Programmable Search
  -> URL/snippet provenance records
  -> reasoning + strategy options
  -> challenge
  -> human acceptance
  -> local execution/calendar authorization event
  -> outcome journal
  -> reviewed learning evidence
```

If Google credentials are not configured, an authorized research request fails explicitly rather than silently pretending that research happened.

The V1 browser keeps the active residence/session in IndexedDB. Python owns the runtime and persists identity, decisions, lifecycle events and trace records in local SQLite.


## Research instrumentation

Human Residence also provides an optional research-participation boundary. It is separate from the Google external-research permission above.

The participant may independently choose:

- research participation;
- retention of original human messages;
- outcome follow-up.

Research participation stores a participant name and email in the research participant table. Structured interaction events are stored only for an opted-in research participant. Original messages require the additional raw-text choice. Outcome records require the additional outcome-follow-up choice.

The V1 research instrumentation store is SQLite. Runtime chat events include language/meaning interpretation and the human confirmation lifecycle. If the human does not respond to an interpretation confirmation within 60 seconds, Criterivox continues with the recorded interpretation and marks the event `UNCONFIRMED_TIMEOUT`.

This instrumentation is intended to support descriptive analysis of the proposed research questions. It does not itself establish causal improvement in decision quality.
