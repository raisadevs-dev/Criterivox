import 'package:flutter/foundation.dart';

/// Resolves Criterivox HTTP API calls to the Python backend rather than the
/// Flutter presentation server.
///
/// The managed launcher runs Flutter on 8080 and Python on 8000. Production
/// deployments may override the backend origin at build time.
class CriterivoxApi {
  static const backendUrl = String.fromEnvironment(
    'CRITERIVOX_BACKEND_URL',
    defaultValue: '',
  );

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    if (backendUrl.isNotEmpty) {
      return Uri.parse(backendUrl).resolve(normalized);
    }

    if (kIsWeb) {
      final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
      final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      const backendPort = String.fromEnvironment(
        'CRITERIVOX_BACKEND_PORT',
        defaultValue: '8000',
      );
      return Uri.parse('$scheme://$host:$backendPort$normalized');
    }

    return Uri.parse('http://127.0.0.1:8000$normalized');
  }
}
