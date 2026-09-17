import 'dart:convert';

import 's8_artifact_store.dart';
import 's8_presentation_state.dart';

/// Canonical serialized envelope shared by persistence adapters.
class S8PersistedArtifact {
  const S8PersistedArtifact({required this.artifact});
  final S8ArtifactSummary artifact;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'artifact_id': artifact.id,
        'kind': artifact.kind,
        'title': artifact.title,
        'status': artifact.status,
        'parents': artifact.parents,
        'uncertainty': artifact.uncertainty,
        'contradictions': artifact.contradictions,
        'integrity': artifact.integrity,
        'temporal': artifact.temporal,
      };

  String toJson() => jsonEncode(toMap());
}

abstract interface class S8ArtifactPersistence {
  Future<void> open();
  Future<void> put(S8ArtifactSummary artifact);
  Future<S8ArtifactSummary?> get(String artifactId);
  Future<List<S8ArtifactSummary>> all();
  Future<void> clear();
  Future<void> close();
}

/// Persistence façade. Storage never manufactures verification truth.
class S8PersistentArtifactRepository {
  S8PersistentArtifactRepository(this.persistence, {S8ArtifactValidator? validator})
      : validator = validator ?? const S8ArtifactValidator();

  final S8ArtifactPersistence persistence;
  final S8ArtifactValidator validator;

  Future<void> open() => persistence.open();

  Future<void> save(S8ArtifactSummary artifact) async {
    final errors = validator.validate(artifact);
    if (errors.isNotEmpty) {
      throw ArgumentError('Invalid artifact: ${errors.join(', ')}');
    }
    await persistence.put(artifact);
  }

  Future<S8ArtifactSummary?> find(String artifactId) => persistence.get(artifactId);
  Future<List<S8ArtifactSummary>> list() => persistence.all();
  Future<void> clear() => persistence.clear();
  Future<void> close() => persistence.close();
}

class S8MemoryArtifactPersistence implements S8ArtifactPersistence {
  final Map<String, S8ArtifactSummary> _items = <String, S8ArtifactSummary>{};
  @override Future<void> open() async {}
  @override Future<void> put(S8ArtifactSummary artifact) async => _items[artifact.id] = artifact;
  @override Future<S8ArtifactSummary?> get(String artifactId) async => _items[artifactId];
  @override Future<List<S8ArtifactSummary>> all() async => List.unmodifiable(_items.values);
  @override Future<void> clear() async => _items.clear();
  @override Future<void> close() async {}
}

class S8IndexedDbArtifactPersistence implements S8ArtifactPersistence {
  S8IndexedDbArtifactPersistence([S8IndexedDbArtifactStore? store]) : store = store ?? S8IndexedDbArtifactStore();
  final S8IndexedDbArtifactStore store;

  @override Future<void> open() => store.open();
  @override Future<void> put(S8ArtifactSummary artifact) => store.put(S8PersistedArtifact(artifact: artifact).toMap());

  @override
  Future<S8ArtifactSummary?> get(String artifactId) async {
    final value = await store.get(artifactId);
    return value == null ? null : _decode(value);
  }

  @override
  Future<List<S8ArtifactSummary>> all() async =>
      (await store.all()).map(_decode).toList(growable: false);

  @override Future<void> clear() => store.clear();
  @override Future<void> close() => store.close();

  S8ArtifactSummary _decode(Map<String, dynamic> value) => S8ArtifactSummary(
        id: value['artifact_id'] as String? ?? '',
        kind: value['kind'] as String? ?? '',
        title: value['title'] as String? ?? '',
        status: value['status'] as String? ?? '',
        parents: List<String>.from(value['parents'] as List? ?? const <String>[]),
        uncertainty: value['uncertainty'] as String? ?? '',
        contradictions: List<String>.from(value['contradictions'] as List? ?? const <String>[]),
        integrity: value['integrity'] as String? ?? '',
        temporal: value['temporal'] as String? ?? '',
      );
}
