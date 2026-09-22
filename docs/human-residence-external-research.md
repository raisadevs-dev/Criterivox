# Human Residence external research

Human Residence is the intake and decision boundary. When the human enables **Allow Google external research**, the backend decision orchestrator calls Google Programmable Search and attaches returned evidence to the decision trace.

## Configuration

Set these server-side environment variables:

- `CRITERIVOX_GOOGLE_API_KEY`
- `CRITERIVOX_GOOGLE_CX`

The human's Criterivox email is recorded as the requesting identity in the research audit trail. It is not used as a Google credential.

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
