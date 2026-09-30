# Criterivox Avishkaar Demo Package

This package defines the human-facing demo case boundary and report interchange format used to demonstrate one Criterivox task end-to-end.

## Principles

- A case describes what a human supplies, not the private input contract of the 15 characters.
- Multimedia inputs remain typed source materials and may be grouped in one case.
- Character execution remains owned by existing capability contracts.
- Character reports are preserved independently and can be filtered by character home.
- A task report composes authoritative artifact/report references rather than copying private reasoning.
- Text and visualization are two views over the same structured report sections.
- Human-readable IDs are presentation aliases; internal IDs remain authoritative for provenance.
- Evaluation expectations are checks, not answer keys or cheatsheets.

## Layout

- `schemas/`: JSON Schemas for cases, reports, report sections and visualization descriptors.
- `cases/`: reproducible Avishkaar task packages.
- `report-fixtures/`: presentation fixtures for character and combined reports.
- `evaluation/`: non-authoritative evaluation expectations.

## Supported source materials

The case boundary supports text, PDF, images/photos, CSV tables, multiple files, and mixed text + file cases. The runtime decides which extraction/normalization capabilities are available for each material; this package does not pretend that every modality is already fully understood.

## Report views

A report section can expose a semantic visualization descriptor. The visualization is derived from the same structured section/artifact references used by the text view. It is not a screenshot or a second source of truth.
## Standardized cases

The package currently defines CASE-001 through CASE-010 with the same execution contract: dynamic capability selection, preserved character reports, a combined task report, provenance, text/visualization views, and non-answer-key evaluation checks. CASE-010 exercises the complete 15-character capability surface.

The Human Residence case-report API accepts a `case_id`, so the presenter does not need to browse fixture folders or manually assemble internal inputs. The UI exposes the standardized case selector and preserves human challenge revisions separately from the original report.
