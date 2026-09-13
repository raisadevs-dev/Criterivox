# Criterivox Human Residence Persistence v1.0

## Residence creation

Gate 2 provisions a local Human Residence after the user chooses Login / Sign up. For the current local-first phase, this is an application identity and workspace record, not production authentication.

## Browser authority

The browser keeps the current residence envelope in IndexedDB under `criterivox_human_residence / residences / current`. The envelope contains `residence_id`, `owner_id`, display name, optional email, residence type, creation time, members and metadata.

## Python mirror

Python keeps a durable local mirror at `data/runtime/human_residences.json`. The mirror is keyed by `residence_id`. It exists to survive Python runtime restarts and to provide a stable binding point for future DataFoundation, Context Frame and collaboration handoff.

## Security boundary

This local Login / Sign up flow must not be presented as secure authentication. No password, authentication secret or credential is persisted in the browser residence record or the Python mirror. A production identity provider and server-side authorization remain a separate future boundary.

## Residence model

A residence has a private room and collaboration room. Collaboration membership uses `owner`, `resident`, and `guest` roles. Club/building provisioning should create a separate collaboration container rather than turning an AI character home into a human residence.

## Recovery

IndexedDB is the browser recovery boundary. Python can restore its local mirror by `residence_id`; subsequent runtime synchronization should treat the browser record as authoritative when reconciling browser-local residence metadata.
