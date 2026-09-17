import 'dart:convert';

import 'package:idb_shim/idb_browser.dart';

import 's8_presentation_state.dart';

/// Authoritative artifact contract at the S8 presentation boundary.
///
/// Persistence is an adapter. It must never manufacture verification truth.
class S8ArtifactStore {
  final Map<String, S8ArtifactSummary> _memory = {};

  List<S8ArtifactSummary> get artifacts => List.unmodifiable(_memory.values);

  void put(S8ArtifactSummary artifact) {
    if (artifact.id.trim().isEmpty) {
      throw ArgumentError('Artifact id must not be empty');
    }
    _memory[artifact.id] = artifact;
  }

  S8ArtifactSummary? get(String id) => _memory[id];

  List<S8ArtifactSummary> childrenOf(String parentId) => _memory.values
      .where((artifact) => artifact.parents.contains(parentId))
      .toList(growable: false);

  void clear() => _memory.clear();
}

class S8ArtifactValidator {
  const S8ArtifactValidator();

  List<String> validate(S8ArtifactSummary artifact) {
    final errors = <String>[];
    if (artifact.id.trim().isEmpty) errors.add('missing id');
    if (artifact.kind.trim().isEmpty) errors.add('missing kind');
    if (artifact.title.trim().isEmpty) errors.add('missing title');
    if (artifact.status.trim().isEmpty) errors.add('missing status');
    if (artifact.integrity.trim().isEmpty) errors.add('missing integrity state');
    if (artifact.temporal.trim().isEmpty) errors.add('missing temporal state');
    return List.unmodifiable(errors);
  }
}

/// Browser-local persistence adapter for S8 authoritative artifact envelopes.
class S8IndexedDbArtifactStore {
  static const _databaseName = 'criterivox_s8';
  static const _storeName = 'artifacts';

  Database? _database;

  Future<void> open() async {
    if (_database != null) return;
    final factory = getIdbFactory();
    if (factory == null) {
      throw StateError('IndexedDB is unavailable in this runtime.');
    }
    _database = await factory.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(_storeName, keyPath: 'artifact_id');
        }
      },
    );
  }

  Future<void> put(Map<String, dynamic> artifact) async {
    await open();
    final tx = _database!.transaction(_storeName, 'readwrite');
    await tx.objectStore(_storeName).put(artifact);
    await tx.completed;
  }

  Future<Map<String, dynamic>?> get(String artifactId) async {
    await open();
    final tx = _database!.transaction(_storeName, 'readonly');
    final value = await tx.objectStore(_storeName).getObject(artifactId);
    await tx.completed;
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<List<Map<String, dynamic>>> all() async {
    await open();
    final tx = _database!.transaction(_storeName, 'readonly');
    final values = await tx.objectStore(_storeName).getAll();
    await tx.completed;
    return values
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }

  Future<void> clear() async {
    await open();
    final tx = _database!.transaction(_storeName, 'readwrite');
    await tx.objectStore(_storeName).clear();
    await tx.completed;
  }

  Future<void> putJson(Map<String, dynamic> artifact) =>
      put({...artifact, 'payload_json': jsonEncode(artifact)});

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
