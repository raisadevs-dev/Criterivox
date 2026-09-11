import 'dart:convert';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class BrowserResidencyStore {
  static const _databaseName = 'criterivox_runtime_residency';
  static const _storeName = 'snapshots';
  static const _key = 'active';

  Future<Database> _open() => idbFactoryBrowser.open(_databaseName, version: 1, onUpgradeNeeded: (event) {
    final db = event.database;
    if (!db.objectStoreNames.contains(_storeName)) db.createObjectStore(_storeName);
  });

  Future<void> save(Map<String, dynamic> snapshot) async {
    final db = await _open();
    final tx = db.transaction(_storeName, idbModeReadWrite);
    await tx.objectStore(_storeName).put(jsonDecode(jsonEncode(snapshot)), _key);
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
}
