import 'dart:convert';

import 'package:idb_shim/idb_browser.dart';

class S7IndexedDbCache {
  static const String _dbName = 'criterivox_s7_cache';
  static const String _storeName = 'sessions';

  Future<Database> _open() async {
    final factory = getIdbFactory();

    if (factory == null) {
      throw StateError(
        'IndexedDB is unavailable in this browser environment.',
      );
    }

    return factory.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (event) {
        final db = event.database;

        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(
            _storeName,
            keyPath: 'session_id',
          );
        }
      },
    );
  }

  Future<void> put(Map<String, dynamic> snapshot) async {
    final db = await _open();

    final transaction = db.transaction(
      _storeName,
      'readwrite',
    );

    await transaction
        .objectStore(_storeName)
        .put({
          ...snapshot,
          'cached_at': DateTime.now()
              .toUtc()
              .toIso8601String(),
        });

    await transaction.completed;
  }

  Future<Map<String, dynamic>?> get(
    String sessionId,
  ) async {
    final db = await _open();

    final transaction = db.transaction(
      _storeName,
      'readonly',
    );

    final value = await transaction
        .objectStore(_storeName)
        .getObject(sessionId);

    await transaction.completed;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Future<void> remove(String sessionId) async {
    final db = await _open();

    final transaction = db.transaction(
      _storeName,
      'readwrite',
    );

    await transaction
        .objectStore(_storeName)
        .delete(sessionId);

    await transaction.completed;
  }

  String encode(Map<String, dynamic> snapshot) {
    return jsonEncode(snapshot);
  }
}