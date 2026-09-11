from __future__ import annotations
import json, math, re
from collections import Counter, defaultdict
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
DATA=ROOT/'data'/'home03'
DATA.mkdir(parents=True,exist_ok=True)

INTENT_SEEDS={
'analyze':['analyze this evidence','inspect the findings','investigate the data','examine the problem','identify evidence gaps'],
'compare':['compare these options','compare the approaches','show trade offs','which option differs','contrast the alternatives'],
'explain':['explain this result','why did this happen','clarify the reasoning','interpret the finding','explain the decision'],
'build':['build this feature','implement the change','create the component','develop the workflow','code the solution'],
'explore':['explore alternatives','research the topic','discover unknowns','find possible approaches','investigate possibilities'],
'decide':['help choose','recommend an option','make a decision','evaluate which to select','choose between alternatives'],
}
UI_SEEDS={
'executive':['summarize the result','give me the key points','executive summary','brief conclusion'],
'reasoning':['show the reasoning','explain the reasoning tree','show the decision path','detail the analysis'],
'json':['return json','machine readable output','raw json payload','structured json'],
'comparison':['compare in a table','show tradeoffs','comparison matrix','compare alternatives'],
'code':['give implementation code','show the code','provide a code solution','implementation output'],
}

def _augment(text,label,i):
 variants=[text, text.replace('the ','this '), text+' for the current task', 'please '+text, text+' with evidence']
 return {'text':variants[i%len(variants)],'label':label}

def generate_dataset(seeds):
 rows=[]
 for label,texts in seeds.items():
  for i,text in enumerate(texts*8): rows.append(_augment(text,label,i))
 return rows

def split(rows):
 train=[];test=[];validate=[]
 for i,row in enumerate(rows):
  (validate if i%10==0 else test if i%10 in (1,2) else train).append(row)
 return train,test,validate

class NaiveBayesTextModel:
 def __init__(self): self.labels=[];self.prior={};self.counts={};self.totals={};self.vocab=set()
 def fit(self,rows):
  labels=Counter(r['label'] for r in rows); n=len(rows); self.labels=list(labels); self.prior={k:v/n for k,v in labels.items()}; self.counts=defaultdict(Counter); self.totals=Counter()
  for r in rows:
   words=re.findall(r'[a-z0-9]+',r['text'].lower()); self.counts[r['label']].update(words);self.totals[r['label']]+=len(words);self.vocab.update(words)
  return self
 def predict(self,text):
  words=re.findall(r'[a-z0-9]+',text.lower()); scores={}
  V=max(1,len(self.vocab))
  for label in self.labels:
   s=math.log(self.prior[label])
   for w in words:s+=math.log((self.counts[label][w]+1)/(self.totals[label]+V))
   scores[label]=s
  best=max(scores,key=scores.get); exps={k:math.exp(v-max(scores.values())) for k,v in scores.items()}; z=sum(exps.values()) or 1
  return {'label':best,'confidence':exps[best]/z,'scores':{k:exps[k]/z for k in scores}}
 def export(self,path):
  payload={'labels':self.labels,'prior':self.prior,'counts':{k:dict(v) for k,v in self.counts.items()},'totals':dict(self.totals),'vocab':sorted(self.vocab)};Path(path).write_text(json.dumps(payload,indent=2))

intent_rows=generate_dataset(INTENT_SEEDS);ui_rows=generate_dataset(UI_SEEDS)
for name,rows in [('intent',intent_rows),('ui',ui_rows)]:
 tr,te,va=split(rows)
 (DATA/f'{name}_train.json').write_text(json.dumps(tr,indent=2));(DATA/f'{name}_test.json').write_text(json.dumps(te,indent=2));(DATA/f'{name}_validate.json').write_text(json.dumps(va,indent=2))

intent_model=NaiveBayesTextModel().fit(split(intent_rows)[0]);ui_model=NaiveBayesTextModel().fit(split(ui_rows)[0])
intent_model.export(DATA/'intent_model.json');ui_model.export(DATA/'ui_model.json')

TRAINING_REPORT={
 'intent':{'dataset_size':len(intent_rows),'train':len(split(intent_rows)[0]),'test':len(split(intent_rows)[1]),'validate':len(split(intent_rows)[2]),'algorithm':'multinomial naive bayes text classifier','artifact':'data/home03/intent_model.json'},
 'ui':{'dataset_size':len(ui_rows),'train':len(split(ui_rows)[0]),'test':len(split(ui_rows)[1]),'validate':len(split(ui_rows)[2]),'algorithm':'multinomial naive bayes text classifier','artifact':'data/home03/ui_model.json'},
}
(DATA/'training_report.json').write_text(json.dumps(TRAINING_REPORT,indent=2))
