import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'presentation_state.dart';

class CharacterRuntimeClient {
  static const backendPort = String.fromEnvironment(
    'CRITERIVOX_BACKEND_PORT',
    defaultValue: '8000',
  );

  WebSocketChannel? _channel;
  final _states = StreamController<PresentationState>.broadcast();
  final _errors = StreamController<String>.broadcast();

  Stream<PresentationState> get states => _states.stream;
  Stream<String> get errors => _errors.stream;

  Uri get endpoint {
    final scheme = Uri.base.scheme == 'https' ? 'wss' : 'ws';
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return Uri.parse('$scheme://$host:$backendPort/runtime/characters');
  }

  Future<void> connect() async {
    await disconnect();
    try {
      final channel = WebSocketChannel.connect(endpoint);
      _channel = channel;
      await channel.ready;
      channel.stream.listen(
        _handleMessage,
        onError: (Object error) => _errors.add('Runtime connection error: $error'),
        onDone: () => _channel = null,
        cancelOnError: false,
      );
    } catch (error) {
      _errors.add('Unable to connect to Python runtime.');
    }
  }

  void requestApplication({
    required String intent,
    required String task,
    required Map<String, dynamic> data,
    required Map<String, dynamic> context,
    required String source,
  }) {
    final channel = _channel;
    if (channel == null) {
      _errors.add('Python runtime is not connected.');
      return;
    }
    channel.sink.add(jsonEncode({
      'contract_version': 1,
      'intent': intent,
      'task': task,
      'data': data,
      'context': context,
      'source': source,
    }));
  }

  void requestAnalysis({
    required Map<String, dynamic> data,
    required Map<String, dynamic> context,
    required String task,
  }) {
    requestApplication(
      intent: 'analyze',
      task: task,
      data: data,
      context: context,
      source: 'legacy-s2',
    );
  }

  void _handleMessage(dynamic message) {
    try {
      final state = PresentationState.fromJson(message.toString());
      _states.add(state);
    } on FormatException catch (error) {
      _errors.add('Rejected runtime state: ${error.message}');
    } catch (_) {
      _errors.add('Rejected runtime state.');
    }
  }

  Future<void> disconnect() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) await channel.sink.close();
  }

  Future<void> dispose() async {
    await disconnect();
    await _states.close();
    await _errors.close();
  }
}
