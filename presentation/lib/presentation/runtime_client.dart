import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'foundation_residency_store.dart';
import 'presentation_state.dart';
import 'context_residency_store.dart';

class CharacterRuntimeClient {
  static const backendPort =
      String.fromEnvironment('CRITERIVOX_BACKEND_PORT', defaultValue: '8000');
  static const _retryDelay = Duration(milliseconds: 900);
  static const _maxPending = 40;
  WebSocketChannel? _channel;
  Timer? _retryTimer;
  bool _disposed = false;
  bool _connecting = false;
  bool _foundationRecoveryInFlight = false;
  final List<Map<String, dynamic>> _pending = [];
  final _states = StreamController<PresentationState>.broadcast();
  final _errors = StreamController<String>.broadcast();
  final _contextEvents = StreamController<Map<String, dynamic>>.broadcast();
  final ContextResidencyStore _contextResidency = ContextResidencyStore();
  final FoundationResidencyStore _foundationResidency =
      FoundationResidencyStore();

  Stream<PresentationState> get states => _states.stream;
  Stream<String> get errors => _errors.stream;
  Stream<Map<String, dynamic>> get contextEvents => _contextEvents.stream;
  Uri get endpoint {
    final scheme = Uri.base.scheme == 'https' ? 'wss' : 'ws';
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return Uri.parse('$scheme://$host:$backendPort/runtime/characters');
  }

  Uri get httpBase {
    final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return Uri.parse('$scheme://$host:$backendPort');
  }

  Future<void> connect() async {
    if (_disposed || _connecting || _channel != null) return;
    _connecting = true;
    _retryTimer?.cancel();
    try {
      final channel = WebSocketChannel.connect(endpoint);
      _channel = channel;
      channel.stream.listen(_handleMessage,
          onError: (_) => _connectionLost(),
          onDone: _connectionLost,
          cancelOnError: false);
      await channel.ready;
      if (_disposed) {
        await channel.sink.close();
        return;
      }
      _flushPending(channel);
      await _recoverBrowserFoundations(channel);
    } catch (error) {
      _channel = null;
      _errors.add('Runtime connection failed: $error');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _flushPending(WebSocketChannel channel) {
    while (_pending.isNotEmpty && identical(_channel, channel)) {
      channel.sink.add(jsonEncode(_pending.removeAt(0)));
    }
  }

  void _connectionLost() {
    _channel = null;
    _foundationRecoveryInFlight = false;
    if (!_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _retryTimer?.isActive == true) return;
    _retryTimer = Timer(_retryDelay, connect);
  }

  Future<void> _recoverBrowserFoundations(WebSocketChannel channel) async {
    if (_foundationRecoveryInFlight || !identical(_channel, channel)) return;
    _foundationRecoveryInFlight = true;
    try {
      final envelopes = await _foundationResidency.allEnvelopes();
      for (final envelope in envelopes) {
        if (!identical(_channel, channel)) break;
        final foundation = envelope['foundation'];
        final id =
            '${envelope['foundation_id'] ?? (foundation is Map ? foundation['foundation_id'] : '')}';
        final revision = int.tryParse('${envelope['revision'] ?? 1}') ?? 1;
        if (foundation is! Map || id.isEmpty) continue;
        channel.sink.add(jsonEncode({
          'type': 'foundation_sync',
          'schema_version': 1,
          'foundation_id': id,
          'revision': revision,
          'foundation': Map<String, dynamic>.from(foundation)
        }));
      }
    } finally {
      _foundationRecoveryInFlight = false;
    }
  }

  void requestApplication(
          {required String intent,
          required String task,
          String? taskId,
          required Map<String, dynamic> data,
          required Map<String, dynamic> context,
          required String source,
          List<String> references = const []}) =>
      _send({
        'contract_version': 1,
        'intent': intent,
        'task': task,
        if (taskId != null) 'task_id': taskId,
        'data': data,
        'context': context,
        'source': source,
        'references': references
      });
  void requestAnalysis(
          {required Map<String, dynamic> data,
          required Map<String, dynamic> context,
          required String task}) =>
      requestApplication(
          intent: 'analyze',
          task: task,
          data: data,
          context: context,
          source: 'legacy-s2');
  void sendChat(
          {String? taskId,
          required String message,
          String targetCharacter = 'syvax',
          Map<String, dynamic> data = const {},
          Map<String, dynamic> context = const {},
          List<Map<String, dynamic>> references = const []}) =>
      _send({
        'type': 'chat_message',
        'target_character': targetCharacter,
        if (taskId != null) 'task_id': taskId,
        'message': message,
        'data': data,
        'context': context,
        'references': references
      });
  void buildContext(
          {required String foundationId,
          Map<String, dynamic> userIntentContext = const {},
          String? taskId,
          bool manual = false}) =>
      _send({
        'type': 'context_build',
        'foundation_id': foundationId,
        'user_intent_context': userIntentContext,
        'manual': manual,
        if (taskId != null) 'task_id': taskId
      });
  void activateContextManually(
          {required String foundationId,
          Map<String, dynamic> userIntentContext = const {},
          String? taskId}) =>
      buildContext(
          foundationId: foundationId,
          userIntentContext: userIntentContext,
          taskId: taskId,
          manual: true);
  void signOffScratchpad({required String taskId}) =>
      _send({'type': 'scratchpad_signoff', 'task_id': taskId});
  void ingestData(
          {required List<Map<String, dynamic>> sources,
          Map<String, dynamic> suppliedContext = const {},
          List<String> recentTaskIds = const [],
          List<String> promptHistory = const []}) =>
      _send({
        'type': 'data_intake',
        'sources': sources,
        'supplied_context': suppliedContext,
        'recent_task_ids': recentTaskIds,
        'prompt_history': promptHistory
      });
  void ingestFolder(
          {required String folderPath,
          Map<String, dynamic> suppliedContext = const {},
          List<String> recentTaskIds = const [],
          List<String> promptHistory = const []}) =>
      _send({
        'type': 'data_folder',
        'folder_path': folderPath,
        'supplied_context': suppliedContext,
        'recent_task_ids': recentTaskIds,
        'prompt_history': promptHistory
      });
  void dataAction(
          {required String foundationId,
          required String action,
          List<String> candidateIds = const [],
          String recipient = 'dharen',
          Map<String, dynamic> values = const {}}) =>
      _send({
        'type': 'data_action',
        'foundation_id': foundationId,
        'action': action,
        'candidate_ids': candidateIds,
        'recipient': recipient,
        'values': values
      });

  Future<Map<String, dynamic>?> createSandbox(
          {required String foundationId,
          Map<String, dynamic> variables = const {}}) =>
      _postContext('/runtime/context/sandbox/create',
          {'foundation_id': foundationId, 'variables': variables});
  Future<Map<String, dynamic>?> runSandbox(
          {required String foundationId,
          required String sandboxId,
          Map<String, dynamic> overrides = const {},
          String? taskId}) =>
      _postContext('/runtime/context/sandbox/run', {
        'foundation_id': foundationId,
        'sandbox_id': sandboxId,
        'overrides': overrides,
        if (taskId != null) 'task_id': taskId
      });
  Future<Map<String, dynamic>?> inspectSandbox(String sandboxId) async {
    try {
      final response = await http.get(httpBase.replace(
          path: '${httpBase.path}/runtime/context/sandbox/$sandboxId'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final value =
            Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        _contextEvents.add(value);
        return value;
      }
      throw Exception(response.body);
    } catch (error) {
      _errors.add('Sandbox inspection failed: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> promoteSandbox(String sandboxId) =>
      _postContext('/runtime/context/sandbox/$sandboxId/promote', {});
  Future<Map<String, dynamic>?> discardSandbox(String sandboxId) =>
      _postContext('/runtime/context/sandbox/$sandboxId/discard', {});
  Future<Map<String, dynamic>?> _postContext(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
          httpBase.replace(path: '${httpBase.path}$path'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final value =
            Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        _contextEvents.add(value);
        return value;
      }
      throw Exception(response.body);
    } catch (error) {
      _errors.add('Context control failed: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadPersistedContext() =>
      _contextResidency.load();

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) {
      if (_pending.length < _maxPending) {
        _pending.add(Map<String, dynamic>.from(payload));
      } else {
        _errors.add(
            'Runtime queue is full; the oldest unsent action was preserved and this action was rejected.');
      }
      _scheduleReconnect();
      return;
    }
    try {
      channel.sink.add(jsonEncode(payload));
    } catch (_) {
      _channel = null;
      if (_pending.length < _maxPending) {
        _pending.add(Map<String, dynamic>.from(payload));
      }
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message.toString());
      if (decoded is Map && decoded['message_type'] == 'foundation_state') {
        final payload = Map<String, dynamic>.from(decoded);
        final foundation = payload['foundation'];
        if (foundation is Map) {
          unawaited(_foundationResidency.put(
              Map<String, dynamic>.from(foundation),
              revision: int.tryParse('${payload['revision'] ?? 1}') ?? 1));
        }
        return;
      }
      if (decoded is Map && decoded['type'] == 'foundation_sync_ack') {
        _states.add(PresentationState.fromJson(message.toString()));
        return;
      }
      if (decoded is Map && decoded['message_type'] == 'context_state') {
        final payload = Map<String, dynamic>.from(decoded);
        unawaited(_contextResidency.save(payload));
        _contextEvents.add(payload);
        return;
      }
      if (decoded is Map && decoded['message_type'] == 'context_handoff') {
        _contextEvents.add(Map<String, dynamic>.from(decoded));
        return;
      }
      _states.add(PresentationState.fromJson(message.toString()));
    } on FormatException catch (error) {
      _errors.add('Rejected runtime state: ${error.message}');
    } catch (_) {
      _errors.add('Rejected runtime state.');
    }
  }

  Future<void> disconnect() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) await channel.sink.close();
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _states.close();
    await _contextEvents.close();
    await _errors.close();
  }
}
