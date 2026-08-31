import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_visual_state.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  group('CharacterVisualState', () {
    test('maps active IDLE state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'IDLE',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.agentId, 'Dharen');
      expect(visual.characterState, 'IDLE');
      expect(visual.isActive, isTrue);
      expect(visual.isIdle, isTrue);
      expect(visual.prominence, 0.25);
    });

    test('maps active WORK state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'WORK',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isActive, isTrue);
      expect(visual.isWorking, isTrue);
      expect(visual.isCommunicating, isFalse);
      expect(visual.prominence, 0.75);
    });

    test('maps RECEIVE state correctly', () {
      const state = PresentationState(
        agentId: 'Vivren',
        characterState: 'RECEIVE',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.agentId, 'Vivren');
      expect(visual.isReceiving, isTrue);
      expect(visual.prominence, 0.75);
    });

    test('maps COMMUNICATE state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'COMMUNICATE',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isCommunicating, isTrue);
      expect(visual.isWorking, isFalse);
      expect(visual.prominence, 0.75);
    });

    test('maps HANDOFF state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'HANDOFF',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isHandingOff, isTrue);
      expect(visual.prominence, 0.75);
    });

    test('maps COMPLETE state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'COMPLETE',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isComplete, isTrue);
      expect(visual.prominence, 0.5);
    });

    test('maps WARNING state correctly', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'WARNING',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isWarning, isTrue);
      expect(visual.requiresUserAttention, isTrue);
      expect(visual.prominence, 1.0);
    });

    test('inactive character has zero prominence', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'WORK',
        active: false,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.isActive, isFalse);
      expect(visual.prominence, 0.0);
      expect(visual.hasMotion, isFalse);
    });

    test('reduced motion is preserved', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'WORK',
        active: true,
        reducedMotion: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.reducedMotion, isTrue);
      expect(visual.hasMotion, isFalse);
      expect(visual.isWorking, isTrue);
    });

    test('normal active state allows motion', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'WORK',
        active: true,
        reducedMotion: false,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.hasMotion, isTrue);
    });

    test('NEEDS_USER requires attention', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'NEEDS_USER',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.requiresUserAttention, isTrue);
      expect(visual.prominence, 1.0);
    });

    test('unknown state remains safe and low prominence', () {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'UNKNOWN_STATE',
        active: true,
      );

      final visual =
          CharacterVisualState.fromPresentationState(state);

      expect(visual.characterState, 'UNKNOWN_STATE');
      expect(visual.prominence, 0.25);
      expect(visual.isActive, isTrue);
    });
  });
}