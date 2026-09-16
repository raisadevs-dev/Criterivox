# S8 Fixtures Lab

These are deterministic acceptance fixtures for the **standalone S8 Evidence Research Bureau**.

They are not Criterivox application data, not model training data, and not production knowledge.

## Boundary

- Launcher: `s8-start-evidence-research-bureau.ps1`
- Fixture runner: `scripts/s8_fixtures_lab.ps1`
- Python fixture runner: `scripts/s8_fixtures_lab.py`
- Flutter standalone entrypoint: `presentation/lib/s8_main.dart`

The S8 lab may use the repository as source code, but it does not start the main Criterivox application shell and has no runtime dependency on the Criterivox application UI.

## Covered scenarios

1. minimal evidence
2. temporal history
3. missing evidence
4. contradiction
5. uncertainty
6. human correction
7. integrity/tamper
8. tenant isolation

Fixture outputs are inspectable artifacts/reports. A fixture must never be interpreted as evidence about real-world truth.
