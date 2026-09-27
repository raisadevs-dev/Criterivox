import 'package:flutter/material.dart';

enum CriterivoxWorld {
  civilization,
  residence,
}

enum CriterivoxSceneLevel {
  world,
  home,
  room,
}

@immutable
class CriterivoxSceneDescriptor {
  final CriterivoxWorld world;
  final CriterivoxSceneLevel level;
  final String id;
  final String title;
  final String? subtitle;

  const CriterivoxSceneDescriptor({
    required this.world,
    required this.level,
    required this.id,
    required this.title,
    this.subtitle,
  });
}

abstract class CriterivoxSceneLayer
    extends StatelessWidget {
  final bool visible;

  const CriterivoxSceneLayer({
    super.key,
    this.visible = true,
  });

  Widget buildLayer(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return buildLayer(context);
  }
}

class CriterivoxScene extends StatelessWidget {
  final CriterivoxSceneDescriptor descriptor;

  final List<Widget> environment;
  final List<Widget> character;
  final List<Widget> lighting;
  final List<Widget> information;
  final List<Widget> artifact;
  final List<Widget> interaction;
  final List<Widget> transition;

  const CriterivoxScene({
    super.key,
    required this.descriptor,
    this.environment = const [],
    this.character = const [],
    this.lighting = const [],
    this.information = const [],
    this.artifact = const [],
    this.interaction = const [],
    this.transition = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${descriptor.title}, '
          '${descriptor.level.name} scene',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedWidth =
              constraints.hasBoundedWidth;
          final hasBoundedHeight =
              constraints.hasBoundedHeight;

          if (!hasBoundedWidth &&
              !hasBoundedHeight) {
            return _buildWithFallbackSize(
              context,
              width: 320,
              height: 320,
            );
          }

          if (!hasBoundedHeight) {
            final width =
                constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                : 320.0;

            return _buildWithFallbackSize(
              context,
              width: width,
              height: _heightForWidth(width),
            );
          }

          if (!hasBoundedWidth) {
            final height =
                constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : 320;

            return _buildWithFallbackSize(
              context,
              width: _widthForHeight(height.toDouble()),
              height: height.toDouble(),
            );
          }

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: _layers(),
          );
        },
      ),
    );
  }

  double _heightForWidth(double width) {
    final safeWidth = width.clamp(260.0, 1600.0).toDouble();
    return (safeWidth * .62).clamp(
      220.0,
      720.0,
    ).toDouble();
  }

  double _widthForHeight(double height) {
    final safeHeight = height.clamp(
      220.0,
      720.0,
    ).toDouble();

    return (safeHeight / .62).clamp(
      260.0,
      1600.0,
    ).toDouble();
  }

  Widget _buildWithFallbackSize(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: _layers(),
    );
  }

  Widget _layers() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _SceneLayer(
          children: environment,
        ),
        _SceneLayer(
          children: character,
        ),
        _SceneLayer(
          children: lighting,
        ),
        _SceneLayer(
          children: information,
        ),
        _SceneLayer(
          children: artifact,
        ),
        _SceneLayer(
          children: interaction,
        ),
        _SceneLayer(
          children: transition,
        ),
      ],
    );
  }
}

class _SceneLayer extends StatelessWidget {
  final List<Widget> children;

  const _SceneLayer({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: children,
    );
  }
}

class CriterivoxEnvironmentLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxEnvironmentLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return child;
  }
}

class CriterivoxCharacterLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxCharacterLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return child;
  }
}

class CriterivoxLightingLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxLightingLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return IgnorePointer(
      child: child,
    );
  }
}

class CriterivoxInformationLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxInformationLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return child;
  }
}

class CriterivoxArtifactLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxArtifactLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return child;
  }
}

class CriterivoxInteractionLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxInteractionLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return child;
  }
}

class CriterivoxTransitionLayer
    extends CriterivoxSceneLayer {
  final Widget child;

  const CriterivoxTransitionLayer({
    super.key,
    required this.child,
    super.visible,
  });

  @override
  Widget buildLayer(BuildContext context) {
    return IgnorePointer(
      child: child,
    );
  }
}