from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
import json
import math
from typing import Any


@dataclass(frozen=True, slots=True)
class VectorEncoding:
    vector: tuple[float, ...]
    dimension: int
    encoder: str = "deterministic-feature-hash-v1"


class VectorEncoder:
    """Local deterministic vector encoding, not a semantic embedding model."""

    def __init__(self, dimension: int = 32) -> None:
        if dimension < 4:
            raise ValueError("Vector dimension must be at least 4.")
        self.dimension = dimension

    def encode(self, row: dict[str, Any]) -> VectorEncoding:
        vector = [0.0] * self.dimension
        for key in sorted(row):
            value = row[key]
            token = f"{key}={value!r}"
            digest = sha256(token.encode("utf-8")).digest()
            bucket = int.from_bytes(digest[:4], "big") % self.dimension
            sign = 1.0 if digest[4] & 1 else -1.0
            magnitude = self._magnitude(value)
            vector[bucket] += sign * magnitude
        norm = math.sqrt(sum(value * value for value in vector))
        if norm:
            vector = [round(value / norm, 8) for value in vector]
        return VectorEncoding(tuple(vector), self.dimension)

    @staticmethod
    def _magnitude(value: Any) -> float:
        if isinstance(value, bool):
            return 1.0 if value else -1.0
        if isinstance(value, (int, float)):
            return float(value) if math.isfinite(float(value)) else 0.0
        if value is None:
            return 0.0
        return 1.0


class VectorLakehousePackageBuilder:
    """Builds a local, inspectable vectorized package manifest.

    This is a package artifact, not a connector to a distributed lakehouse.
    """

    def __init__(self, encoder: VectorEncoder | None = None) -> None:
        self.encoder = encoder or VectorEncoder()

    def build(
        self,
        rows: list[dict[str, Any]],
        schema: list[str] | None = None,
    ) -> dict[str, Any]:
        schema = schema or sorted({key for row in rows for key in row})
        encoded = [self.encoder.encode(row) for row in rows]
        manifest = {
            "kind": "kaelen.vectorized_lakehouse_package",
            "package_version": "1",
            "storage": "local-inspectable-artifact",
            "schema": schema,
            "row_count": len(rows),
            "dimension": self.encoder.dimension,
            "encoder": encoded[0].encoder if encoded else "deterministic-feature-hash-v1",
            "vectors": [list(item.vector) for item in encoded],
        }
        manifest["content_hash"] = sha256(
            json.dumps(manifest, sort_keys=True, default=str).encode("utf-8")
        ).hexdigest()
        return manifest
