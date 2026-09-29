# Criterivox S8 UI/UX Backlog Closure

Date: 2026-09-17
Branch: `s8-xai-evidence-bureau`

## Basis

This closure compares the S8 implementation with the authoritative S8 UI/UX ledger, the established S7 Reasoning Research Bureau UI principles, and the supplied S8 visual references. S7 requires an independently usable research environment, progressive information density, inspectable analytical structures, human challenge/intervention, state-grounded presentation, and character presentation separated from computation. S8 applies those principles to its four-room Evidence/XAI boundary.

## Closed implementation backlog

- [x] Independent S8 Home and four-room navigation
- [x] Shared artifact presentation model
- [x] Overview → detail inspection hierarchy
- [x] Artifact inspector with status/source/parents/integrity/temporal/uncertainty fields
- [x] Evidence → verification → explanation → human-action flow visualization
- [x] Medrus evidence/memory/temporal presentation
- [x] Epistre provenance/explanation presentation
- [x] Veridat verification/contradiction/uncertainty presentation
- [x] Presentation room and Evidence Challenge Arena
- [x] Human-provided context and proposed alternative capture
- [x] Explicit authorization control in the human-facing intervention surface
- [x] Original/revised lineage presentation contract
- [x] State-driven character presentation contract for Medrus, Epistre, and Veridat
- [x] Character profile card opens when the human taps a character
- [x] Character profile remains attached to the character presentation and is draggable
- [x] Medrus reference wardrobe rendered in Flutter: layered light coat, dark fitted inner suit/bodysuit, neck cloth, glasses, research pendant, wrist device and evidence slate
- [x] Epistre reference wardrobe rendered in Flutter: layered scholarly coat, dark inner suit, neck stole, glasses, hair ornament, compass/star pendant and knowledge tablet
- [x] Veridat reference wardrobe rendered in Flutter: refined light verification coat, dark fitted inner suit/bodysuit, high neck cloth, glasses, verification insignia, wrist scanner and evidence slate
- [x] Character-specific tools/accessories are presentation elements only and do not perform computation
- [x] Standalone/synthetic boundary is visibly identified
- [x] No character is treated as computational truth

## Character reference interpretation

The supplied Medrus, Epistre and Veridat sheets are treated as visual specifications, not external image assets. Flutter draws the character-detail overlays and costume/accessory cues programmatically on top of the canonical Criterivox character runtime. The implementation preserves the referenced distinctions in role, attire, neck pieces, insignia/pendants, glasses, tools and active-state equipment without importing image files.

## Deliberate boundaries

- No external character image assets are required for the S8 implementation. The reference sheets are translated into Flutter-rendered presentation details.
- The presentation demo snapshot is explicitly synthetic. It is not production evidence and must not be represented as live truth.
- The Flutter presentation layer does not perform verification or re-evaluation. It structures human interaction and renders authoritative state.
- S8 remains independent from the main Criterivox shell and does not depend on Syvax.

## Research/architecture gates already implemented separately

Artifact contracts, persistence, policy/isolation, interventions, temporal retrieval, memory consolidation, downstream impact calculation, provenance/verification/uncertainty/contradiction artifacts, local layered NLP, intake contracts, fixtures, launcher, and evaluation instrumentation are implemented in the S8 backend and acceptance surface.

## Remaining work is not a baseline UI backlog defect

The following are intentionally future research/integration work rather than missing S8 baseline UI:

1. actual S7↔S8 production handoff once both contract surfaces are finalized;
2. production live-data adapter;
3. empirical human-understanding study with collected participant data;
4. advanced graph rendering package selection and performance tuning.

No unsupported confidence threshold is introduced by this document.
