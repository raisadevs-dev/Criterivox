import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Crops one state from the supplied six-frame character sheet SVG.
/// Frame order: IDLE, RECEIVE, WORK, COMMUNICATE, HANDOFF, COMPLETE.
class CharacterFrame extends StatelessWidget {
  final String asset;
  final int index;
  final double width;
  final double height;

  const CharacterFrame({
    super.key,
    required this.asset,
    required this.index,
    this.width = 64,
    this.height = 94,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = index.clamp(0, 5);
    final column = safeIndex % 3;
    final row = safeIndex ~/ 3;
    final scale = width / 64;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Transform.translate(
          offset: Offset(-column * width, -row * height),
          child: Transform.scale(
            alignment: Alignment.topLeft,
            scale: scale,
            child: SvgPicture.asset(
              asset,
              width: 192,
              height: 188,
              fit: BoxFit.fill,
              semanticsLabel: 'Character animation frame',
            ),
          ),
        ),
      ),
    );
  }
}
