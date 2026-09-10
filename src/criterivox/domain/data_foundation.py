from __future__ import annotations
from dataclasses import asdict,dataclass,field
from datetime import datetime,timezone
from enum import Enum
from typing import Any
from uuid import uuid4
class SourceType(str,Enum):
 TEXT='text';FILE='file';DATASET='dataset';FOLDER_COLLECTION='folder_collection';REFERENCE='reference';CHAT='chat'
class ExtractionStatus(str,Enum):
 PENDING='pending';COMPLETED='completed';PARTIAL='partial';UNSUPPORTED='unsupported';FAILED='failed'
class ConfirmationStatus(str,Enum):
 UNCERTAIN='uncertain';SYSTEM_EXTRACTED='system-extracted';USER_CONFIRMED='user-confirmed';USER_CORRECTED='user-corrected';USER_EXCLUDED='user-excluded'
class Missingness(str,Enum):
 UNKNOWN='unknown';NOT_PROVIDED='not_provided';NOT_APPLICABLE='not_applicable';NOT_MEASURED='not_measured';NOT_OBSERVED='not_observed';WITHHELD='withheld';UNAVAILABLE='unavailable';EXTRACTION_FAILED='extraction_failed'
@dataclass(frozen=True,slots=True)
class Provenance:
 source_id:str;source_type:SourceType;source_name:str;parent_source_id:str|None=None;created_at:str=field(default_factory=lambda:datetime.now(timezone.utc).isoformat());derived_from:tuple[str,...]=()
@dataclass(frozen=True,slots=True)
class SourceRecord:
 source_id:str;name:str;source_type:SourceType;channel:str;provided_at:str;location:str|None=None;parent_source_id:str|None=None;raw_content:str|None=None;raw_content_base64:str|None=None;stored_location:str|None=None;extraction_status:ExtractionStatus=ExtractionStatus.PENDING;processing_status:str='received';error:str|None=None;provenance:Provenance|None=None
@dataclass(frozen=True,slots=True)
class CandidateInformation:
 candidate_id:str;value:Any;source_id:str;field:str|None=None;confidence:float=1.0;confirmation_status:ConfirmationStatus=ConfirmationStatus.SYSTEM_EXTRACTED;uncertainty:str|None=None;provenance:Provenance|None=None
@dataclass(frozen=True,slots=True)
class Transformation:
 transformation_id:str;original:Any;transformation:str;result:Any;reason:str;provenance:Provenance
@dataclass(frozen=True,slots=True)
class Anomaly:
 anomaly_id:str;source_id:str;field:str;value:Any;detector:str;reason:str;flagged:bool=True
@dataclass(frozen=True,slots=True)
class DataProfile:
 record_count:int;field_count:int;field_types:dict[str,str];missingness:dict[str,int];uniqueness:dict[str,int];duplicate_candidates:int;distributions:dict[str,dict[str,float]];suspicious_values:tuple[str,...]=();source_coverage:dict[str,int]=field(default_factory=dict);extraction_confidence:float=1.0
@dataclass(frozen=True,slots=True)
class QualityMetadata:
 validation_errors:tuple[str,...]=();validation_warnings:tuple[str,...]=();anomaly_count:int=0;missing_count:int=0;duplicate_count:int=0
@dataclass(frozen=True,slots=True)
class DataFoundation:
 foundation_id:str;created_at:str;sources:tuple[SourceRecord,...]=();candidates:tuple[CandidateInformation,...]=();supplied_context:dict[str,Any]=field(default_factory=dict);derived_information:dict[str,Any]=field(default_factory=dict);raw_data:tuple[dict[str,Any],...]=();normalized_data:tuple[dict[str,Any],...]=();canonical_data:tuple[dict[str,Any],...]=();profile:DataProfile|None=None;quality:QualityMetadata=field(default_factory=QualityMetadata);missingness:dict[str,Missingness]=field(default_factory=dict);anomalies:tuple[Anomaly,...]=();transformations:tuple[Transformation,...]=();confirmation_status:ConfirmationStatus=ConfirmationStatus.UNCERTAIN;handoff_ready:bool=False
 @classmethod
 def create(cls)->'DataFoundation':return cls(foundation_id=f'DF-{uuid4().hex[:10].upper()}',created_at=datetime.now(timezone.utc).isoformat())
 def to_dict(self)->dict[str,Any]:return asdict(self)
@dataclass(frozen=True,slots=True)
class DataHandoff:
 handoff_id:str;foundation_id:str;recipient:str;created_at:str;canonical_data:tuple[dict[str,Any],...];provenance:tuple[Provenance,...];supplied_context:dict[str,Any];quality:QualityMetadata;transformations:tuple[Transformation,...];confirmation_status:ConfirmationStatus;source_ids:tuple[str,...]
 @classmethod
 def from_foundation(cls,foundation:DataFoundation,recipient:str)->'DataHandoff':
  if not foundation.handoff_ready:raise ValueError('Foundation is not ready for handoff.')
  return cls(handoff_id=f'HO-{uuid4().hex[:10].upper()}',foundation_id=foundation.foundation_id,recipient=recipient,created_at=datetime.now(timezone.utc).isoformat(),canonical_data=foundation.canonical_data,provenance=tuple(s.provenance for s in foundation.sources if s.provenance is not None),supplied_context=dict(foundation.supplied_context),quality=foundation.quality,transformations=foundation.transformations,confirmation_status=foundation.confirmation_status,source_ids=tuple(s.source_id for s in foundation.sources))
 def to_dict(self)->dict[str,Any]:return asdict(self)
__all__=['Anomaly','CandidateInformation','ConfirmationStatus','DataFoundation','DataHandoff','DataProfile','ExtractionStatus','Missingness','Provenance','QualityMetadata','SourceRecord','SourceType','Transformation']