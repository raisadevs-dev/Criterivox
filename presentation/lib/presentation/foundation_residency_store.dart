import 'dart:convert';
import 'package:idb_shim/idb_browser.dart';

/// Durable browser residency for the authoritative S5 DataFoundation copy.
/// Python is a processing runtime/cache and is rehydrated from this store.
class FoundationResidencyStore {
  static const _dbName = 'criterivox_foundation_residency';
  static const _store = 'foundations';
  Database? _db;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) return existing;
    final db = await idbFactoryBrowser.open(_dbName, version: 1,
        onUpgradeNeeded: (event) {
      final database = event.database;
      if (!database.objectStoreNames.contains(_store)) {
        database.createObjectStore(_store);
      }
    });
    _db = db;
    return db;
  }

  Future<void> put(Map<String, dynamic> foundation,
      {required int revision}) async {
    final db = await _open();
    final id = '${foundation['foundation_id']}';
    final envelope = {
      'schema_version': 1,
      'foundation_id': id,
      'revision': revision,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'foundation': jsonDecode(jsonEncode(foundation)),
    };
    final tx = db.transaction(_store, idbModeReadWrite);
    await tx.objectStore(_store).put(envelope, id);
    await tx.completed;
  }

  Future<Map<String, dynamic>?> getEnvelope(String id) async {
    final db = await _open();
    final tx = db.transaction(_store, idbModeReadOnly);
    final value = await tx.objectStore(_store).getObject(id);
    await tx.completed;
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<List<Map<String, dynamic>>> allEnvelopes() async {
    final db = await _open();
    final tx = db.transaction(_store, idbModeReadOnly);
    final values = await tx.objectStore(_store).getAll();
    await tx.completed;
    return values
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  Future<void> remove(String id) async {
    final db = await _open();
    final tx = db.transaction(_store, idbModeReadWrite);
    await tx.objectStore(_store).delete(id);
    await tx.completed;
  }
}
