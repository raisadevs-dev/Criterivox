from __future__ import annotations

import csv
import io
import json
import zipfile
from typing import Any

from .repository import ResearchRepository


def build_json_export(repository: ResearchRepository) -> str:
    return json.dumps(
        {"format_version": "1.0", "tables": repository.export_tables()},
        indent=2,
        ensure_ascii=False,
        sort_keys=True,
        default=str,
    )


def build_csv_bundle(repository: ResearchRepository) -> bytes:
    tables = repository.export_tables()
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, rows in tables.items():
            stream = io.StringIO()
            if rows:
                fields = sorted({key for row in rows for key in row})
                writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
                writer.writeheader()
                for row in rows:
                    flattened = dict(row)
                    for key, value in list(flattened.items()):
                        if isinstance(value, (dict, list)):
                            flattened[key] = json.dumps(value, ensure_ascii=False, sort_keys=True, default=str)
                    writer.writerow(flattened)
            archive.writestr(f"{name}.csv", stream.getvalue())
    return output.getvalue()
