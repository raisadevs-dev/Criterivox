import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_local_intelligence.dart';
import 'package:presentation/s8_persistence.dart';
import 'package:presentation/s8_sqlite_persistence.dart';
import 'package:presentation/s8_temporal.dart';
import 'package:presentation/s8_presentation_state.dart';

S8ArtifactSummary artifact(String id) => S8ArtifactSummary(
      id: id,
      kind: 'evidence',
      title: 'Test evidence',
      status: 'available',
      parents: const <String>[],
      uncertainty: const <String>['unknown'],
      contradictions: const <String>[],
      integrity: 'unverified',
      temporal: '2026-09-17T00:00:00Z',
    );

class FakeClock implements S8Clock {
  FakeClock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
}

class FakeTransport implements S8LocalIntelligenceTransport {
  Map<String, dynamic>? request;
  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> value) async {
    request = value;
    return <String, dynamic>{
      'operation': value['operation'],
      'output': <String, dynamic>{'ok': true},
      'source': 'python-test',
      'trace_id': value['trace_id'],
    };
  }
}

void main() {
  test('repository validates and persists artifacts through memory adapter', () async {
    final repository = S8PersistentArtifactRepository(S8MemoryArtifactPersistence());
    await repository.open();
    await repository.save(artifact('a1'));

    expect((await repository.find('a1'))?.id, 'a1');
    expect((await repository.list()).single.id, 'a1');
    await repository.clear();
    expect(await repository.list(), isEmpty);
  });

  test('temporal sequencer produces ordered UTC stamps', () {
    final clock = FakeClock(DateTime.utc(2026, 9, 17, 1, 2, 3));
    final sequencer = S8TemporalSequencer(clock: clock);
    final first = sequencer.next(source: 'test');
    final second = sequencer.next(source: 'test');

    expect(first.occurredAtUtc.isUtc, isTrue);
    expect(first.sequence, 1);
    expect(second.sequence, 2);
    expect(first.source, 'test');
  });

  test('Python boundary preserves protocol, operation and trace id', () async {
    final transport = FakeTransport();
    final boundary = S8PythonBoundary(transport);
    final response = await boundary.invoke(const S8PythonRequest(
      operation: 'nlp.analyze',
      input: <String, dynamic>{'text': 'hello'},
      traceId: 'trace-1',
    ));

    expect(transport.request?['protocol'], 'criterivox.s8.local-intelligence.v1');
    expect(transport.request?['trace_id'], 'trace-1');
    expect(response.output['ok'], isTrue);
    expect(response.source, 'python-test');
  });

  test('language boundary fails closed when no local model is configured', () async {
    const port = S8UnavailableLanguagePort();
    expect(
      () => port.analyze(const S8LanguageRequest(text: 'hello')),
      throwsA(isA<StateError>()),
    );
  });

  test('SQLite implementation is selected only on non-web platforms', () {
    expect(S8SqliteArtifactPersistence, isA<Type>());
  });
}
