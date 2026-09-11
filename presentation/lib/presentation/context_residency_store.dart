import 'dart:convert';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class ContextResidencyStore {
  static const _databaseName = 'criterivox_context_residency';
  static const _storeName = 'context_states';
  static const _key = 'active';

  Future<Database> _open() => idbFactoryBrowser.open(_databaseName, version: 1, onUpgradeNeeded: (event) {
    final db = event.database;
    if (!db.objectStoreNames.contains(_storeName)) db.createObjectStore(_storeName);
  });

  Future<void> save(Map<String, dynamic> payload) async {
    final db = await _open();
    final tx = db.transaction(_storeName, idbModeReadWrite);
    await tx.objectStore(_storeName).put(jsonDecode(jsonEncode(payload)), _key);
    await tx.completed;
    db.close();
  }

  Future<Map<String, dynamic>?> load() async {
    final db = await _open();
    final tx = db.transaction(_storeName, idbModeReadOnly);
    final value = await tx.objectStore(_storeName).getObject(_key);
    await tx.completed;
    db.close();
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> clear() async {
    final db = await _open();
    final tx = db.transaction(_storeName, idbModeReadWrite);
    await tx.objectStore(_storeName).delete(_key);
    await tx.completed;
    db.close();
  }
}
