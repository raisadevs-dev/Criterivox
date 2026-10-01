# Criterivox 2.0 — Railway Backend Hosting Readiness

Status: Railway deployment files committed; no Railway project linked and no public backend deployed.
Target branch: `criterivox-2.0`.

## Repository implementation

- Python package requires Python `>=3.13,<3.14` in `pyproject.toml`.
- FastAPI entrypoint: `src/criterivox/app.py`.
- Health endpoint: `GET /health`.
- Runtime WebSocket: `/runtime/characters`.
- Human authentication and residence routes are defined in `src/criterivox/ui/routes.py`.
- `Dockerfile` uses Python 3.13, installs the package's ML extra, and launches Uvicorn on Railway's `PORT` (default 8000).
- `railway.toml` selects the Dockerfile builder and configures `/health` as the health check.
- `.dockerignore` excludes local environments, databases, secrets, caches and build output.
- `CRITERIVOX_CORS_ORIGINS` configures explicit comma-separated browser origins. Defaults cover common local development origins; set the exact deployed frontend origin in Railway's service variables.
- No public URL is created by these commits. Railway project setup, deployment and live verification remain pending.

## Important runtime and security limits

- Existing human residence/auth responses identify their storage as `local-sqlite`. A hosted service must not assume its filesystem is durable. Configure a persistent volume or migrate to a supported database, then verify isolation, backups and restart behavior before real user data is used.
- The app has in-memory runtime/context state. A multi-instance deployment may split state; start with one replica and assess shared-state requirements before scaling.
- Review session expiry/revocation, password handling, authorization on every user-scoped route, upload limits, rate limits, and sensitive logging before public exposure.
- The current backend's CORS allowlist is explicit. Do not use wildcard origins with credentials.
- The app mounts static files from `src/criterivox/ui/static`; confirm this directory is present in the container image and startup succeeds.
- AppDeploy's available backend scaffold is TypeScript-based and does not directly execute this Python/FastAPI service. Host the Python service on Railway and connect the frontend only after endpoint verification.
- Use Railway-managed variables for configuration and secrets. Never commit credentials or put backend secrets in frontend code.

## Railway setup and validation

1. In Railway, create a project and add a service from the GitHub repository `raisadevs-dev/Criterivox`.
2. Select branch `criterivox-2.0`. Ensure Railway detects the repository's root `Dockerfile` (or select Dockerfile builder explicitly).
3. Set `CRITERIVOX_ENVIRONMENT=staging` and `CRITERIVOX_CORS_ORIGINS` to the exact AppDeploy frontend origin. Do not add secrets unless a reviewed backend integration actually requires them.
4. Configure persistent storage for any required SQLite/files, or complete a reviewed migration to a managed database before testing account persistence. Keep staging data synthetic.
5. Deploy and inspect build/runtime logs. Confirm the Railway-generated HTTPS domain serves `GET /health` with status 200 and that the WebSocket endpoint accepts a valid client connection.
6. Verify required API routes, reconnect behavior, user/residence authorization boundaries, persistence across restart, and absence of private-data leakage. Do not treat a successful health response as proof all workflows work.
7. Set the verified HTTPS and WSS base URLs in the frontend's supported environment configuration, then run cross-service end-to-end tests.
8. Public use requires a separate security and privacy review, including user consent and data retention behavior.

## Local versus hosted

The local launcher starts services on the user's machine; it does not itself create a public endpoint. Cloud hosting has different filesystem, process, network, secret, persistence and security assumptions. Do not copy local databases or private data to a hosted service without explicit review and consent.

## Current blocker

The Railway project must be created/authorized by an account holder in Railway. The available GitHub integration can commit repository files but cannot create a Railway project or authorize Railway account access. Do not share account passwords, access tokens or secret values in chat.
