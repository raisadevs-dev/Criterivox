import 'dart:convert';

/// Boundary between Flutter and locally hosted computational services.
///
/// Flutter owns presentation/orchestration contracts here. A Python service,
/// when present, owns the actual NLP/LLM/model execution. No model is silently
/// invoked by a character widget.
abstract interface class S8LocalIntelligenceTransport {
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> request);
}

class S8PythonRequest {
  const S8PythonRequest({
    required this.operation,
    required this.input,
    this.traceId,
  });

  final String operation;
  final Map<String, dynamic> input;
  final String? traceId;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'protocol': 'criterivox.s8.local-intelligence.v1',
        'operation': operation,
        'input': input,
        if (traceId != null) 'trace_id': traceId,
      };

  String toJson() => jsonEncode(toMap());
}

class S8PythonResponse {
  const S8PythonResponse({
    required this.operation,
    required this.output,
    required this.source,
    this.traceId,
  });

  final String operation;
  final Map<String, dynamic> output;
  final String source;
  final String? traceId;

  factory S8PythonResponse.fromMap(Map<String, dynamic> map) {
    return S8PythonResponse(
      operation: map['operation'] as String? ?? '',
      output: Map<String, dynamic>.from(map['output'] as Map? ?? const {}),
      source: map['source'] as String? ?? 'unknown',
      traceId: map['trace_id'] as String?,
    );
  }
}

class S8PythonBoundary {
  const S8PythonBoundary(this.transport);

  final S8LocalIntelligenceTransport transport;

  Future<S8PythonResponse> invoke(S8PythonRequest request) async {
    final response = await transport.invoke(request.toMap());
    return S8PythonResponse.fromMap(response);
  }
}

/// Capability-level contract for local NLP/LLM work. Implementations are
/// deliberately injected so deterministic S8 flows do not acquire a model
/// dependency merely because a boundary exists.
abstract interface class S8LocalLanguagePort {
  Future<S8LanguageResult> analyze(S8LanguageRequest request);
}

class S8LanguageRequest {
  const S8LanguageRequest({required this.text, this.task = 'analyze'});

  final String text;
  final String task;
}

class S8LanguageResult {
  const S8LanguageResult({
    required this.output,
    required this.provider,
    required this.model,
  });

  final String output;
  final String provider;
  final String model;
}

/// Explicit no-model implementation. It fails closed instead of pretending
/// that an NLP/LLM result exists.
class S8UnavailableLanguagePort implements S8LocalLanguagePort {
  const S8UnavailableLanguagePort();

  @override
  Future<S8LanguageResult> analyze(S8LanguageRequest request) {
    throw StateError('No local language implementation is configured.');
  }
}
