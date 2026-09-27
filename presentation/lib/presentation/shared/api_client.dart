import 'package:flutter/foundation.dart';

class CriterivoxApi {
  static const backendUrl = String.fromEnvironment('CRITERIVOX_BACKEND_URL', defaultValue: '');
  static const backendPort = String.fromEnvironment('CRITERIVOX_BACKEND_PORT', defaultValue: '8000');

  static Uri _origin({required bool websocket}) {
    if (backendUrl.isNotEmpty) {
      final parsed = Uri.parse(backendUrl);
      if (!websocket) return parsed;
      return parsed.replace(scheme: parsed.scheme == 'https' ? 'wss' : 'ws');
    }
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      final scheme = Uri.base.scheme == 'https' ? (websocket ? 'wss' : 'https') : (websocket ? 'ws' : 'http');
      return Uri.parse(scheme + '://' + host + ':' + backendPort);
    }
    return Uri.parse((websocket ? 'ws' : 'http') + '://127.0.0.1:' + backendPort);
  }

  static Uri uri(String path) => _origin(websocket: false).resolve(path.startsWith('/') ? path : '/' + path);
  static Uri websocketUri(String path) => _origin(websocket: true).resolve(path.startsWith('/') ? path : '/' + path);
}