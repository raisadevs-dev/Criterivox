# Criterivox Character Chat: Set 3 Operations Architecture

Set 3 adds a governed operational bridge to the existing character-chat backbone. Natural language is interpreted into a structured Command before any side effect can occur.

The boundary is:

Human → command interpretation → journey/task → capability registry → authorization → ActionContract → adapter → ExecutionResult → verification → S8 provenance/event lineage → updated state.

Characters remain presentation/orchestration boundaries. They do not own capabilities. The first real adapter is the bounded local filesystem MOVE operation. Calendar remains NOT_IMPLEMENTED until a real provider adapter exists.
