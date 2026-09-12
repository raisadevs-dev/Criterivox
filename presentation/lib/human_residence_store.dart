import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class HumanResidenceRecord {
  final String residenceId;
  final String ownerId;
  final String displayName;
  final String? email;
  final String residenceType;
  final DateTime createdAt;
  final List<Map<String, dynamic>> members;
  final Map<String, dynamic> metadata;
  HumanResidenceRecord({required this.residenceId, required this.ownerId, required this.displayName, this.email, required this.residenceType, required this.createdAt, this.members = const [], this.metadata = const {}});
  Map<String, dynamic> toJson() => {'residence_id': residenceId, 'owner_id': ownerId, 'display_name': displayName, 'email': email, 'residence_type': residenceType, 'created_at': createdAt.toIso8601String(), 'members': members, 'metadata': metadata};
  factory HumanResidenceRecord.fromJson(Map<dynamic, dynamic> m) => HumanResidenceRecord(residenceId: '${m['residence_id']}', ownerId: '${m['owner_id']}', displayName: '${m['display_name']}', email: m['email']?.toString(), residenceType: '${m['residence_type']}', createdAt: DateTime.tryParse('${m['created_at']}') ?? DateTime.now(), members: ((m['members'] as List?) ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(), metadata: Map<String, dynamic>.from((m['metadata'] as Map?) ?? {}));
}

class HumanResidenceStore {
  static const _dbName = 'criterivox_human_residence';
  static const _storeName = 'residences';
  static const _key = 'current';
  static HumanResidenceRecord? _memory;
  Future<Database> _db() => getIdbFactory().open(_dbName, version: 1, onUpgradeNeeded: (e) { if (!e.database.objectStoreNames.contains(_storeName)) e.database.createObjectStore(_storeName); });
  Future<HumanResidenceRecord?> load() async {
    if (!kIsWeb) return _memory;
    try { final db = await _db(); final tx = db.transaction(_storeName, idbModeReadOnly); final value = await tx.objectStore(_storeName).getObject(_key); await tx.completed; if (value is! Map) return null; return HumanResidenceRecord.fromJson(value); } catch (_) { return null; }
  }
  Future<void> save(HumanResidenceRecord record) async {
    _memory = record;
    if (!kIsWeb) return;
    final db = await _db(); final tx = db.transaction(_storeName, idbModeReadWrite); await tx.objectStore(_storeName).put(record.toJson(), _key); await tx.completed;
  }
}
