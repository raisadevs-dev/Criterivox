# ADR-009 — S6 Context, Civilization and Human Residence Boundary

**Status:** Accepted  
**Scope:** Sprint 6 refinement of earlier Bloom/Syvax work and S5→S6 integration.

## Context

Criterivox evolved from earlier character/home and presentation work into a computational environment containing specialised responsibilities. S5 established an authoritative data foundation. S6 now requires persistent contextual computation while humans remain able to inspect and challenge the system.

Earlier Bloom and Syvax decisions must be reused and refined without making presentation the computational authority.

## Decision

Criterivox will maintain two distinct but connected environments:

- **Criterivox Civilization:** specialised computational workers/homes and their domain interactions.
- **Human Residence:** the human-side decision environment.

**Syvax** is the interaction/gateway/orchestration/presentation boundary.  
**Bloom** is the capability-discovery/world surface.  
**Dharen** is the computational Context Master.  
**Anuka** is the conditionally activated Context Adaptor.  
**Sandre** remains upstream Data Stewardship over the S5 foundation.  
**Kaelen** remains responsible for build/experimentation work and short-lived scratchpad activity.

Characters remain representations of computational responsibilities and are not synonymous with their underlying models.

## Human boundary

Humans retain goal-setting, challenge, accept/reject and real-world action authority. Results can return to Criterivox as new evidence/context through the provenance-aware data pipeline.

## Consequences

- Presentation can evolve without redefining computational authority.
- S5 remains reusable after sprint closure.
- Earlier Bloom/Syvax work can be pulled into later integration without violating sprint boundaries.
- S6 testing can verify the complete human → gateway → context → worker → human loop.
- Learned components remain below deterministic safety/scope rules.

## Rejected alternatives

- Treating every character as an independent chatbot/model.
- Making Bloom the source of computational truth.
- Making Syvax the intelligence authority.
- Treating Human Residence as another autonomous worker home.
- Freezing S5/Bloom/Syvax permanently after their original sprint.
