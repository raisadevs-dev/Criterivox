
import 'package:flutter/material.dart';

import 's8_ambient_motion.dart';

class S8AnimatedEnvironment extends StatelessWidget {
  final Widget? child;
  final bool motionEnabled;

  const S8AnimatedEnvironment({
    super.key,
    this.child,
    this.motionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return S8AmbientMotion(
      enabled: motionEnabled,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
