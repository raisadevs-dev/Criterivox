from __future__ import annotations

from typing import Any

from .bloom import bloom_controller
from .home03_models import output_renderer_model, ui_intent_model
from .home03_runtime import home03_runtime
from .syvax import syvax_engine


class Home03Services:
    """
    Runtime-facing service boundary for Home 03.

    SyvaxEngine owns safety, intent and route planning.
    Home03Services owns the handoff into Home03Runtime and presentation output.
    """

    def dispatch(
        self,
        message: str,
        task_id: str | None = None,
        plan: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        if not message.strip():
            raise ValueError("A non-empty request is required.")

        if plan is None:
            canonical = syvax_engine.prepare(
                message,
                task_id=task_id,
            )
            safety = canonical["safety"]
            if safety["status"] == "blocked":
                raise ValueError("Syvax safety preflight blocked the request.")
            plan = canonical["plan"]
            task_id = str(plan["task_id"])
        else:
            task_id = task_id or str(plan.get("task_id", ""))

        if not task_id:
            raise ValueError("A Syvax task id is required for runtime handoff.")

        intent = dict(plan.get("intent", {}))
        home03_runtime.start(
            task_id,
            {
                "intent": intent,
                "plan": plan,
                "source": "Syvax Gateway",
            },
        )

        intent_event = home03_runtime.emit(
            "INTENT_CLASSIFIED",
            task_id,
            prediction=intent,
            source="Syvax",
        )
        plan_event = home03_runtime.emit(
            "ROUTE_ACCEPTED",
            task_id,
            plan=plan,
            source="Syvax",
        )

        return {
            "task_id": task_id,
            "intent": intent,
            "plan": plan,
            "events": [intent_event, plan_event],
        }

    def render(
        self,
        text: str,
        intent: str = "general",
        mode: str = "",
    ) -> dict[str, Any]:
        result = output_renderer_model.predict(
            {
                "text": text,
                "intent": intent,
                "mode": mode,
            }
        )
        result["ui"] = ui_intent_model.predict(
            {
                "intent": intent,
                "text": text,
            }
        )
        return result

    def suspend(self, task_id: str, correction: str = ""):
        return home03_runtime.pause(task_id, correction)

    def resume(self, task_id: str):
        return home03_runtime.resume(task_id)

    def intervene(
        self,
        task_id: str,
        action: str,
        diff: dict[str, Any] | None = None,
    ):
        result = home03_runtime.approve(task_id, action, diff)
        return {
            **result,
            "decision_diff": diff or {},
            "resume_required": action.lower() in {"approve", "reject", "edit"},
        }

    def budget(self, task_id: str, home: str, tokens: int):
        return home03_runtime.allocate(task_id, home, tokens)

    def consume(self, task_id: str, home: str, cost: int):
        return home03_runtime.consume(task_id, home, cost)

    def ingest_runtime_event(self, event: dict[str, Any]):
        task_id = str(event.get("task_id", "unknown"))
        handoff = home03_runtime.emit(
            "RUNTIME_HANDOFF",
            task_id,
            source=event.get("source"),
            target=event.get("target"),
            payload=event.get("payload", {}),
            confidence=event.get("confidence"),
        )
        pollen = home03_runtime.ingest_pollen(handoff)
        score = float(
            event.get("confidence")
            if event.get("confidence") is not None
            else 1.0
        )
        evaluation = bloom_controller.evaluate(
            task_id,
            str(event.get("source", "")),
            str(event.get("target", "")),
            score,
            reason=str(event.get("event", "runtime")),
        )

        adaptation = None
        current = home03_runtime.workflows.get(task_id)
        try:
            if current and current.status != "paused":
                current_plan = current.plan or {}
                goal = str(
                    event.get("goal")
                    or event.get("payload", {}).get("goal")
                    or current_plan.get("intent", {}).get("goal")
                    or "continue task"
                )
                plan = syvax_engine.compile_plan(goal, task_id)
                adaptation = syvax_engine.revise_from_runtime(
                    plan,
                    event,
                )
                home03_runtime.emit(
                    "ROUTE_REVISED",
                    task_id,
                    source_event=handoff.get("event_id"),
                    candidate=adaptation["candidate"],
                )
        except Exception as exc:
            adaptation = {"error": str(exc)}

        return {
            "event": handoff,
            "pollen": pollen,
            "evaluation": evaluation,
            "adaptation": adaptation,
        }

    def restore(self, checkpoint_id: str):
        return home03_runtime.restore(checkpoint_id)

    def fork(self, checkpoint_id: str, name: str):
        return home03_runtime.fork(checkpoint_id, name)

    def snapshot(self):
        return home03_runtime.snapshot()


home03_services = Home03Services()
