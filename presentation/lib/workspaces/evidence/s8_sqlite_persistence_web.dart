import 's8_persistence.dart';
import 's8_presentation_state.dart';

/// Web deliberately does not emulate SQLite. IndexedDB is the browser-native
/// S8 persistence backend and remains the authoritative web adapter.
class S8SqliteArtifactPersistence implements S8ArtifactPersistence {
  Never _unsupported() => throw UnsupportedError(
        'SQLite persistence is native-only. Use S8IndexedDbArtifactPersistence on web.',
      );

  @override
  Future<void> open() => Future<void>.error(_unsupported());

  @override
  Future<void> put(S8ArtifactSummary artifact) => Future<void>.error(_unsupported());

  @override
  Future<S8ArtifactSummary?> get(String artifactId) => Future<S8ArtifactSummary?>.error(_unsupported());

  @override
  Future<List<S8ArtifactSummary>> all() => Future<List<S8ArtifactSummary>>.error(_unsupported());

  @override
  Future<void> clear() => Future<void>.error(_unsupported());

  @override
  Future<void> close() async {}
}
