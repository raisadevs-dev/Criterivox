#!/usr/bin/env python3
from __future__ import annotations
import argparse, csv, json, random, sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
try:
    from openpyxl import Workbook
except ImportError:
    Workbook = None
ROOT=Path(__file__).resolve().parent; OUT=ROOT/'generated'
@dataclass
class Fixture:
    fixture_id:str; scenario:str; upstream_component:str; task:str; input_kind:str; records:list[dict]
    competing_hypotheses:bool; contradictory_evidence:bool; provenance:dict; human_intervention:bool
    limitations:list[str]; synthetic:bool=True

def ask(prompt, default=''):
    value=input(f'{prompt}\n> ').strip(); return value or default
def ask_bool(prompt, default=False):
    value=ask(f'{prompt} (yes/no)', 'yes' if default else 'no').lower(); return value in {'y','yes','true','1'}
def ask_int(prompt, default):
    try:return max(1,int(ask(prompt,str(default))))
    except ValueError:return default
def make(args):
    now=datetime.now(timezone.utc).isoformat(); out=[]
    for i in range(args.count):
        records=[{'record_id':f'obs-{i+1:04d}-{j+1:03d}','observation':f'Synthetic structured observation {j+1} for {args.task}','source_component':args.component} for j in range(args.records)]
        if args.contradictory: records.append({'record_id':f'conflict-{i+1:04d}','observation':'Synthetic contradictory observation requiring conflict handling','conflict':True})
        if args.hypotheses: records += [{'hypothesis_id':'H1','statement':'Synthetic explanation A'},{'hypothesis_id':'H2','statement':'Synthetic explanation B'}]
        if args.intervention: records.append({'intervention_id':'I1','type':'challenge','instruction':'Reconsider the weakest supported inference'})
        out.append(Fixture(f'FX-{args.scenario.upper()}-{i+1:04d}',args.scenario,args.component,args.task,args.input_kind,records,args.hypotheses,args.contradictory,{'generated_at':now,'generator':'Criterivox Test Dataset & Fixture Laboratory','origin_component':args.component},args.intervention,['Synthetic material; not real-world evidence.']))
    return out
def write(fixtures, formats):
    OUT.mkdir(parents=True,exist_ok=True); data=[asdict(x) for x in fixtures]; scenario=fixtures[0].scenario
    if 'json' in formats:(OUT/'json').mkdir(exist_ok=True); (OUT/'json'/f'{scenario}.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
    if 'csv' in formats:
        (OUT/'csv').mkdir(exist_ok=True); p=OUT/'csv'/f'{scenario}.csv'; fields=list(data[0]);
        with p.open('w',newline='',encoding='utf-8') as h:
            w=csv.DictWriter(h,fieldnames=fields); w.writeheader();
            for row in data:w.writerow({k:json.dumps(v) if isinstance(v,(dict,list)) else v for k,v in row.items()})
    if 'xlsx' in formats:
        if Workbook is None: raise RuntimeError('XLSX output requires openpyxl')
        (OUT/'xlsx').mkdir(exist_ok=True); book=Workbook(); sheet=book.active; sheet.title='fixtures'; sheet.append(list(data[0]))
        for row in data:sheet.append([json.dumps(v) if isinstance(v,(dict,list)) else v for v in row.values()])
        book.save(OUT/'xlsx'/f'{scenario}.xlsx')
    (OUT/'manifests').mkdir(exist_ok=True); (OUT/'manifests'/f'{scenario}.manifest.json').write_text(json.dumps({'synthetic':True,'production_ingestion':False,'formats':formats,'fixture_ids':[x.fixture_id for x in fixtures]},indent=2),encoding='utf-8')
def main():
    p=argparse.ArgumentParser(); p.add_argument('--non-interactive',action='store_true'); p.add_argument('--scenario',default='reasoning'); p.add_argument('--component',default='Dharen'); p.add_argument('--task'); p.add_argument('--input-kind',default='structured observations'); p.add_argument('--count',type=int,default=1); p.add_argument('--records',type=int,default=5); p.add_argument('--hypotheses',action='store_true'); p.add_argument('--contradictory',action='store_true'); p.add_argument('--provenance',action='store_true'); p.add_argument('--intervention',action='store_true'); p.add_argument('--formats',default='json,csv,xlsx'); p.add_argument('--seed',type=int,default=7); a=p.parse_args(); random.seed(a.seed)
    if not a.non_interactive:
        print('\nCriterivox Research Fixture Generator\n'); a.task=ask('What are you testing?','S7 reasoning analysis'); a.input_kind=ask('What kind of input should simulate the upstream system?','structured observations'); a.records=ask_int('How many records?',50); a.hypotheses=ask_bool('Should there be competing hypotheses?',True); a.contradictory=ask_bool('Should there be contradictory evidence?',True); a.provenance=ask_bool('Should provenance be included?',True); a.intervention=ask_bool('Should human intervention be included?',False); a.formats=ask('Output formats (JSON, CSV, XLSX)','JSON, CSV, XLSX'); a.component=ask('Which Criterivox component should this simulate?','Dharen'); a.scenario=ask('Scenario','reasoning'); a.count=ask_int('How many fixture cases?',1); a.formats=','.join(x.strip().lower() for x in a.formats.split(','))
    else:a.task=a.task or 'Analyze supplied structured observations.'; a.formats=','.join(x.strip().lower() for x in a.formats.split(','))
    write(make(a),a.formats.split(',')); print(f'Generated fixtures under {OUT}')
if __name__=='__main__':sys.exit(main())
