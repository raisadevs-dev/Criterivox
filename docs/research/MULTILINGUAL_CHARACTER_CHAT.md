# Criterivox Multilingual Character-Chat Layer

## Implemented scope
The unified character runtime now accepts English, Hindi, and Marathi input through one semantic runtime.

Pipeline:
Human language → language detection → language-specific phrase resources → canonical intent → capability discovery → unified runtime → localized response → Flutter presentation.

## Languages
- English (en)
- Hindi (hi)
- Marathi (mr)

## Supported behavior
- Devanagari script detection for Hindi/Marathi.
- Deterministic phrase-based intent recognition from external YAML resources.
- Common English operational terms remain accepted inside Hindi/Marathi input for practical code-switching.
- Canonical intents remain language-independent.
- Character routing remains language-independent.
- Runtime metadata reports detected language, response language, and language confidence.
- Authoritative current/next/no-record state responses are localized.
- Runtime boundary responses such as pause/resume/capability-unavailable are localized.
- Flutter chat chips change language based on the runtime response language.

## Explicit limitation
This is deterministic multilingual interaction, not unrestricted natural-language understanding or machine translation. It does not claim coverage of every Hindi/Marathi phrasing, dialect, transliteration, or arbitrary mixed-language sentence.

## Research relevance
The implementation preserves semantic invariance across languages: changing the human language should not create a separate agent runtime or alter the underlying capability/authorization semantics.

## Verification
Added:
- tests/test_multilingual_language.py
- tests/test_multilingual_runtime.py

Tests were added but require the repository Python environment and dependencies to be executed. No passing result is claimed here without execution.
