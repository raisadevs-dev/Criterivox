# S8 Fixtures Lab

These are deterministic acceptance fixtures for the **standalone S8 Evidence Research Bureau**.

They are synthetic stimuli, not Criterivox application data, model training data, production knowledge, or real-world evidence.

## Boundary

- Launcher: `s8-start-evidence-research-bureau.ps1`
- Python fixture runner: `scripts/s8_fixtures_lab.py`
- Flutter standalone entrypoint: `presentation/lib/s8_main.dart`
- Upstream contract: `criterivox.internal.s8.intake.v1`

The lab simulates Criterivox members communicating with S8 in structured internal language. The bureau then turns accepted material into authoritative S8 artifacts. The layers remain separate:

`synthetic member message → S8 intake → epistemic artifacts/events → human-facing presentation`

The S8 lab never starts the main Criterivox application shell and has no runtime dependency on its UI.

## Covered scenarios

1. member/internal-language intake
2. temporal material
3. insufficient evidence
4. contradiction
5. uncertainty
6. human correction stimulus
7. integrity/tamper

Fixture outputs are inspectable reports. Synthetic inputs must remain explicitly marked as synthetic.
