from __future__ import annotations

import base64
from pathlib import Path
from typing import Any

from criterivox.domain.data_foundation import ExtractionStatus, SourceType

MAX_FILES = 50
MAX_FILE_BYTES = 4 * 1024 * 1024
TEXT_EXTENSIONS = {
    '.txt', '.md', '.csv', '.tsv', '.json', '.yaml', '.yml', '.xml', '.html', '.htm',
    '.py', '.java', '.dart', '.js', '.ts', '.sql', '.log', '.rtf',
}


def collect_folder_sources(folder_path: str, *, collection_id: str | None = None) -> list[dict[str, Any]]:
    """Read actual material from a local folder for the trusted Python runtime.

    The frontend supplies only the selected local path. Python owns enumeration,
    size checks, decoding, and copying/processing decisions. A directory name is
    never treated as if it were its contents.
    """
    if not isinstance(folder_path, str) or not folder_path.strip():
        raise ValueError('A folder path is required.')
    root = Path(folder_path).expanduser().resolve(strict=True)
    if not root.is_dir():
        raise ValueError('The supplied folder path is not a directory.')

    files = sorted((p for p in root.rglob('*') if p.is_file() and not p.is_symlink()), key=lambda p: str(p).lower())
    if not files:
        raise ValueError('The selected folder contains no regular files.')
    if len(files) > MAX_FILES:
        raise ValueError(f'Folder contains more than the {MAX_FILES}-file intake limit.')

    sources: list[dict[str, Any]] = []
    for path in files:
        size = path.stat().st_size
        if size > MAX_FILE_BYTES:
            sources.append({
                'name': path.name,
                'source_type': SourceType.FILE.value,
                'channel': 'folder',
                'location': str(path),
                'parent_source_id': collection_id or root.name,
                'extraction_status': ExtractionStatus.FAILED.value,
                'error': 'File exceeds the 4 MB intake limit.',
            })
            continue
        raw = path.read_bytes()
        relative = str(path.relative_to(root))
        common = {
            'name': relative,
            'source_type': SourceType.FILE.value,
            'channel': 'folder',
            'location': str(path),
            'parent_source_id': collection_id or root.name,
        }
        if path.suffix.lower() in TEXT_EXTENSIONS:
            common.update({'content': raw.decode('utf-8', errors='replace'), 'extraction_status': ExtractionStatus.COMPLETED.value})
        else:
            common.update({
                'content_base64': base64.b64encode(raw).decode('ascii'),
                'extraction_status': ExtractionStatus.UNSUPPORTED.value,
                'error': f'No generic text extractor is registered for {path.suffix or "this binary format"}. The original bytes are preserved for a later adapter.',
            })
        sources.append(common)
    return sources


__all__ = ['collect_folder_sources']