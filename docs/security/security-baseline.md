# Criterivox Security Baseline

## Purpose

This document defines the initial security principles for Criterivox development.

The baseline will evolve as the system gains real data, APIs, authentication, integrations, and synchronization capabilities.

## Initial Principles

### 1. Secrets must never be committed

API keys, passwords, tokens, private credentials, and other secrets must not be stored in source code or committed to Git.

Environment-specific secrets belong outside the repository.

### 2. User input is untrusted

Any data originating from users, imported files, external platforms, APIs, or future integrations must be treated as untrusted input.

Input must be validated at appropriate boundaries.

### 3. Missing data is not automatically zero

The system must preserve the distinction between:

- missing
- unavailable
- zero
- unknown
- not applicable

This is both a data-integrity and research-validity requirement.

### 4. Do not expose sensitive information through logs

Logs must not contain:

- passwords
- API keys
- authentication tokens
- unnecessary personal information
- private platform data

### 5. Least privilege

Components should receive only the permissions and data they require.

### 6. Fail safely

Errors should not expose:

- secrets
- internal credentials
- unnecessary filesystem information
- sensitive user data
- implementation details that could assist misuse

### 7. Dependencies must be controlled

Dependencies should be explicitly declared and periodically reviewed.

Unnecessary dependencies should not be introduced.

### 8. Data provenance matters

Data used for analysis should preserve its origin where appropriate.

The system should distinguish between:

- user-provided data
- external/platform data
- system-derived data

### 9. Security is incremental

Security requirements will evolve as Criterivox introduces:

- APIs
- external integrations
- authentication
- persistence
- synchronization
- multi-device access
- cloud deployment

Security mechanisms should be introduced when the corresponding threat surface exists.

## Current Threat Assumptions

At S0, Criterivox is a local development application.

The system does not yet implement:

- user authentication
- remote API access
- multi-user authorization
- cloud synchronization
- external social-media credentials
- production deployment

These are intentionally deferred.

## Review Requirement

Security considerations must be reviewed when introducing any feature that changes the application's attack surface or data exposure.