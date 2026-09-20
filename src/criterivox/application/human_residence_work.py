from __future__ import annotations

import asyncio
import base64
import csv
import hashlib
import io
import json
import threading
import uuid
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from xml.etree import ElementTree as ET

from criterivox.application.state_runtime import state_runtime
from criterivox.character_backbone.language import interpret


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


class ResidenceWorkEngine:
    """Durable Human Residence work boundary.

    Residence work is a higher-level work item over StateRuntime. It persists
    human intent, confirmation, materials, checkpoints, ready items and human
    governance actions. It never treats conversational memory as authoritative.
    """

    STATUSES = {
        "DRAFT", "INTERPRETING", "AWAITING_CONFIRMATION", "CONFIRMED",
        "WORKING", "PAUSED", "BLOCKED", "READY_FOR_HUMAN", "UNDER_REVIEW",
        "CHALLENGED", "REWORKING", "DECISION_READY", "AUTHORIZED", "COMPLETED",
    }

    def __init__(
        self,
        path: str | Path = "data/runtime/human_residence_work.json",
        material_root: str | Path = "data/runtime/human_residence_materials",
    ) -> None:
        self.path = Path(path)
        self.material_root = Path(material_root)
        self._lock = threading.RLock()
        self._records: dict[str, dict[str, Any]] = {}
        self._tasks: dict[str, asyncio.Task] = {}
        self._load()

    def _load(self) -> None:
        with self._lock:
            if not self.path.exists():
                return
            try:
                raw = json.loads(self.path.read_text(encoding="utf-8"))
                self._records = {
                    str(k): dict(v) for k, v in raw.get("records", {}).items()
                }
            except (OSError, ValueError, TypeError):
                self._records = {}

    def _save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(
            json.dumps({"version": 2, "records": self._records}, indent=2, sort_keys=True, default=str),
            encoding="utf-8",
        )

    @staticmethod
    def _copy(value: dict[str, Any]) -> dict[str, Any]:
        return json.loads(json.dumps(value, default=str))

    def create_work(
        self,
        *,
        owner_id: str,
        room_id: str,
        goal: str,
        language: str = "en",
        requirements: list[str] | None = None,
        constraints: list[str] | None = None,
        expected_output: str = "strategies and options",
    ) -> dict[str, Any]:
        goal = str(goal).strip()
        if not goal:
            raise ValueError("goal is required")
        work_id = f"WORK-{uuid.uuid4().hex[:12].upper()}"
        task_id = f"RES-{uuid.uuid4().hex[:12].upper()}"
        record = {
            "work_id": work_id,
            "owner_id": str(owner_id).strip() or "human",
            "room_id": str(room_id).strip() or "private",
            "journey_id": None,
            "task_id": task_id,
            "goal": goal,
            "interpretation": None,
            "interpretation_status": "NOT_STARTED",
            "materials": [],
            "requirements": list(requirements or []),
            "constraints": list(constraints or []),
            "expected_output": expected_output,
            "workflow": [],
            "status": "DRAFT",
            "ready_items": [],
            "unread_for_human": False,
            "checkpoints": [],
            "artifacts": [],
            "decisions": [],
            "authorization": {"status": "NOT_REQUESTED"},
            "events": [],
            "language": language if language in {"en", "hi", "mr"} else "en",
            "created_at": now(),
            "updated_at": now(),
            "truth_class": "DETERMINISTIC_RUNTIME",
        }
        with self._lock:
            self._records[work_id] = record
            self._save()
        return self._copy(record)

    def get(self, work_id: str) -> dict[str, Any]:
        with self._lock:
            record = self._records.get(str(work_id))
            if record is None:
                raise KeyError("work_not_found")
            return self._copy(record)

    def list(self, owner_id: str, room_id: str | None = None) -> list[dict[str, Any]]:
        with self._lock:
            values = [
                r for r in self._records.values()
                if r.get("owner_id") == str(owner_id)
                and (room_id is None or r.get("room_id") == str(room_id))
            ]
            values.sort(key=lambda x: x.get("updated_at", ""), reverse=True)
            return [self._copy(v) for v in values]

    def _event(self, record: dict[str, Any], event_type: str, actor: str = "system", **data: Any) -> None:
        record["events"].append({
            "event_id": f"REV-{uuid.uuid4().hex[:12].upper()}",
            "type": event_type,
            "actor": actor,
            "timestamp": now(),
            **data,
        })
        record["updated_at"] = now()

    def _checkpoint(self, record: dict[str, Any], state: str, current: str, *, waiting_for: str | None = None) -> None:
        task_id = record["task_id"]
        completed = [x.get("step") for x in record["checkpoints"] if x.get("status") == "COMPLETED"]
        remaining = [
            x for x in ("interpretation", "material_review", "analysis", "strategy_review", "human_decision")
            if x not in completed and x != current
        ]
        cp = state_runtime.checkpoint(
            task_id,
            current_step=current,
            active_step=current if state not in {"READY_FOR_HUMAN", "COMPLETED"} else None,
            completed_steps=tuple(completed),
            remaining_steps=tuple(remaining),
            active_character="syvax" if current == "interpretation" else "dharen",
            active_capability="residence_work",
            state=state,
            waiting_for=waiting_for,
            artifact_refs=tuple(a.get("artifact_id") for a in record["artifacts"]),
        )
        record["checkpoints"].append({
            "checkpoint_id": cp.checkpoint_id,
            "step": current,
            "state": state,
            "status": "COMPLETED" if state in {"READY_FOR_HUMAN", "COMPLETED"} else "ACTIVE",
            "timestamp": cp.timestamp,
            "waiting_for": waiting_for,
        })

    @staticmethod
    def _extract_sections(text: str) -> tuple[list[str], list[str], str]:
        lines = [x.strip(" -•\t") for x in text.splitlines() if x.strip()]
        requirements: list[str] = []
        constraints: list[str] = []
        expected = ""
        for line in lines:
            low = line.casefold()
            if low.startswith(("requirement:", "requirements:", "need:", "needs:")):
                requirements.append(line.split(":", 1)[1].strip())
            elif low.startswith(("constraint:", "constraints:", "must not:", "avoid:")):
                constraints.append(line.split(":", 1)[1].strip())
            elif low.startswith(("output:", "expected:", "expected output:")):
                expected = line.split(":", 1)[1].strip()
        return requirements, constraints, expected

    def interpret_work(self, work_id: str) -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            record["status"] = "INTERPRETING"
            self._event(record, "INTERPRETATION_STARTED", "syvax")
            language = interpret(record["goal"])
            req, cons, expected = self._extract_sections(record["goal"])
            interpretation = {
                "interpretation_id": f"INT-{uuid.uuid4().hex[:10].upper()}",
                "raw_input": record["goal"],
                "language": language.detected_language,
                "goal": record["goal"],
                "requirements": list(dict.fromkeys([*record["requirements"], *req])),
                "constraints": list(dict.fromkeys([*record["constraints"], *cons])),
                "materials": [m["material_id"] for m in record["materials"]],
                "expected_output": expected or record["expected_output"],
                "intent": language.intent,
                "confidence": language.confidence,
                "ambiguities": [language.clarification] if language.ambiguous else [],
                "missing_information": [],
                "status": "AWAITING_CONFIRMATION",
            }
            if language.ambiguous:
                interpretation["missing_information"].append("Clarify the requested operation.")
            record["interpretation"] = interpretation
            record["interpretation_status"] = "AWAITING_CONFIRMATION"
            record["status"] = "AWAITING_CONFIRMATION"
            self._event(record, "INTERPRETATION_READY", "syvax", interpretation_id=interpretation["interpretation_id"])
            self._checkpoint(record, "AWAITING_CONFIRMATION", "interpretation", waiting_for="human_confirmation")
            self._save()
            return self._copy(record)

    def confirm(self, work_id: str, *, actor: str = "human", confirmed: bool = True, correction: str | None = None) -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            if record["status"] != "AWAITING_CONFIRMATION":
                raise ValueError("work_not_awaiting_confirmation")
            if not confirmed:
                record["interpretation_status"] = "REJECTED"
                record["status"] = "DRAFT"
                self._event(record, "INTERPRETATION_REJECTED", actor, correction=correction or "")
                self._save()
                return self._copy(record)
            if correction:
                record["goal"] = correction.strip()
                record["interpretation_status"] = "CORRECTED"
                record["interpretation"]["goal"] = correction.strip()
                record["interpretation"]["raw_input"] = correction.strip()
                self._event(record, "INTERPRETATION_CORRECTED", actor, correction=correction.strip())
            else:
                record["interpretation_status"] = "CONFIRMED"
                self._event(record, "INTERPRETATION_CONFIRMED", actor)
            record["status"] = "CONFIRMED"
            journey = state_runtime.ensure_journey(record["task_id"], record["goal"])
            record["journey_id"] = journey.journey_id
            self._event(record, "JOURNEY_CREATED", "system", journey_id=journey.journey_id)
            self._checkpoint(record, "CONFIRMED", "material_review")
            self._save()
        self.start_work(work_id)
        return self.get(work_id)

    def add_material(
        self,
        work_id: str,
        *,
        filename: str,
        content_type: str,
        data: bytes,
        original_language: str | None = None,
    ) -> dict[str, Any]:
        if not data:
            raise ValueError("material is empty")
        if len(data) > 16 * 1024 * 1024:
            raise ValueError("16 MB material limit exceeded")
        safe_name = Path(filename or "upload").name
        material_id = f"MAT-{uuid.uuid4().hex[:12].upper()}"
        digest = hashlib.sha256(data).hexdigest()
        suffix = Path(safe_name).suffix.lower() or ".bin"
        target = self.material_root / f"{material_id}{suffix}"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        extracted, extraction_status = self._extract(safe_name, content_type, data)
        material = {
            "material_id": material_id,
            "filename": safe_name,
            "content_type": content_type or "application/octet-stream",
            "size_bytes": len(data),
            "sha256": digest,
            "original_language": original_language,
            "extraction_status": extraction_status,
            "extracted_text": extracted,
            "storage_path": str(target),
            "created_at": now(),
            "provenance": {
                "source": "human_residence_upload",
                "original_retained": True,
            },
        }
        with self._lock:
            record = self._records[str(work_id)]
            record["materials"].append(material)
            self._event(record, "MATERIAL_RECEIVED", "human", material_id=material_id, filename=safe_name)
            self._event(record, "MATERIAL_EXTRACTED", "sandre", material_id=material_id, extraction_status=extraction_status)
            record["updated_at"] = now()
            self._save()
            return self._copy(material)

    @staticmethod
    def _extract(filename: str, content_type: str, data: bytes) -> tuple[str | None, str]:
        ext = Path(filename).suffix.lower()
        text_ext = {".txt", ".md", ".markdown", ".csv", ".json", ".yaml", ".yml", ".xml", ".log"}
        if ext in text_ext or content_type.startswith("text/"):
            try:
                text = data.decode("utf-8")
                if ext == ".json":
                    obj = json.loads(text)
                    text = json.dumps(obj, indent=2, ensure_ascii=False)
                elif ext == ".csv":
                    rows = list(csv.reader(io.StringIO(text)))
                    text = "\n".join(" | ".join(row) for row in rows[:500])
                return text[:100_000], "EXTRACTED"
            except (UnicodeDecodeError, ValueError, csv.Error):
                return None, "EXTRACTION_FAILED"
        if ext == ".docx" or content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            try:
                with zipfile.ZipFile(io.BytesIO(data)) as archive:
                    xml = archive.read("word/document.xml")
                root = ET.fromstring(xml)
                ns = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
                text = "\n".join(
                    "".join(node.itertext()).strip()
                    for node in root.iter()
                    if node.tag == ns + "p"
                )
                return text[:100_000], "EXTRACTED"
            except (zipfile.BadZipFile, KeyError, ET.ParseError):
                return None, "EXTRACTION_FAILED"
        if content_type.startswith("image/") or ext in {".png", ".jpg", ".jpeg", ".webp", ".gif"}:
            return None, "ORIGINAL_RETAINED_VISUAL_EXTRACTION_UNAVAILABLE"
        return None, "ORIGINAL_RETAINED_NO_TEXT_EXTRACTOR"

    def start_work(self, work_id: str) -> None:
        if work_id in self._tasks and not self._tasks[work_id].done():
            return
        self._tasks[work_id] = asyncio.create_task(self._run(work_id))

    async def _run(self, work_id: str) -> None:
        stages = [
            ("material_review", "MATERIAL_REVIEW", "Sandre", 0.05),
            ("analysis", "ANALYSIS", "Dharen", 0.08),
            ("strategy_review", "STRATEGY_PREPARATION", "Pramon", 0.08),
        ]
        for step, event_type, actor, delay in stages:
            with self._lock:
                record = self._records.get(work_id)
                if record is None or record["status"] in {"PAUSED", "COMPLETED"}:
                    return
                record["status"] = "WORKING"
                self._event(record, "STEP_STARTED", actor, step=step)
                self._checkpoint(record, "WORKING", step)
                self._save()
            await asyncio.sleep(delay)
            with self._lock:
                record = self._records.get(work_id)
                if record is None:
                    return
                for cp in reversed(record["checkpoints"]):
                    if cp["step"] == step and cp["status"] == "ACTIVE":
                        cp["status"] = "COMPLETED"
                        break
                self._event(record, "STEP_COMPLETED", actor, step=step)
                self._save()

        with self._lock:
            record = self._records.get(work_id)
            if record is None:
                return
            materials = record["materials"]
            extracted = [m for m in materials if m.get("extracted_text")]
            material_summary = [
                {
                    "material_id": m["material_id"],
                    "filename": m["filename"],
                    "extraction_status": m["extraction_status"],
                    "sha256": m["sha256"],
                }
                for m in materials
            ]
            options = [
                {
                    "option_id": "OPT-1",
                    "title": "Evidence-first review",
                    "description": "Prioritize extracted source material and resolve missing evidence before committing to a strategy.",
                    "basis": [m["material_id"] for m in extracted],
                    "status": "PREPARED",
                },
                {
                    "option_id": "OPT-2",
                    "title": "Constraint-first planning",
                    "description": "Start from the recorded requirements and constraints, then compare feasible paths.",
                    "basis": [record["interpretation"]["interpretation_id"]],
                    "status": "PREPARED",
                },
                {
                    "option_id": "OPT-3",
                    "title": "Counterfactual comparison",
                    "description": "Prepare competing paths and expose assumptions that would change the choice.",
                    "basis": [record["interpretation"]["interpretation_id"]],
                    "status": "PREPARED",
                },
            ]
            artifact = {
                "artifact_id": f"ART-{uuid.uuid4().hex[:12].upper()}",
                "type": "strategy_options",
                "status": "PREPARED",
                "truth_class": "DETERMINISTIC_SYNTHESIS",
                "materials": material_summary,
                "options": options,
                "limitations": [
                    "No unsupported visual/OCR interpretation was claimed for images.",
                    "Options are deterministic workflow scaffolding, not an autonomous decision.",
                    "Human review and challenge remain required before a decision or action.",
                ],
                "created_at": now(),
            }
            record["artifacts"].append(artifact)
            record["ready_items"] = [{
                "ready_id": f"READY-{uuid.uuid4().hex[:10].upper()}",
                "type": "STRATEGY_OPTIONS",
                "title": "Strategy options are ready for human review.",
                "artifact_id": artifact["artifact_id"],
                "take_required": True,
            }]
            record["unread_for_human"] = True
            record["status"] = "READY_FOR_HUMAN"
            self._event(record, "STRATEGY_CREATED", "pramon", artifact_id=artifact["artifact_id"])
            self._event(record, "WORK_READY", "system", artifact_id=artifact["artifact_id"])
            self._checkpoint(record, "READY_FOR_HUMAN", "strategy_review")
            self._save()

    def take(self, work_id: str, actor: str = "human") -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            if record["status"] != "READY_FOR_HUMAN":
                raise ValueError("work_not_ready_for_human")
            record["status"] = "UNDER_REVIEW"
            record["unread_for_human"] = False
            self._event(record, "WORK_TAKEN", actor)
            self._save()
            return self._copy(record)

    def challenge(self, work_id: str, *, actor: str = "human", challenge_type: str, text: str) -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            if record["status"] not in {"UNDER_REVIEW", "READY_FOR_HUMAN", "DECISION_READY"}:
                raise ValueError("work_not_reviewable")
            challenge = {
                "challenge_id": f"CH-{uuid.uuid4().hex[:10].upper()}",
                "type": challenge_type,
                "text": text,
                "actor": actor,
                "timestamp": now(),
                "status": "RECORDED",
            }
            record.setdefault("challenges", []).append(challenge)
            record["status"] = "CHALLENGED"
            self._event(record, "CHALLENGE_RAISED", actor, challenge_id=challenge["challenge_id"])
            self._save()
        self._schedule_rework(work_id)
        return self.get(work_id)

    def _schedule_rework(self, work_id: str) -> None:
        with self._lock:
            record = self._records[work_id]
            record["status"] = "REWORKING"
            self._event(record, "REWORK_STARTED", "system")
            self._save()
        self.start_work(work_id)

    def decide(self, work_id: str, *, actor: str = "human", option_id: str, modification: str | None = None) -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            if record["status"] not in {"UNDER_REVIEW", "READY_FOR_HUMAN"}:
                raise ValueError("work_not_reviewable")
            decision = {
                "decision_id": f"DEC-{uuid.uuid4().hex[:10].upper()}",
                "selected_option": option_id,
                "modification": modification,
                "actor": actor,
                "timestamp": now(),
                "authority": "HUMAN",
                "status": "RECORDED",
            }
            record["decisions"].append(decision)
            record["status"] = "DECISION_READY"
            self._event(record, "DECISION_CREATED", actor, decision_id=decision["decision_id"])
            self._save()
            return self._copy(record)

    def authorize(self, work_id: str, *, actor: str = "human") -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            if record["status"] != "DECISION_READY":
                raise ValueError("decision_not_ready")
            record["authorization"] = {"status": "AUTHORIZED", "actor": actor, "timestamp": now()}
            record["status"] = "AUTHORIZED"
            self._event(record, "ACTION_AUTHORIZED", actor)
            self._save()
            return self._copy(record)

    def outcome(self, work_id: str, *, actor: str = "human", observed: str, verified: bool = False) -> dict[str, Any]:
        with self._lock:
            record = self._records[str(work_id)]
            result = {
                "outcome_id": f"OUT-{uuid.uuid4().hex[:10].upper()}",
                "planned": record["expected_output"],
                "observed": observed,
                "verified": bool(verified),
                "status": "VERIFIED" if verified else "REPORTED",
                "actor": actor,
                "timestamp": now(),
            }
            record.setdefault("outcomes", []).append(result)
            record["status"] = "COMPLETED" if verified else record["status"]
            self._event(record, "OUTCOME_RECORDED", actor, outcome_id=result["outcome_id"], status=result["status"])
            self._save()
            return self._copy(record)


residence_work = ResidenceWorkEngine()
