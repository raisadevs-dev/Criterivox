import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 's8_persistence.dart';
import 's8_presentation_state.dart';

/// Native SQLite adapter for S8. The browser uses IndexedDB instead.
class S8SqliteArtifactPersistence implements S8ArtifactPersistence {
  Database? _db;

  @override
  Future<void> open() async {
    if (_db != null) return;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      path.join(root, 'criterivox_s8.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE artifacts (
            artifact_id TEXT PRIMARY KEY,
            kind TEXT NOT NULL,
            title TEXT NOT NULL,
            status TEXT NOT NULL,
            parents_json TEXT NOT NULL,
            uncertainty TEXT NOT NULL,
            contradictions_json TEXT NOT NULL,
            integrity TEXT NOT NULL,
            temporal TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> put(S8ArtifactSummary artifact) async {
    await open();
    await _db!.insert(
      'artifacts',
      <String, Object?>{
        'artifact_id': artifact.id,
        'kind': artifact.kind,
        'title': artifact.title,
        'status': artifact.status,
        'parents_json': artifact.parents.join('\u001f'),
        'uncertainty': artifact.uncertainty,
        'contradictions_json': artifact.contradictions.join('\u001f'),
        'integrity': artifact.integrity,
        'temporal': artifact.temporal,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<S8ArtifactSummary?> get(String artifactId) async {
    await open();
    final rows = await _db!.query(
      'artifacts',
      where: 'artifact_id = ?',
      whereArgs: <Object>[artifactId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _decode(rows.single);
  }

  @override
  Future<List<S8ArtifactSummary>> all() async {
    await open();
    final rows = await _db!.query('artifacts', orderBy: 'artifact_id ASC');
    return List.unmodifiable(rows.map(_decode));
  }

  @override
  Future<void> clear() async {
    await open();
    await _db!.delete('artifacts');
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  S8ArtifactSummary _decode(Map<String, Object?> row) => S8ArtifactSummary(
        id: row['artifact_id']! as String,
        kind: row['kind']! as String,
        title: row['title']! as String,
        status: row['status']! as String,
        parents: _split(row['parents_json'] as String),
        uncertainty: row['uncertainty']! as String,
        contradictions: _split(row['contradictions_json'] as String),
        integrity: row['integrity']! as String,
        temporal: row['temporal']! as String,
      );

  List<String> _split(String value) => value.isEmpty ? const <String>[] : value.split('\u001f');
}
