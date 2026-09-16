import 'dart:convert';

import 'package:idb_shim/idb_browser.dart';

/// Browser-local presentation adapter for S8 authoritative artifacts.
///
/// The Flutter layer never computes verification truth. It stores and retrieves
/// authoritative artifact envelopes produced by the S8 capability boundary.
class S8IndexedDbArtifactStore {
  static const _databaseName = 'criterivox_s8';
  static const _storeName = 'artifacts';

  Database? _database;

  Future<void> open() async {
    if (_database != null) return;
    final factory = getIdbFactory();
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
    final db = _database!;
    final tx = db.transaction(_storeName, 'readwrite');
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

  Future<void> putJson(Map<String, dynamic> artifact) =>
      put({...artifact, 'payload_json': jsonEncode(artifact)});

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
