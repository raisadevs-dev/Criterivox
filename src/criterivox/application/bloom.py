from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from hashlib import sha256
from typing import Any, Literal

Mode = Literal["HITL", "HOTL"]

@dataclass(frozen=True)
class BloomPetal:
    home: str
    label: str
    status: str
    budget: int
    active: bool
    confidence: float | None

class BloomController:
    HOMES = {
        "Home 01": "Sandre / Data Foundation", "Home 02": "Dharen / Context", "Home 03": "Syvax / Gateway",
        "Home 04": "Vivren + Tarkis / Intelligence", "Home 05": "Pramon + Bodhex / Planning",
        "Home 06": "Medrus + Epistre + Veridat / Evidence", "Home 07": "Manis / Human Challenge", "Home 08": "Viveda / Knowledge",
    }
    def __init__(self) -> None:
        self.mode: Mode = "HITL"
        self.budgets = {home: 100 for home in self.HOMES}
        self.active: set[str] = set()
        self.seeds: list[dict[str, Any]] = []
        self.checkpoints: list[dict[str, Any]] = []
        self.traces: list[dict[str, Any]] = []

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def petals(self) -> list[dict[str, Any]]:
        return [asdict(BloomPetal(home, label, "ACTIVE" if home in self.active else "IDLE", self.budgets[home], home in self.active, None)) for home, label in self.HOMES.items()]

    def route_seed(self, source: str, destinations: list[str], payload: dict[str, Any]) -> dict[str, Any]:
        item = {"seed_id": f"seed-{len(self.seeds)+1:06d}", "source": source, "destinations": destinations, "payload": payload, "created_at": self._now()}
        self.seeds.append(item)
        self.active.update(destinations)
        return item

    def checkpoint(self, task_id: str, state: dict[str, Any]) -> dict[str, Any]:
        serialized = repr(sorted(state.items())).encode()
        item = {"checkpoint_id": f"bloom-cp-{len(self.checkpoints)+1:06d}", "task_id": task_id, "state_hash": sha256(serialized).hexdigest(), "state": state, "created_at": self._now()}
        self.checkpoints.append(item)
        return item

    def evaluate(self, task_id: str, source: str, target: str, score: float, *, reason: str = "") -> dict[str, Any]:
        score = max(0.0, min(1.0, float(score)))
        status = "ANOMALY" if score < .5 else ("REVIEW" if score < .75 else "OK")
        item = {"trace_id": f"bloom-trace-{len(self.traces)+1:06d}", "task_id": task_id, "source": source, "target": target, "score": score, "status": status, "reason": reason, "created_at": self._now()}
        self.traces.append(item)
        return item

    def set_budget(self, home: str, budget: int) -> int:
        if home not in self.HOMES:
            raise KeyError(f"Unknown Bloom home: {home}")
        self.budgets[home] = max(1, min(1000, int(budget)))
        return self.budgets[home]

    def set_mode(self, mode: Mode) -> str:
        if mode not in {"HITL", "HOTL"}:
            raise ValueError("Bloom mode must be HITL or HOTL.")
        self.mode = mode
        return mode

    def state(self) -> dict[str, Any]:
        return {"mode": self.mode, "petals": self.petals(), "active_homes": sorted(self.active), "seeds": self.seeds[-20:], "checkpoints": self.checkpoints[-20:], "traces": self.traces[-50:]}

bloom_controller = BloomController()
