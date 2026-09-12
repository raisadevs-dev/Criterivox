import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Browser-first residence persistence contract. The web adapter stores the
/// complete residence envelope in IndexedDB; the non-web adapter keeps a
/// session copy so the presentation remains usable during local development.
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
}

class HumanResidenceStore {
  static const _dbName = 'criterivox_human_residence';
  static const _storeName = 'residences';
  static const _key = 'current';
  static HumanResidenceRecord? _memory;

  Future<HumanResidenceRecord?> load() async {
    if (!kIsWeb) return _memory;
    try {
      final value = await _IndexedDbBridge.get(_dbName, _storeName, _key);
      if (value == null) return null;
      final map = jsonDecode(value) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(HumanResidenceRecord record) async {
    _memory = record;
    if (!kIsWeb) return;
    await _IndexedDbBridge.put(_dbName, _storeName, _key, jsonEncode(record.toJson()));
  }

  HumanResidenceRecord _fromJson(Map<String, dynamic> m) => HumanResidenceRecord(residenceId: '${m['residence_id']}', ownerId: '${m['owner_id']}', displayName: '${m['display_name']}', email: m['email']?.toString(), residenceType: '${m['residence_type']}', createdAt: DateTime.tryParse('${m['created_at']}') ?? DateTime.now(), members: ((m['members'] as List?) ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(), metadata: Map<String, dynamic>.from((m['metadata'] as Map?) ?? {}));
}

class _IndexedDbBridge {
  static Future<String?> get(String db, String store, String key) async {
    const channel = MethodChannel('criterivox/indexeddb');
    try { return await channel.invokeMethod<String>('get', {'db': db, 'store': store, 'key': key}); } catch (_) { return null; }
  }
  static Future<void> put(String db, String store, String key, String value) async {
    const channel = MethodChannel('criterivox/indexeddb');
    try { await channel.invokeMethod('put', {'db': db, 'store': store, 'key': key, 'value': value}); } catch (_) {}
  }
}
