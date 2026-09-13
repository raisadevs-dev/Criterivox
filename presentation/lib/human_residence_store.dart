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

  HumanResidenceRecord({
    required this.residenceId,
    required this.ownerId,
    required this.displayName,
    this.email,
    required this.residenceType,
    required this.createdAt,
    this.members = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'residence_id': residenceId,
      'owner_id': ownerId,
      'display_name': displayName,
      'email': email,
      'residence_type': residenceType,
      'created_at': createdAt.toIso8601String(),
      'members': members,
      'metadata': metadata,
    };
  }

  factory HumanResidenceRecord.fromJson(
    Map<dynamic, dynamic> m,
  ) {
    final rawMembers = m['members'];
    final rawMetadata = m['metadata'];

    return HumanResidenceRecord(
      residenceId: '${m['residence_id'] ?? ''}',
      ownerId: '${m['owner_id'] ?? ''}',
      displayName: '${m['display_name'] ?? ''}',
      email: m['email']?.toString(),
      residenceType: '${m['residence_type'] ?? ''}',
      createdAt:
          DateTime.tryParse('${m['created_at'] ?? ''}') ??
          DateTime.now(),
      members: rawMembers is List
          ? rawMembers
              .whereType<Map>()
              .map(
                (entry) => Map<String, dynamic>.from(entry),
              )
              .toList()
          : <Map<String, dynamic>>[],
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
    );
  }
}

class HumanResidenceStore {
  static const String _dbName = 'criterivox_human_residence';
  static const String _storeName = 'residences';
  static const String _key = 'current';

  static HumanResidenceRecord? _memory;

  Future<Database> _db() async {
    final factory = getIdbFactory();

    if (factory == null) {
      throw StateError(
        'IndexedDB is unavailable in this browser environment.',
      );
    }

    return factory.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final database = event.database;

        if (!database.objectStoreNames.contains(_storeName)) {
          database.createObjectStore(_storeName);
        }
      },
    );
  }

  Future<HumanResidenceRecord?> load() async {
    if (!kIsWeb) {
      return _memory;
    }

    try {
      final db = await _db();

      final transaction = db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final value = await transaction
          .objectStore(_storeName)
          .getObject(_key);

      await transaction.completed;

      if (value is! Map) {
        return null;
      }

      final record = HumanResidenceRecord.fromJson(value);

      _memory = record;

      return record;
    } catch (_) {
      return _memory;
    }
  }

  Future<void> save(
    HumanResidenceRecord record,
  ) async {
    _memory = record;

    if (!kIsWeb) {
      return;
    }

    final db = await _db();

    final transaction = db.transaction(
      _storeName,
      idbModeReadWrite,
    );

    await transaction
        .objectStore(_storeName)
        .put(record.toJson(), _key);

    await transaction.completed;
  }
}
