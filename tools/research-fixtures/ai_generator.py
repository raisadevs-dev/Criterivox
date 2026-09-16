#!/usr/bin/env python3
"""Optional OpenAI-assisted fixture material generator.

This helper creates synthetic fixture text only. It is deliberately separate from
S7 and must never be imported by the S7 reasoning runtime.
"""
from __future__ import annotations

import argparse
import json
import os
import urllib.request


def generate(prompt: str, model: str) -> str:
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        raise RuntimeError("OPENAI_API_KEY is required for AI-assisted generation.")
    body = json.dumps({
        "model": model,
        "input": (
            "Generate synthetic test material for the Criterivox Test Dataset & Fixture Laboratory. "
            "Do not present it as real evidence. Return JSON only. User request: " + prompt
        ),
    }).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/responses",
        data=body,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = json.load(response)
    return str(payload.get("output_text", "")).strip()


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate synthetic fixture material with OpenAI.")
    parser.add_argument("prompt", help="Synthetic scenario description")
    parser.add_argument("--model", default="gpt-5.6-mini")
    parser.add_argument("--output", default="tools/research-fixtures/generated/ai_synthetic.json")
    args = parser.parse_args()
    text = generate(args.prompt, args.model)
    parsed = json.loads(text)
    output = {"synthetic": True, "generator": "OpenAI-assisted fixture helper", "model": args.model, "material": parsed}
    with open(args.output, "w", encoding="utf-8") as handle:
        json.dump(output, handle, indent=2)
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
