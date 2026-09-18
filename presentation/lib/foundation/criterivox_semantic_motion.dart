import 'package:flutter/material.dart';

enum CriterivoxCharacterActivity { idle, receive, work, communicate, handoff, complete }
enum CriterivoxAttention { quiet, attentive, focused, busy, waiting, needsUser, completing, recovering }

@immutable
class CriterivoxSemanticMotion {
  final CriterivoxCharacterActivity activity;
  final CriterivoxAttention attention;
  const CriterivoxSemanticMotion({this.activity = CriterivoxCharacterActivity.idle, this.attention = CriterivoxAttention.quiet});

  bool get isActive => activity != CriterivoxCharacterActivity.idle;
  bool get allowsSemanticEmphasis => activity != CriterivoxCharacterActivity.idle;
}

class CriterivoxSemanticAnimation extends StatefulWidget {
  final CriterivoxSemanticMotion motion;
  final bool reducedMotion;
  final Widget child;
  const CriterivoxSemanticAnimation({super.key, required this.motion, required this.child, this.reducedMotion = false});
  @override State<CriterivoxSemanticAnimation> createState() => _CriterivoxSemanticAnimationState();
}

class _CriterivoxSemanticAnimationState extends State<CriterivoxSemanticAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (!widget.reducedMotion && widget.motion.isActive) _controller.forward();
  }
  @override void didUpdateWidget(covariant CriterivoxSemanticAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion) { _controller.stop(); return; }
    if (oldWidget.motion.activity != widget.motion.activity && widget.motion.isActive) {
      _controller.forward(from: 0);
    }
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: .72, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
    child: widget.child,
  );
}

class CriterivoxAmbientMotion extends StatefulWidget {
  final bool reducedMotion;
  final Widget child;
  const CriterivoxAmbientMotion({super.key, required this.child, this.reducedMotion = false});
  @override State<CriterivoxAmbientMotion> createState() => _CriterivoxAmbientMotionState();
}

class _CriterivoxAmbientMotionState extends State<CriterivoxAmbientMotion> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    if (!widget.reducedMotion) _controller.repeat();
  }
  @override void didUpdateWidget(covariant CriterivoxAmbientMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion) _controller.stop(); else if (oldWidget.reducedMotion) _controller.repeat();
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, child) => Opacity(opacity: .96 + (_controller.value * 0.04), child: child),
    child: widget.child,
  );
}