import 'package:flutter/material.dart';

enum CriterivoxWorld { civilization, residence }
enum CriterivoxSceneLevel { world, home, room }

@immutable
class CriterivoxSceneDescriptor {
  final CriterivoxWorld world;
  final CriterivoxSceneLevel level;
  final String id;
  final String title;
  final String? subtitle;
  const CriterivoxSceneDescriptor({
    required this.world, required this.level, required this.id,
    required this.title, this.subtitle,
  });
}

abstract class CriterivoxSceneLayer extends StatelessWidget {
  final bool visible;
  const CriterivoxSceneLayer({super.key, this.visible = true});
  Widget buildLayer(BuildContext context);
  @override
  Widget build(BuildContext context) => visible ? buildLayer(context) : const SizedBox.shrink();
}

class CriterivoxScene extends StatelessWidget {
  final CriterivoxSceneDescriptor descriptor;
  final List<Widget> environment, character, lighting, information, artifact, interaction, transition;
  const CriterivoxScene({
    super.key, required this.descriptor,
    this.environment = const [], this.character = const [], this.lighting = const [],
    this.information = const [], this.artifact = const [], this.interaction = const [],
    this.transition = const [],
  });

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '${descriptor.title}, ${descriptor.level.name} scene',
    child: Stack(fit: StackFit.expand, children: [
      _SceneLayer(children: environment),
      _SceneLayer(children: character),
      _SceneLayer(children: lighting),
      _SceneLayer(children: information),
      _SceneLayer(children: artifact),
      _SceneLayer(children: interaction),
      _SceneLayer(children: transition),
    ]),
  );
}

class _SceneLayer extends StatelessWidget {
  final List<Widget> children;
  const _SceneLayer({required this.children});
  @override Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: children);
}

class CriterivoxEnvironmentLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxEnvironmentLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => child;
}
class CriterivoxCharacterLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxCharacterLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => child;
}
class CriterivoxLightingLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxLightingLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => IgnorePointer(child: child);
}
class CriterivoxInformationLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxInformationLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => child;
}
class CriterivoxArtifactLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxArtifactLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => child;
}
class CriterivoxInteractionLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxInteractionLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => child;
}
class CriterivoxTransitionLayer extends CriterivoxSceneLayer {
  final Widget child;
  const CriterivoxTransitionLayer({super.key, required this.child, super.visible});
  @override Widget buildLayer(BuildContext context) => IgnorePointer(child: child);
}