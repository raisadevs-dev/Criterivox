import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

/// Browser-first persistence for the Criterivox working set.
///
/// IndexedDB is used instead of LocalStorage so user-owned research material
/// can exceed the small key/value quota normally associated with LocalStorage.
/// The browser copy is the durable client-side residency boundary; Python is
/// a processing runtime/cache and must be re-hydrated from this copy.
class BrowserResidencyStore {
  static const _databaseName = 'criterivox_runtime_residency';
  static const _storeName = 'snapshots';
  static const _key = 'active';

  Database? _database;

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) return existing;
    final db = await idbFactoryBrowser.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (event) {
        final database = event.database;
        if (!database.objectStoreNames.contains(_storeName)) {
          database.createObjectStore(_storeName);
        }
      },
    );
    _database = db;
    return db;
  }

  Future<void> save(Map<String, dynamic> snapshot) async {
    final db = await _open();
    final transaction = db.transaction(_storeName, idbModeReadWrite);
    await transaction.objectStore(_storeName).put(snapshot, _key);
    await transaction.completed;
  }

  Future<Map<String, dynamic>?> load() async {
    final db = await _open();
    final transaction = db.transaction(_storeName, idbModeReadOnly);
    final value = await transaction.objectStore(_storeName).getObject(_key);
    await transaction.completed;
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Future<void> clear() async {
    final db = await _open();
    final transaction = db.transaction(_storeName, idbModeReadWrite);
    await transaction.objectStore(_storeName).delete(_key);
    await transaction.completed;
  }
}
