# Human Territory Release Validation

## Automated checks

The `Human Territory Flutter Analysis` workflow completed successfully on `railway/production-deployment` at commit `d740a076c53a630e65542769ef93798e14e1bcf2` on 2026-10-02. The workflow passed Python dependency installation, Human Situation strategy-routing regression tests, Flutter dependency resolution, Dart formatting, Flutter analysis, and Flutter tests.

## Deployment verification

Railway's `criterivox-web` and `criterivox-api` services are configured to track `railway/production-deployment`. A successful deployment is not sufficient evidence that the latest branch revision is live. Confirm the deployed commit hashes and smoke-test the web interface, API health endpoint, and core decision flow after each release.

## Research prototype boundary

Automated CI and successful hosting validate software checks and deployment availability only. They do not constitute empirical research validation or establish production readiness.
