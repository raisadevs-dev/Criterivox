# Criterivox 2.0 — Python Backend Hosting Readiness

Status: repository review completed; no public backend deployment performed.
Target branch: `criterivox-2.0`

## What exists

- Python package requires Python `>=3.13,<3.14` in `pyproject.toml`.
- FastAPI application entrypoint: `src/criterivox/app.py`.
- Health endpoint: `GET /health`.
- Runtime WebSocket: `/runtime/characters`.
- Human authentication and residence routes are defined in `src/criterivox/ui/routes.py`.
- Current auth/residence responses explicitly identify storage as `local-sqlite`.
- `requirements.txt` installs `-e .[dev,ml]`; project runtime dependencies are declared in `pyproject.toml`.
- `.env.example` currently contains only the environment selector.
- Existing CI workflows use Python 3.13, but the repository review did not establish a production container image or hosted service configuration.
- The FastAPI CORS configuration currently permits localhost/127.0.0.1 origins only. A hosted frontend origin must be explicitly configured; do not broadly allow arbitrary origins with credentials.
- `src/criterivox/app.py` mounts static files from a repository-relative path. A container must start from the correct project root or configure this path robustly.

## Hosting compatibility

AppDeploy's available backend scaffold is TypeScript-based (`backend/index.ts`) and imports its platform SDK. It does not directly execute the repository's Python/FastAPI app. The existing Python service therefore needs a Python-capable hosting target, such as a container-compatible application platform, or a separately provisioned server.

No provider/account was specified or connected in this task. Do not claim the backend is publicly reachable until a provider is selected, deployment is authorized/configured, and a live health check succeeds.

## Pre-deployment requirements

1. Select a Python-capable hosting provider and connect its deployment integration or authorize the required account setup.
2. Build a reproducible Python 3.13 container/start command from the repository's actual dependency declarations; install only runtime dependencies needed by the service, not development/test extras by default.
3. Confirm all model files, datasets and static assets required at startup are packaged or retrieved from an approved persistent location. Do not assume local workstation files exist in the cloud.
4. Inventory every SQLite-backed store, file write, cache, model download and in-memory runtime object. Local ephemeral disks and in-memory dictionaries are not durable multi-instance storage. Decide which records require persistent, user-isolated storage before exposing accounts publicly.
5. Review session-token generation, expiry, revocation, password handling, authorization on every user-scoped route, upload limits, rate limits and logging of sensitive values.
6. Configure HTTPS, a strict allowlist of the deployed frontend origin(s), secure WebSocket transport, health/readiness checks, request limits, service restart behavior and monitoring.
7. Use provider-managed secrets for any credentials. Never commit secrets or put backend credentials in frontend bundles.
8. Deploy to a staging environment first. Verify `GET /health`, expected API routes, WebSocket connect/reconnect, task isolation, account boundaries, persistence across restart, and no leakage of private residence/research data.
9. Configure the AppDeploy frontend with the verified API and WebSocket base URLs through safe environment configuration, then run cross-service end-to-end QA.
10. Promote to a public deployment only after the above checks pass and limitations are documented.

## Local-versus-hosted behavior

The local launcher starts services in the user's environment; it does not itself provide a public network endpoint. Cloud hosting is a separate runtime with different filesystem, process, network, secrets, persistence and security assumptions. Do not copy a local database or private data into a public deployment without explicit review and consent.

## Current decision needed

Choose or connect a Python-capable hosting provider. Until then, implementation can continue in the GitHub branch and local tests, but a genuine public FastAPI URL cannot be created from AppDeploy's TypeScript-only backend runtime alone.
