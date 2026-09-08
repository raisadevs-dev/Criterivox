from __future__ import annotations
import base64,hashlib,shutil
from pathlib import Path
from typing import Any
from criterivox.domain.data_foundation import ExtractionStatus,SourceType
MAX_FILES=50;MAX_FILE_BYTES=4*1024*1024
TEXT_EXTENSIONS={'.txt','.md','.csv','.tsv','.json','.yaml','.yml','.xml','.html','.htm','.py','.java','.dart','.js','.ts','.sql','.log','.rtf'}

def collect_folder_sources(folder_path:str,*,collection_id:str|None=None)->list[dict[str,Any]]:
    if not isinstance(folder_path,str) or not folder_path.strip():raise ValueError('A folder path is required.')
    root=Path(folder_path).expanduser().resolve(strict=True)
    if not root.is_dir():raise ValueError('The supplied folder path is not a directory.')
    files=sorted((p for p in root.rglob('*') if p.is_file() and not p.is_symlink()),key=lambda p:str(p).lower())
    if not files:raise ValueError('The selected folder contains no regular files.')
    if len(files)>MAX_FILES:raise ValueError(f'Folder contains more than the {MAX_FILES}-file intake limit.')
    collection_key=collection_id or root.name
    safe_key=hashlib.sha256(str(collection_key).encode('utf-8')).hexdigest()[:16]
    storage_root=Path('data')/'s5_materials'/safe_key
    storage_root.mkdir(parents=True,exist_ok=True)
    sources=[]
    for path in files:
        size=path.stat().st_size;relative=path.relative_to(root);stored=storage_root/relative
        if size>MAX_FILE_BYTES:
            sources.append({'name':str(relative),'source_type':SourceType.FILE.value,'channel':'folder','location':str(path),'stored_location':str(stored),'parent_source_id':collection_key,'extraction_status':ExtractionStatus.FAILED.value,'error':'File exceeds the 4 MB intake limit.'});continue
        stored.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,stored);raw=stored.read_bytes()
        common={'name':str(relative),'source_type':SourceType.FILE.value,'channel':'folder','location':str(path),'stored_location':str(stored),'parent_source_id':collection_key}
        if path.suffix.lower() in TEXT_EXTENSIONS:common.update({'content':raw.decode('utf-8',errors='replace'),'extraction_status':ExtractionStatus.COMPLETED.value})
        else:common.update({'content_base64':base64.b64encode(raw).decode('ascii'),'extraction_status':ExtractionStatus.UNSUPPORTED.value,'error':f'No generic text extractor is registered for {path.suffix or "this binary format"}. The original bytes are preserved for a later adapter.'})
        sources.append(common)
    return sources
__all__=['collect_folder_sources']