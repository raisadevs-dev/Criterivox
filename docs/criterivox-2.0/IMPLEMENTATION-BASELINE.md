# Criterivox 2.0 — Integration Baseline

Status: implementation baseline; not a claim that integrations are complete.
Target branch: `criterivox-2.0`
Product authority: owner-provided Criterivox 2.0 story and Gate 1 / Gate 2 UX model.
Technical reference: existing Criterivox implementation and its current registries.

## Product contract

Criterivox 2.0 is a human-centered, navigable representation of the existing decision-support system. The world map is an interaction surface for real application features, not a claim that characters are independent autonomous models. Agent activity, progress, evidence, reports and handoffs must be rendered only when backed by runtime records. Mark unavailable or simulated features honestly.

The user's story defines the intended journey:
1. Brief welcome animation that ends after roughly three seconds or when initialization completes, whichever occurs first.
2. Account sign-in/sign-up or temporary guest entry.
3. User profile or temporary guest identity.
4. Expandable civilization orb/map and navigable Gate 1 / Gate 2 locations.
5. Human request intake with purpose, expected result, data/context and permission boundaries.
6. Real task execution through available Criterivox capabilities, with traceable agent contribution records.
7. Inspectable agent-specific reports and permitted human challenge/intervention.
8. Human acceptance before consequential action; accepted outputs may be saved to the Result Journal and Calendar.
9. Optional outcome follow-up. Feedback is evidence for review, not an automatic model-training signal.

## Existing implementation references

- Python entrypoint: `src/criterivox/app.py` (FastAPI; includes `/health`, UI routes, operations routes and `/runtime/characters` WebSocket).
- Browser-facing routes: `src/criterivox/ui/routes.py` (includes Human Residence authentication, decision lifecycle and human-situation intake routes).
- Global chat interpretation: `src/criterivox/application/global_chat.py`.
- Character chat: `src/criterivox/application/character_chat.py`.
- Runtime orchestration and WebSocket transport: `src/criterivox/infrastructure/runtime.py`.
- Character registry: `configs/character_chat/character_registry.json`.
- Capability registry: `configs/character_chat/capability_registry.json`.
- Flutter runtime transport: `presentation/lib/presentation/shared/runtime_client.dart`.
- Flutter API configuration: `presentation/lib/presentation/shared/api_client.dart`.
- Current implementation authority: `docs/FINAL-INTEGRATED-RESEARCH-PROTOTYPE.md`.
- Gate 1 / Gate 2 UX baseline: `docs/ux/GATE1-GATE2-CIVILIZATION-UX-ARCHITECTURE.md`.

The registries describe responsibility and implementation status; they do not prove every character has a deep computational adapter. Keep `CURRENT`, `PARTIAL`, `ARCHITECTURE_DEFINED`, `REQUIRED` and `UNKNOWN` distinctions visible in product behavior and documentation.

## Integration constraints

- Keep `main` unchanged. All implementation commits for this effort target `criterivox-2.0`.
- Do not assume the AppDeploy-hosted frontend and GitHub branch are synchronized. Track them as separate artifacts until a repeatable source-sync/deployment process is established.
- The existing Python API is not presumed to be publicly hosted or reachable from AppDeploy. Configure a backend base URL only after a real deployment endpoint and transport/security configuration are verified.
- Do not expose credentials in frontend code, repository files, logs or chat. Use backend-only secret configuration.
- Do not send private residence data or raw messages to research storage by default. Respect separate consent scopes for research participation, identifiable data, raw text and outcome follow-up.
- Existing local-SQLite authentication and residence stores must be reviewed for suitability before public multi-user deployment. Do not represent local persistence as secure hosted account infrastructure without verification.
- Preserve explicit human authorization before consequential execution. Never silently convert user feedback into model training.
- Do not claim hidden chain-of-thought access. Present inspectable reasoning artifacts, evidence, provenance, uncertainty and limitations.
- Keep guest data temporary and isolated from registered residence state unless the user explicitly chooses to retain/convert it.
- Test mobile and desktop paths, error handling, reconnect behavior, authorization boundaries and persistence isolation.

## Delivery sequence

### A. Branch and baseline
Confirm branch head and clean separation from `main`; inventory current AppDeploy snapshot and repository contracts; create a traceable implementation checklist.

### B. Real entry and identity
Replace account-preview UI with a verified authentication flow; retain guest mode as a temporary isolated session. Do not deploy public account creation against local-only auth without a security review.

### C. Runtime connection
Deploy or otherwise securely host the existing FastAPI service, verify `/health`, configure CORS/origin policy and secure API/WebSocket URLs, then connect the frontend to actual API responses and runtime events. Never display demo stages as live work.

### D. Task and agent observability
Connect request intake, capability selection, task IDs, recorded agent events, evidence/provenance, report retrieval and user intervention to authoritative backend state. Use registry metadata for identity/role display while showing computational status accurately.

### E. Residence, journal and outcomes
Connect profile, residence, decisions, acceptance, journal/calendar and outcome records to authenticated, user-scoped persistence. Separate operational telemetry from consent-gated research data.

### F. Verification and deployment
Add or update automated tests for each integrated journey; run Python and Flutter checks in the repository environment; run AppDeploy build, runtime and E2E QA; record test evidence and unresolved limitations. Deploy incrementally from this branch only.

## Current state

- The `criterivox-2.0` branch exists.
- An AppDeploy frontend prototype is deployed separately.
- The prototype's agent replies and task workflow are simulated.
- Backend hosting, verified frontend-to-backend connectivity, production-grade hosted authentication, and end-to-end persistence are not established by this baseline.
