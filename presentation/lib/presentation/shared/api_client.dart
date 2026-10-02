class CriterivoxApi {
  static const backendUrl = String.fromEnvironment(
    'CRITERIVOX_BACKEND_URL',
    defaultValue: '',
  );
  static const backendHost = String.fromEnvironment(
    'CRITERIVOX_BACKEND_HOST',
    defaultValue: '127.0.0.1',
  );
  static const backendPort = String.fromEnvironment(
    'CRITERIVOX_BACKEND_PORT',
    defaultValue: '8000',
  );

  static Uri _origin({required bool websocket}) {
    if (backendUrl.isNotEmpty) {
      final parsed = Uri.parse(backendUrl);
      if (!websocket) return parsed;
      final socketScheme = switch (parsed.scheme.toLowerCase()) {
        'https' || 'wss' => 'wss',
        _ => 'ws',
      };
      return parsed.replace(scheme: socketScheme);
    }

    final scheme = websocket ? 'ws' : 'http';
    final host = backendHost.isEmpty ? '127.0.0.1' : backendHost;
    return Uri.parse('$scheme://$host:$backendPort');

  }

  /// Resolve an API path without discarding a configured backend path prefix.
  static Uri _resolve(String path, {required bool websocket}) {
    final base = _origin(websocket: websocket);
    final normalized = path.startsWith('/') ? path : '/$path';
    final basePath = base.path == '/'
        ? ''
        : base.path.replaceFirst(RegExp(r'/+$'), '');
    return base.replace(path: '$basePath$normalized');
  }

  static Uri uri(String path) => _resolve(path, websocket: false);
  static Uri websocketUri(String path) => _resolve(path, websocket: true);
}