import 'package:flutter/material.dart';

import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';

class CharacterPresentation extends StatelessWidget {
  final PresentationState state;

  const CharacterPresentation({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(state.agentId);
    final visualState =
        CharacterVisualState.fromPresentationState(state);

    return Semantics(
      container: true,
      label: '${identity.displayName}, ${identity.role}',
      value: visualState.characterState,
      child: _CharacterCard(
        identity: identity,
        visualState: visualState,
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterIdentity identity;
  final CharacterVisualState visualState;

  const _CharacterCard({
    required this.identity,
    required this.visualState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: visualState.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      opacity: visualState.active ? 1.0 : 0.55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CharacterFigure(
            visualState: visualState,
          ),
          const SizedBox(height: 18),
          Text(
            identity.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            identity.role,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _StateBadge(
            state: visualState.characterState,
          ),
        ],
      ),
    );
  }
}

class _CharacterFigure extends StatelessWidget {
  final CharacterVisualState visualState;

  const _CharacterFigure({
    required this.visualState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configuration =
        _VisualConfiguration.fromState(
      visualState.characterState,
    );

    final prominenceScale =
        0.96 + (visualState.prominence * 0.04);

    final scale =
        configuration.scale * prominenceScale;

    return AnimatedScale(
      scale: visualState.active ? scale : 0.94,
      duration: visualState.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      child: SizedBox(
        width: 230,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 4,
              child: Container(
                width: 170,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              child: AnimatedContainer(
                duration: visualState.reducedMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                width: configuration.bodyWidth,
                height: configuration.bodyHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(52),
                ),
              ),
            ),
            Positioned(
              top: 22,
              child: AnimatedContainer(
                duration: visualState.reducedMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                width: configuration.headSize,
                height: configuration.headSize,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: configuration.borderWidth,
                  ),
                ),
                child: _CharacterFace(
                  state: visualState.characterState,
                  reducedMotion: visualState.reducedMotion,
                ),
              ),
            ),
            if (configuration.showActivityIndicator)
              Positioned(
                top: 4,
                right: 28,
                child: _ActivityIndicator(
                  state: visualState.characterState,
                  reducedMotion: visualState.reducedMotion,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CharacterFace extends StatelessWidget {
  final String state;
  final bool reducedMotion;

  const _CharacterFace({
    required this.state,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final bool emphasized =
        state == 'RECEIVE' ||
        state == 'COMMUNICATE' ||
        state == 'HANDOFF' ||
        state == 'WARNING';

    final bool complete = state == 'COMPLETE';
    final bool communicating = state == 'COMMUNICATE';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Eye(emphasized: emphasized),
            const SizedBox(width: 28),
            _Eye(emphasized: emphasized),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          width: communicating ? 38 : 30,
          height: complete ? 8 : 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: complete
                ? null
                : Border.all(width: 2),
          ),
        ),
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  final bool emphasized;

  const _Eye({
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: emphasized ? 13 : 12,
      height: emphasized ? 20 : 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ActivityIndicator extends StatelessWidget {
  final String state;
  final bool reducedMotion;

  const _ActivityIndicator({
    required this.state,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String symbol = switch (state) {
      'WORK' => '•',
      'COMMUNICATE' => '…',
      'HANDOFF' => '→',
      'WARNING' => '!',
      _ => '•',
    };

    return AnimatedOpacity(
      opacity: 1.0,
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Text(
          symbol,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _VisualConfiguration {
  final double scale;
  final double bodyWidth;
  final double bodyHeight;
  final double headSize;
  final double borderWidth;
  final bool showActivityIndicator;

  const _VisualConfiguration({
    required this.scale,
    required this.bodyWidth,
    required this.bodyHeight,
    required this.headSize,
    required this.borderWidth,
    required this.showActivityIndicator,
  });

  factory _VisualConfiguration.fromState(String state) {
    return switch (state) {
      'RECEIVE' => const _VisualConfiguration(
          scale: 1.04,
          bodyWidth: 124,
          bodyHeight: 134,
          headSize: 138,
          borderWidth: 6,
          showActivityIndicator: false,
        ),
      'WORK' => const _VisualConfiguration(
          scale: 1.02,
          bodyWidth: 122,
          bodyHeight: 136,
          headSize: 134,
          borderWidth: 5,
          showActivityIndicator: true,
        ),
      'COMMUNICATE' => const _VisualConfiguration(
          scale: 1.03,
          bodyWidth: 124,
          bodyHeight: 132,
          headSize: 136,
          borderWidth: 6,
          showActivityIndicator: true,
        ),
      'HANDOFF' => const _VisualConfiguration(
          scale: 1.05,
          bodyWidth: 126,
          bodyHeight: 136,
          headSize: 136,
          borderWidth: 6,
          showActivityIndicator: true,
        ),
      'COMPLETE' => const _VisualConfiguration(
          scale: 1.01,
          bodyWidth: 120,
          bodyHeight: 130,
          headSize: 134,
          borderWidth: 5,
          showActivityIndicator: false,
        ),
      'WARNING' => const _VisualConfiguration(
          scale: 1.06,
          bodyWidth: 126,
          bodyHeight: 138,
          headSize: 140,
          borderWidth: 7,
          showActivityIndicator: true,
        ),
      _ => const _VisualConfiguration(
          scale: 1.0,
          bodyWidth: 118,
          bodyHeight: 128,
          headSize: 132,
          borderWidth: 5,
          showActivityIndicator: false,
        ),
    };
  }
}

class _StateBadge extends StatelessWidget {
  final String state;

  const _StateBadge({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        state.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}