# Criterivox — Final Integrated Research Prototype State

This document is the current implementation authority for the end-of-project research prototype.

## 1. System boundary

Criterivox is a context-aware, evidence-grounded and inspectable decision-support research prototype. Human authority remains explicit.

```
Human Goal / Problem
        ↓
Human Residence
        ↓
Natural Human Input
        ↓
Language + Meaning Intake
        ↓
Data / Context / Evidence
        ↓
Inspectable Reasoning
        ↓
Human Challenge / Confirmation
        ↓
Decision / Authorized Action
        ↓
Real-world Result
        ↓
Outcome / Knowledge / Future Context
```

## 2. Research instrumentation

Criterivox now contains a dedicated research-instrumentation boundary.

```
Criterivox interaction
        ↓
Research Instrumentation
        ├── participant identity
        ├── consent record
        ├── session
        ├── structured interaction events
        └── optional outcomes
                 ↓
        SQLite V1 research store
```

The initial implementation is local SQLite. The application boundary is intentionally repository-shaped so a future server-backed research database can replace SQLite without changing the event vocabulary.

## 3. Data classes

### Operational telemetry

Operational events may be recorded without research participation. They are used to understand runtime behavior and remain separate from participant research claims.

### Research data

Research events require explicit research-data authorization.

### Identifiable research data

Participant name and email are stored as participant identity only when the participant chooses research participation. They are not mixed into every event payload.

### Raw human text

Original human messages are a separate consent category. Structured interpretation can be retained for research without automatically retaining the original message. Raw text is rejected by the research API unless raw-text consent is enabled.

### Outcome follow-up

Participants can separately allow later reporting of whether the task succeeded, how helpful Criterivox was, what should be improved, and an optional outcome summary.

## 4. Language-aware research trace

Human input preserves original expression, detected language/script profile, code-mixing/transliteration information, normalized meaning, interaction intent, semantic summary and interpretation uncertainty where available.

```
Human input
    ↓
What Criterivox understood
    ↓
Human confirmation / correction
    ↓
Continue
    │
    └── no response for 60 seconds
             ↓
       continue with recorded interpretation
       and mark it UNCONFIRMED_TIMEOUT
```

The timeout prevents unattended work from being blocked indefinitely while preserving the fact that the interpretation was not confirmed.

## 5. Research-question evidence

The instrumentation layer derives descriptive evidence from recorded interaction sequences rather than manually manufacturing answers.

Examples include challenge frequency and targets, interpretation confirmation/correction rates, human intervention sequences, hypothesis/challenge/decision transitions, outcome reports, reported helpfulness, improvement requests, and context/language patterns.

Aggregates are evidence for analysis. They are not automatically causal findings.

## 6. Privacy boundary

Research instrumentation never requires passwords, password hashes, authentication tokens, API credentials, or secrets.

The Human Residence authentication store remains responsible for authentication. Research instrumentation receives only the participant information needed for the selected research scope.

Future server deployment must preserve the same separation and add appropriate authentication, access control, retention, deletion and institutional research governance.

## 7. Current storage

V1 uses separate Human Residence and Research Instrumentation SQLite stores.

Future deployment can use an authenticated research API and server research repository while retaining the same research event model.

## 8. What remains historical

Sprint plans, exploratory architecture notes and superseded implementation plans are historical records, not current implementation authority.

The proposal and research history remain valuable because they document how the research direction evolved. They should not be read as proof that every planned capability was implemented.

For current implementation behavior, use this document and the code/tests.

## 9. Evidence vocabulary

The repository continues to distinguish IMPLEMENTED, VERIFIED, RESEARCH QUESTION, FUTURE and UNKNOWN.

Architecture and telemetry are not automatically empirical findings.