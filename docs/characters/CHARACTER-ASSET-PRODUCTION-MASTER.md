# Criterivox Character Asset Production Master

## Purpose

This is the living production task for converting Criterivox character placeholders into final authored character assets.

It is intentionally **not a blocker for functional sprints**. Character behavior, responsibilities, interaction, lifecycle states and application capabilities must be completed before final visual production is prioritized.

Whenever a new character is added to Criterivox, add that character to this same production task rather than creating a separate disconnected visual workflow.

## Production Principle

Automate deterministic and repetitive work aggressively. Keep human control over character identity, artistic direction, visual quality and final acceptance.

AI may assist with artwork generation, variation, cleanup, separation and preparation. It must not silently redefine the canonical Character Bible.

## Pipeline

```text
Canonical Character Bible
        ↓
Visual specification
        ↓
AI-assisted artwork preparation
        ↓
Piece/layer separation
        ↓
Cleanup + normalization
        ↓
Rig definition
        ↓
Bone hierarchy
        ↓
Attachments / weights
        ↓
Animation layers
        ↓
Facial expression
        ↓
Hair + clothing secondary motion
        ↓
Runtime validation
        ↓
Flutter presentation integration
        ↓
Accessibility validation
        ↓
Human visual acceptance
        ↓
Production-ready character
```

## 1. Character Visual Specification

For each character, verify the canonical identity before artwork begins.

Record:

- display name
- canonical role/responsibility
- residence
- relationship constraints
- visual personality
- silhouette
- face direction
- hair
- clothing
- accessories/signature elements
- palette
- age presentation where canon requires it
- accessibility considerations

Do not infer or change identity from an artwork reference alone.

## 2. Authored Artwork as Separate Pieces

Prepare artwork so the final character is not a single flattened image.

Preferred separable groups:

- head/face
- hair/back hair
- torso/clothing
- upper/lower arms
- hands
- upper/lower legs
- feet/shoes
- accessories
- foreground clothing
- background clothing
- facial features where practical
- secondary-motion elements

Use consistent layer names and dimensions.

## 3. Rigging

Create a reusable skeletal hierarchy appropriate for the selected runtime.

At minimum consider:

- root
- pelvis
- torso
- neck
- head
- shoulders
- upper arms
- forearms
- hands
- thighs
- shins
- feet

Add character-specific bones only when they have a real visual/animation purpose.

Use automated schema validation for missing parents, duplicate names, invalid references and malformed transforms.

## 4. Animation System

The production character must map semantic Criterivox lifecycle states to visual behavior:

- `IDLE`
- `RECEIVE`
- `WORK`
- `COMMUNICATE`
- `HANDOFF`
- `COMPLETE`
- `WARNING`

These states remain semantic application states. Animation is a presentation of the state, not the source of its meaning.

### WORK motion layers

```text
WORK
 ├─ breathing
 ├─ subtle weight shift
 ├─ head movement
 ├─ hand movement
 ├─ clothing response
 ├─ hair response
 └─ facial expression
```

Prefer reusable procedural/template layers where technically appropriate rather than manually duplicating equivalent animation logic for every character.

## 5. Runtime Decision Gate

Before adopting a third-party runtime, verify:

- supported platform
- web compatibility
- Flutter embedding requirements
- asset format
- runtime API
- animation blending capability
- performance characteristics
- licensing requirements
- redistribution requirements
- authoring-tool requirements
- maintenance status

Do not claim Spine or DragonBones compatibility unless the actual runtime and format have been verified.

The current Criterivox `criterivox-skeletal-v2` runtime is an original lightweight runtime contract. It must not be described as the commercial Spine runtime or DragonBonesJS runtime.

## 6. Automation Candidates

Automation should cover as much deterministic work as practical:

- create character package directories
- validate required files
- validate dimensions and formats
- enforce naming conventions
- generate/update manifests
- generate reusable rig templates
- generate animation-track templates
- validate bone hierarchy
- validate animation references
- detect missing assets
- detect unused assets
- generate package completeness reports
- run runtime loading tests
- run Flutter/web validation
- run CI checks

## 7. AI-Assisted Artwork Workflow

AI can be used as an assistant for:

1. visual concept exploration
2. character-sheet generation
3. controlled variations
4. background removal
5. cleanup assistance
6. piece separation assistance
7. reconstruction of missing visual details
8. texture preparation
9. reference-based consistency checks

Human review is required after each important transformation. AI-generated output is not automatically accepted as canonical character artwork.

## 8. Final Acceptance Checklist

A character is production-ready only when all applicable items are verified:

- [ ] Canonical identity verified
- [ ] Final visual specification approved
- [ ] Artwork pieces separated
- [ ] Naming convention validated
- [ ] Artwork dimensions/formats validated
- [ ] Skeleton created
- [ ] Attachments/weights validated
- [ ] Semantic animation states implemented
- [ ] WORK layered motion implemented
- [ ] Facial behavior implemented where applicable
- [ ] Hair/clothing secondary motion implemented where applicable
- [ ] Runtime loading verified
- [ ] Flutter presentation integration verified
- [ ] Reduced-motion behavior verified
- [ ] Semantic status text verified
- [ ] No legacy SVG dependency
- [ ] CI passes
- [ ] Human visual acceptance recorded

## 9. Research/Decision Traceability

Every significant production decision must be labeled as one of:

- `EVIDENCE`
- `DECISION`
- `ASSUMPTION`
- `HYPOTHESIS`
- `IMPLEMENTED`
- `FUTURE`
- `UNKNOWN`

Do not invent evidence, benchmarks, licensing permissions, standards, user-study results or claims of novelty.

## 10. Current Roster

Current characters requiring eventual final authored assets:

- Dharen
- Syvax
- Sandre
- Kaelen
- Anuka
- Vivren
- Tarkis

New characters must be appended here when introduced by the canonical Character Bible.

## 11. Current Sprint Boundary

S6 does **not** require final authored character artwork.

S6 does require:

- a stable character presentation boundary
- reserved avatar slots
- semantic state presentation
- accessible state information
- reduced-motion behavior
- character interaction capability
- a runtime contract capable of receiving future authored assets
- documentation of the future production pipeline

Final visual production is an end-stage task after functional character capabilities are stable.
