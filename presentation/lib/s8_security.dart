import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 's8_presentation_state.dart';

/// Stable canonical representation used for integrity checks.
/// Ordering is fixed so the same artifact produces the same digest.
String s8CanonicalArtifact(S8ArtifactSummary artifact) => jsonEncode(<String, dynamic>{
      'artifact_id': artifact.id,
      'kind': artifact.kind,
      'title': artifact.title,
      'status': artifact.status,
      'parents': artifact.parents,
      'uncertainty': artifact.uncertainty,
      'contradictions': artifact.contradictions,
      'integrity': artifact.integrity,
      'temporal': artifact.temporal,
    });

String s8Sha256(S8ArtifactSummary artifact) =>
    sha256.convert(utf8.encode(s8CanonicalArtifact(artifact))).toString();

class S8IntegrityReceipt {
  final String artifactId;
  final String algorithm;
  final String digest;
  final DateTime createdAt;

  const S8IntegrityReceipt({
    required this.artifactId,
    required this.algorithm,
    required this.digest,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'artifact_id': artifactId,
        'algorithm': algorithm,
        'digest': digest,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class S8IntegrityService {
  const S8IntegrityService();

  S8IntegrityReceipt seal(S8ArtifactSummary artifact, {DateTime? now}) =>
      S8IntegrityReceipt(
        artifactId: artifact.id,
        algorithm: 'SHA-256',
        digest: s8Sha256(artifact),
        createdAt: (now ?? DateTime.now()).toUtc(),
      );

  bool verify(S8ArtifactSummary artifact, S8IntegrityReceipt receipt) =>
      receipt.artifactId == artifact.id &&
      receipt.algorithm == 'SHA-256' &&
      receipt.digest == s8Sha256(artifact);
}

/// Explicit authorization boundary. It is intentionally tiny: UI actions
/// can request authority, but cannot silently grant it to domain computation.
class S8AuthorizationService {
  final Map<String, Set<String>> _grants = <String, Set<String>>{};

  void grant({required String actorId, required String capability}) {
    if (actorId.trim().isEmpty || capability.trim().isEmpty) {
      throw ArgumentError('actorId and capability are required');
    }
    _grants.putIfAbsent(actorId, () => <String>{}).add(capability);
  }

  void revoke({required String actorId, required String capability}) {
    _grants[actorId]?.remove(capability);
  }

  bool isAuthorized({required String actorId, required String capability}) =>
      _grants[actorId]?.contains(capability) ?? false;
}

/// Append-only security audit records. Consumers receive immutable snapshots.
class S8SecurityAudit {
  final List<S8SecurityAuditEvent> _events = <S8SecurityAuditEvent>[];

  List<S8SecurityAuditEvent> get events => List.unmodifiable(_events);

  void record({
    required String actorId,
    required String action,
    required String targetId,
    bool authorized = false,
  }) {
    if (actorId.trim().isEmpty || action.trim().isEmpty || targetId.trim().isEmpty) {
      throw ArgumentError('actorId, action and targetId are required');
    }
    _events.add(S8SecurityAuditEvent(
      actorId: actorId,
      action: action,
      targetId: targetId,
      authorized: authorized,
      at: DateTime.now().toUtc(),
    ));
  }
}

class S8SecurityAuditEvent {
  final String actorId;
  final String action;
  final String targetId;
  final bool authorized;
  final DateTime at;

  const S8SecurityAuditEvent({
    required this.actorId,
    required this.action,
    required this.targetId,
    required this.authorized,
    required this.at,
  });
}

// Keeps the imported type explicit for platforms where Uint8List is surfaced
// by crypto implementations.
Uint8List s8Utf8(String value) => Uint8List.fromList(utf8.encode(value));
