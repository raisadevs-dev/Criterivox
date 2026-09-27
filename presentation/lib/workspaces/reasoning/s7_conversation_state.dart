import 's7_nlp_intents.dart';

class S7ConversationTurn {
  const S7ConversationTurn({
    required this.actor,
    required this.text,
    required this.intent,
    required this.target,
    required this.confidence,
  });

  final String actor;
  final String text;
  final S7NlpIntent intent;
  final String? target;
  final double confidence;
}

/// Mutable context for one local S7 conversation session.
///
/// This is interaction context only. It is not a source of computational
/// truth and should never replace authoritative S7 artifacts/events.
class S7ConversationState {
  S7NlpIntent? activeIntent;
  String? activeTarget;
  String? activeArtifactId;
  String? activeHypothesisId;
  String? activeClaimId;
  bool awaitingClarification = false;
  bool awaitingConfirmation = false;

  final List<S7ConversationTurn> history = <S7ConversationTurn>[];

  void remember(S7ConversationTurn turn) {
    history.add(turn);
    if (history.length > 30) {
      history.removeAt(0);
    }
    activeIntent = turn.intent;
    if (turn.target != null) activeTarget = turn.target;
    awaitingClarification = false;
  }

  String? get lastHumanTarget => history.reversed
      .where((turn) => turn.actor.toLowerCase() == 'human' && turn.target != null)
      .map((turn) => turn.target)
      .firstOrNull;

  void clearPending() {
    awaitingClarification = false;
    awaitingConfirmation = false;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
