from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CommunicationTruth:
    """Guards communication against unsupported progress claims."""

    completed: bool = False
    in_progress: bool = False
    warning: bool = False
    result_available: bool = False

    def status_message(self) -> str:
        """Return a truthful status description."""
        if self.warning:
            return "warning"

        if self.completed:
            return "completed"

        if self.in_progress:
            return "in_progress"

        return "waiting"

    def can_claim_progress(self) -> bool:
        """Return whether progress can truthfully be communicated."""
        return self.in_progress or self.completed

    def can_claim_completion(self) -> bool:
        """Return whether completion can truthfully be communicated."""
        return self.completed

    def can_claim_result(self) -> bool:
        """Return whether a result can truthfully be communicated."""
        return self.result_available

    def can_claim_warning(self) -> bool:
        """Return whether a warning can truthfully be communicated."""
        return self.warning