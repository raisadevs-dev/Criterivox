import 'package:flutter/material.dart';

enum CriterivoxTransitionKind { worldToHome, homeToRoom, roomToRoom, characterFocus, artifact, handoff, intervention, completion }

class CriterivoxSceneTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final CriterivoxTransitionKind kind;
  const CriterivoxSceneTransition({super.key, required this.animation, required this.child, required this.kind});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
    final offset = switch (kind) {
      CriterivoxTransitionKind.worldToHome || CriterivoxTransitionKind.homeToRoom => 20.0,
      CriterivoxTransitionKind.characterFocus => 10.0,
      _ => 6.0,
    };
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, offset / 100), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

class CriterivoxReducedMotionTransition extends StatelessWidget {
  final bool reducedMotion;
  final Widget child;
  const CriterivoxReducedMotionTransition({super.key, required this.reducedMotion, required this.child});
  @override Widget build(BuildContext context) => reducedMotion ? child : child;
}