from __future__ import annotations
import json, sqlite3
from pathlib import Path
from criterivox.s7.models import AnalysisSession, Artifact, ArtifactKind, S7Event, SessionStatus

class S7SQLiteStore:
    """Local durable store. Historical artifacts/events are append-preserving and never overwritten."""
    def __init__(self,path='data/s7/reasoning_history.sqlite3'):
        self.path=Path(path); self.path.parent.mkdir(parents=True,exist_ok=True); self._db=sqlite3.connect(self.path); self._db.row_factory=sqlite3.Row
        self._db.executescript('''PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS sessions(session_id TEXT PRIMARY KEY,task TEXT NOT NULL,context_json TEXT NOT NULL,status TEXT NOT NULL,branch_id TEXT NOT NULL,missing_json TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS artifacts(artifact_id TEXT PRIMARY KEY,session_id TEXT NOT NULL,kind TEXT NOT NULL,title TEXT NOT NULL,content_json TEXT NOT NULL,parent_ids_json TEXT NOT NULL,version INTEGER NOT NULL,branch_id TEXT NOT NULL,created_at TEXT NOT NULL,FOREIGN KEY(session_id) REFERENCES sessions(session_id));
CREATE TABLE IF NOT EXISTS events(event_id TEXT PRIMARY KEY,session_id TEXT NOT NULL,event_type TEXT NOT NULL,payload_json TEXT NOT NULL,created_at TEXT NOT NULL,FOREIGN KEY(session_id) REFERENCES sessions(session_id));
CREATE INDEX IF NOT EXISTS idx_artifacts_session ON artifacts(session_id);CREATE INDEX IF NOT EXISTS idx_events_session ON events(session_id);'''); self._db.commit()
    def save(self,s):
        self._db.execute('INSERT OR IGNORE INTO sessions VALUES(?,?,?,?,?,?)',(s.session_id,s.task,json.dumps(dict(s.context),sort_keys=True),s.status.value,s.branch_id,json.dumps(s.missing_information)))
        self._db.execute('UPDATE sessions SET status=?,branch_id=?,missing_json=? WHERE session_id=?',(s.status.value,s.branch_id,json.dumps(s.missing_information),s.session_id))
        for a in s.artifacts:self._db.execute('INSERT OR IGNORE INTO artifacts VALUES(?,?,?,?,?,?,?,?,?,?)',(a.artifact_id,s.session_id,a.kind.value,a.title,json.dumps(dict(a.content),sort_keys=True),json.dumps(a.parent_ids),a.version,a.branch_id,a.created_at))
        for e in s.events:self._db.execute('INSERT OR IGNORE INTO events VALUES(?,?,?,?,?)',(e.event_id,s.session_id,e.event_type,json.dumps(dict(e.payload),sort_keys=True),e.created_at))
        self._db.commit()
    def restore(self,session_id):
        r=self._db.execute('SELECT * FROM sessions WHERE session_id=?',(session_id,)).fetchone()
        if not r:return None
        s=AnalysisSession(r['session_id'],r['task'],json.loads(r['context_json']),SessionStatus(r['status']),r['branch_id'],[],[],tuple(json.loads(r['missing_json'])))
        for a in self._db.execute('SELECT * FROM artifacts WHERE session_id=? ORDER BY rowid', (session_id,)):s.artifacts.append(Artifact(a['artifact_id'],ArtifactKind(a['kind']),a['title'],json.loads(a['content_json']),tuple(json.loads(a['parent_ids_json'])),a['version'],a['branch_id'],a['created_at']))
        for e in self._db.execute('SELECT * FROM events WHERE session_id=? ORDER BY rowid',(session_id,)):s.events.append(S7Event(e['event_id'],e['event_type'],json.loads(e['payload_json']),e['created_at']))
        return s
    def list_sessions(self):return [r['session_id'] for r in self._db.execute('SELECT session_id FROM sessions ORDER BY rowid DESC')]
    def close(self):self._db.close()
