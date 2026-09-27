/// Temporal metadata is explicit infrastructure, not UI decoration.
class S8TemporalStamp {
  const S8TemporalStamp({
    required this.occurredAtUtc,
    this.observedAtUtc,
    this.sequence,
    this.source,
  });

  final DateTime occurredAtUtc;
  final DateTime? observedAtUtc;
  final int? sequence;
  final String? source;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'occurred_at_utc': occurredAtUtc.toUtc().toIso8601String(),
        if (observedAtUtc != null)
          'observed_at_utc': observedAtUtc!.toUtc().toIso8601String(),
        if (sequence != null) 'sequence': sequence,
        if (source != null) 'source': source,
      };
}

abstract interface class S8Clock {
  DateTime nowUtc();
}

class S8SystemClock implements S8Clock {
  const S8SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class S8TemporalSequencer {
  S8TemporalSequencer({S8Clock? clock}) : clock = clock ?? const S8SystemClock();

  final S8Clock clock;
  int _sequence = 0;

  S8TemporalStamp next({String? source}) {
    final now = clock.nowUtc();
    return S8TemporalStamp(
      occurredAtUtc: now,
      observedAtUtc: now,
      sequence: ++_sequence,
      source: source,
    );
  }
}
