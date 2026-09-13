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
   c.executescript('''CREATE TABLE IF NOT EXISTS conversations(id TEXT PRIMARY KEY, created REAL NOT NULL, updated REAL NOT NULL);CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, conversation_id TEXT, branch_id TEXT, role TEXT, content TEXT, metadata TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS branches(id TEXT PRIMARY KEY, conversation_id TEXT, parent_message INTEGER, name TEXT, state TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS checkpoints(id TEXT PRIMARY KEY, conversation_id TEXT, branch_id TEXT, state TEXT, state_hash TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY AUTOINCREMENT, event_type TEXT, task_id TEXT, payload TEXT, created REAL NOT NULL);CREATE TABLE IF NOT EXISTS pollen(id INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT, source TEXT, target TEXT, payload TEXT, confidence REAL, created REAL NOT NULL);''')
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

home03_store=Home03Store()
