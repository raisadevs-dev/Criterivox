# CRITERIVOX — S8 UI/UX + Functional Specification Ledger

**Status:** AUTHORITATIVE FOR S8 PRESENTATION IMPLEMENTATION  
**Scope:** Four-room presentation, inspection and human intervention specification  
**Basis:** S8 Architecture Discussion + consolidated ledger material supplied by project owner

## Purpose

Functional and presentation specification for the four S8 rooms and their interaction boundaries. It describes what humans see, inspect and do, without redefining the computational architecture.

## Global UI Principles

- Exactly four S8 rooms: Medrus, Epistre, Veridat, and Presentation + Human Intervention/Collaboration.
- Underlying artifacts retain one identity. Rooms request and display role-relevant information particles rather than creating duplicate artifacts.
- Characters are presentation identities. Their visual/state behavior must reflect real capability state or retrieved material.
- Primary human visual language is an abstract “what happened” flowchart, with deeper inspection available on demand.
- Human intervention is artifact-grounded and permission-aware.
- No visual animation should imply computation that did not actually occur.
- Accessibility and comprehension are first-class requirements.

---

## Room 1 — Medrus

### Primary focus

Evidence, experimentation-related materials, knowledge retention, historical retrieval, temporal memory, evidence/artifact management and memory consolidation.

### Functional presentation

Display evidence/source/extraction particles, relevant historical states, retention/consolidation status and linked artifact relationships.

Provide pathways from retained material to its originating evidence/source and temporal history.

Do not present Epistre's full provenance dossier or Veridat's full verification workspace unless the human navigates to those views.

Character presentation should retrieve real Medrus capability/material state.

---

## Room 2 — Epistre

### Primary focus

Provenance, explanatory lineage, knowledge transformation, human-readable explanation, attribution, audit narrative and evidence dossiers.

### Functional presentation

Display transformation lineage, attribution relationships, explanation components and human-readable provenance narratives.

Allow inspection from result to provenance and provenance to supporting material.

Evidence dossiers are assembled dynamically from linked artifacts without duplicating underlying artifact identity.

Character presentation should retrieve real Epistre capability/material state.

---

## Room 3 — Veridat

### Primary focus

Empirical verification, fact grounding, source verification, contradiction detection, truth boundaries, temporal validity, integrity/security checks and uncertainty evaluation.

### Functional presentation

Display verification artifacts, competing evidence, conflict states, temporal validity/invalidation, integrity indicators and relevant uncertainty.

Allow comparison of competing evidence and navigation to supporting source/material.

Do not force unresolved contradictions into a single answer.

Character presentation should retrieve real Veridat capability/material state.

---

## Room 4 — Presentation + Human Intervention / Collaboration

### Primary focus

Cross-S8 overview, human-readable “what happened” flow, result summary, relevant evidence/provenance/verification inspection and human intervention.

### Functional presentation

Provide the primary abstract lifecycle/flowchart view.

Allow contextual navigation to Medrus, Epistre and Veridat when deeper specialist inspection is required.

Provide structured challenge, evidence/context submission, proposed alternative path and Debate Arena interaction.

Show original and revised states and their intervention/provenance relationship.

Provide explicit authorization UI for consequential actions.

Request additional evidence/context when required by an identified unknown or unresolved issue.

---

## Debate Arena

Debate is not theatrical character-to-character argument. It is a structured human ↔ system interaction grounded in artifacts and relationships.

Local layered NLP is the interaction mechanism; exact models/implementation are defined in the technology ledger and later implementation.

### Human can

- identify a divergence,
- inspect supporting material,
- challenge it,
- provide reasoning/evidence/context,
- propose an alternative,
- request re-evaluation.

### The system

- identifies affected artifacts/relationships,
- records the intervention,
- applies authorization rules,
- exposes revised state/lineage.

---

## Navigation and Information Density

Navigation is contextual and preserves the human's inspection context.

Each room exposes only role-defined information particles, preventing every room from becoming the same dashboard.

Information is layered:

1. overview,
2. artifact/path details,
3. deeper evidence/provenance/verification material.

Cross-room consistency means shared artifact identity and state remain consistent even when presentation differs.

---

## Functional Interaction Contract

The main interaction loop is:

`Inspect → trace → question → challenge → provide evidence/context → propose correction → authorize when required → re-evaluate → inspect revised state`

Challenge targets may be:

- artifacts,
- relationships,
- path points,
- supporting material.

### Unknown / uncertainty handling

Uncertainty and unknown states expose:

- reason,
- affected artifacts,
- possible resolution paths.

### Authorization

Consequential changes require explicit human authorization.

### History

Original and revised histories remain available.
