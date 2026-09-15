# S7 fixture scenarios

The laboratory now has explicit scenario modules for `reasoning`, `hypothesis`, `contradiction`, `provenance`, `intervention`, `insufficient_context`, and `cross_component`.

These generators create synthetic stimuli only. They simulate structured requests arriving from Criterivox components and must never be treated as production evidence. The top-level `generate.py` remains the canonical JSON/CSV/XLSX writer and manifest producer.
