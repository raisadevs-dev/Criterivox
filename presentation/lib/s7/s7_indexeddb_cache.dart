import 'dart:convert';
import 'package:idb_shim/idb_browser.dart';

class S7IndexedDbCache {
  static const _dbName = 'criterivox_s7_cache';
  static const _storeName = 'sessions';
  Future<Database> _open() async {
    final factory = getIdbFactory();
    return factory.open(_dbName, version: 1, onUpgradeNeeded: (event) {
      final db = event.database;
      if (!db.objectStoreNames.contains(_storeName)) db.createObjectStore(_storeName, keyPath: 'session_id');
    });
  }
  Future<void> put(Map<String,dynamic> snapshot) async { final db=await _open(); final tx=db.transaction(_storeName,'readwrite'); await tx.objectStore(_storeName).put({...snapshot,'cached_at':DateTime.now().toUtc().toIso8601String()}); await tx.completed; }
  Future<Map<String,dynamic>?> get(String sessionId) async { final db=await _open(); final tx=db.transaction(_storeName,'readonly'); final value=await tx.objectStore(_storeName).getObject(sessionId); await tx.completed; return value is Map ? Map<String,dynamic>.from(value) : null; }
  Future<void> remove(String sessionId) async { final db=await _open(); final tx=db.transaction(_storeName,'readwrite'); await tx.objectStore(_storeName).delete(sessionId); await tx.completed; }
  String encode(Map<String,dynamic> snapshot)=>jsonEncode(snapshot);
}
