from __future__ import annotations
import json, sqlite3, time
from pathlib import Path

DB=Path(__file__).resolve().parents[3]/'data'/'home03'/'home03.sqlite3'
DB.parent.mkdir(parents=True,exist_ok=True)

class Home03Store:
 def __init__(self,path=DB):
  self.path=str(path); self._init()
 def _db(self): return sqlite3.connect(self.path)
 def _init(self):
  with self._db() as c:
   c.executescript('''CREATE TABLE IF NOT EXISTS state_journeys(journey_id TEXT PRIMARY KEY,conversation_id TEXT NOT NULL,task_id TEXT UNIQUE NOT NULL,goal TEXT NOT NULL,status TEXT NOT NULL,created_at TEXT NOT NULL,updated_at TEXT NOT NULL,context_reference TEXT);
   CREATE INDEX IF NOT EXISTS idx_state_journey_conversation ON state_journeys(conversation_id);
   CREATE TABLE IF NOT EXISTS state_checkpoints(checkpoint_id TEXT PRIMARY KEY,journey_id TEXT NOT NULL,task_id TEXT NOT NULL,timestamp TEXT NOT NULL,payload TEXT NOT NULL);
   CREATE INDEX IF NOT EXISTS idx_state_checkpoint_task ON state_checkpoints(task_id,timestamp);
   CREATE TABLE IF NOT EXISTS state_events(event_id TEXT PRIMARY KEY,journey_id TEXT NOT NULL,task_id TEXT NOT NULL,timestamp TEXT NOT NULL,event_type TEXT NOT NULL,payload TEXT NOT NULL);
   CREATE INDEX IF NOT EXISTS idx_state_event_task ON state_events(task_id,timestamp);
   CREATE TABLE IF NOT EXISTS conversations(id TEXT PRIMARY KEY, created REAL NOT NULL, updated REAL NOT NULL);CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, conversation_id TEXT, branch_id TEXT, role TEXT, content TEXT, metadata TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS branches(id TEXT PRIMARY KEY, conversation_id TEXT, parent_message INTEGER, name TEXT, state TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS checkpoints(id TEXT PRIMARY KEY, conversation_id TEXT, branch_id TEXT, state TEXT, state_hash TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY AUTOINCREMENT, event_type TEXT, task_id TEXT, payload TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS pollen(id INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT, source TEXT, target TEXT, payload TEXT, confidence REAL, created REAL NOT NULL);''')
 def conversation(self,cid):
  now=time.time()
  with self._db() as c:c.execute('INSERT OR IGNORE INTO conversations VALUES(?,?,?)',(cid,now,now));c.execute('UPDATE conversations SET updated=? WHERE id=?',(now,cid))
  return cid
 def message(self,cid,branch,role,content,metadata=None):
  self.conversation(cid)
  with self._db() as c:return c.execute('INSERT INTO messages(conversation_id,branch_id,role,content,metadata,created) VALUES(?,?,?,?,?,?)',(cid,branch,role,content,json.dumps(metadata or {}),time.time())).lastrowid
 def branch(self,bid,cid,parent,name,state=None):
  with self._db() as c:c.execute('INSERT OR REPLACE INTO branches VALUES(?,?,?,?,?,?)',(bid,cid,parent,name,json.dumps(state or {}),time.time()))
  return bid
 def checkpoint(self,cid,bid,state,state_hash):
  cp=f'cp-{int(time.time()*1000000)}'
  with self._db() as c:c.execute('INSERT INTO checkpoints VALUES(?,?,?,?,?,?)',(cp,cid,bid,json.dumps(state),state_hash,time.time()))
  return cp
 def event(self,event_type,task_id,payload):
  with self._db() as c:c.execute('INSERT INTO events(event_type,task_id,payload,created) VALUES(?,?,?,?)',(event_type,task_id,json.dumps(payload),time.time()))
 def pollen(self,task_id,source,target,payload,confidence):
  with self._db() as c:c.execute('INSERT INTO pollen(task_id,source,target,payload,confidence,created) VALUES(?,?,?,?,?,?)',(task_id,source,target,json.dumps(payload),confidence,time.time()))
 def tree(self,cid):
  with self._db() as c:
   branches=[dict(zip(['id','conversation_id','parent_message','name','state','created'],r)) for r in c.execute('SELECT * FROM branches WHERE conversation_id=? ORDER BY created',(cid,))]
   messages=[dict(zip(['id','conversation_id','branch_id','role','content','metadata','created'],r)) for r in c.execute('SELECT * FROM messages WHERE conversation_id=? ORDER BY id',(cid,))]
  return {'conversation_id':cid,'branches':branches,'messages':messages}



def _state_row(self, task_id):
 with self._db() as c:
  r=c.execute('SELECT * FROM state_journeys WHERE task_id=?',(task_id,)).fetchone()
  if not r:return None
  return dict(r)

def state_journey(self,row):
 with self._db() as c:c.execute('INSERT OR IGNORE INTO state_journeys VALUES(?,?,?,?,?,?,?,?)',(row['journey_id'],row['conversation_id'],row['task_id'],row['goal'],row['status'],row['created_at'],row['updated_at'],row.get('context_reference')))

def update_state_journey(self,task_id,fields):
 if not fields:return
 allowed={'goal','status','updated_at','context_reference'}; items=[(k,v) for k,v in fields.items() if k in allowed]
 if not items:return
 with self._db() as c:c.execute(f"UPDATE state_journeys SET {','.join(k+'=?' for k,_ in items)} WHERE task_id=?",(*[v for _,v in items],task_id))

def get_state_journey_by_task(self,task_id):return self._state_row(task_id)
def state_journeys_by_conversation(self,cid):
 with self._db() as c:return [dict(r) for r in c.execute('SELECT * FROM state_journeys WHERE conversation_id=? ORDER BY updated_at DESC',(cid,))]
def active_state_journeys(self):
 with self._db() as c:return [dict(r) for r in c.execute("SELECT * FROM state_journeys WHERE status NOT IN ('COMPLETED','FAILED','CANCELLED') ORDER BY updated_at DESC")]
def state_checkpoint(self,row):
 import json
 with self._db() as c:c.execute('INSERT INTO state_checkpoints VALUES(?,?,?,?,?)',(row['checkpoint_id'],row['journey_id'],row['task_id'],row['timestamp'],json.dumps(row,sort_keys=True)))
def latest_state_checkpoint(self,task_id):
 import json
 with self._db() as c:
  r=c.execute('SELECT payload FROM state_checkpoints WHERE task_id=? ORDER BY timestamp DESC LIMIT 1',(task_id,)).fetchone()
  return json.loads(r[0]) if r else None
def state_event(self,row):
 import json
 with self._db() as c:c.execute('INSERT INTO state_events VALUES(?,?,?,?,?,?)',(row['event_id'],row['journey_id'],row['task_id'],row['timestamp'],row['event_type'],json.dumps(row,sort_keys=True)))
def state_events(self,task_id):
 import json
 with self._db() as c:return [json.loads(r[0]) for r in c.execute('SELECT payload FROM state_events WHERE task_id=? ORDER BY timestamp,event_id',(task_id,))]

Home03Store._state_row=_state_row
Home03Store.state_journey=state_journey
Home03Store.update_state_journey=update_state_journey
Home03Store.get_state_journey_by_task=get_state_journey_by_task
Home03Store.state_journeys_by_conversation=state_journeys_by_conversation
Home03Store.active_state_journeys=active_state_journeys
Home03Store.state_checkpoint=state_checkpoint
Home03Store.latest_state_checkpoint=latest_state_checkpoint
Home03Store.state_event=state_event
Home03Store.state_events=state_events
home03_store=Home03Store()
