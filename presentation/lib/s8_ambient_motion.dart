import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable, asset-free motion layer for the S8 intelligence environment.
///
/// Everything is rendered from Flutter primitives. No remote images, runtime
/// services, or external visual assets are required.
class S8AmbientMotion extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const S8AmbientMotion({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  _PulseOrb(
                    left: constraints.maxWidth * .14,
                    top: constraints.maxHeight * .18,
                    size: 10,
                  ),
                  _PulseOrb(
                    left: constraints.maxWidth * .78,
                    top: constraints.maxHeight * .28,
                    size: 7,
                    delay: 700,
                  ),
                  _PulseOrb(
                    left: constraints.maxWidth * .48,
                    top: constraints.maxHeight * .10,
                    size: 5,
                    delay: 1200,
                  ),
                  Positioned.fill(
                    child: _SignalSweep()
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 900.ms)
                        .moveX(
                          begin: -constraints.maxWidth,
                          end: constraints.maxWidth,
                          duration: 5200.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PulseOrb extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final int delay;

  const _PulseOrb({
    required this.left,
    required this.top,
    required this.size,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: .35),
              blurRadius: size * 2.5,
              spreadRadius: size * .4,
            ),
          ],
        ),
      )
          .animate(delay: delay.ms, onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(.65, .65), end: const Offset(1.35, 1.35), duration: 1600.ms)
          .fade(begin: .25, end: .9, duration: 1600.ms),
    );
  }
}

class _SignalSweep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 2,
        height: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: .08),
              blurRadius: 28,
              spreadRadius: 14,
            ),
          ],
        ),
      ),
    );
  }
}
