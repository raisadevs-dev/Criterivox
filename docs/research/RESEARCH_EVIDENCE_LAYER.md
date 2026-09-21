# Criterivox Research Evidence Layer

The research evidence layer is researcher-facing infrastructure, not ordinary user UI.

## Local mode

By default, research collection is disabled:

- `CRITERIVOX_RESEARCH_ENABLED=false`
- SQLite path: `data/research/criterivox_research.sqlite3`

When enabled for a study, the backend stores:

- participants
- versioned consent records
- study sessions
- consent-gated interaction events

Human Residence events are forwarded into this layer only after a research session is attached to the work.

## Access

Researcher endpoints are protected by `CRITERIVOX_RESEARCH_ADMIN_TOKEN`.

- `POST /api/research/consent`
- `POST /api/research/session`
- `POST /api/research/attach-work/{work_id}`
- `GET /api/research/summary`
- `GET /api/research/sessions`
- `GET /api/research/events`
- `GET /api/research/export.json`
- `GET /api/research/export.csv.zip`

The token is supplied as the `X-Research-Admin-Token` request header or the query parameter name currently accepted by the route: `x_research_admin_token`.

## Production transition

The application code depends on the `ResearchRepository` interface rather than SQLite-specific calls. The initial implementation is SQLite so the research pipeline can be validated locally before deployment.

For a multi-user public deployment, the repository implementation should be replaced/configured with a server-side database such as PostgreSQL. The research event model and export format do not need to change.

Large research artifacts should eventually use object storage rather than putting binary files into the relational database.

## Research boundary

Research collection is intentionally separate from ordinary product operation. Technical ability to observe a value does not make it a research variable.

Collection should remain driven by:

`research question -> required variable -> collection mechanism -> permission/consent -> dataset -> analysis`

The implementation does not silently collect research telemetry when the feature is disabled or when the participant lacks the relevant consent purpose.
