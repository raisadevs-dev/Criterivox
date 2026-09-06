# Dharen Rive Character Asset

This directory is the authored animation boundary for Dharen.

Expected production asset:

- `dharen.riv`
- Artboard: `Dharen`
- State machine: `DharenLifecycle`
- Runtime states: `IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`

The Flutter renderer maps the application-owned semantic character state to this animation layer. Rive owns motion, posing, facial expression, transitions, and continuous character animation. Python/application/domain code does not control animation frames.

Until the authored `.riv` asset is added, Criterivox uses the deterministic Flutter renderer as a graceful fallback.
