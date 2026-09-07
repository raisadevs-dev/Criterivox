import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'character_visual_state.dart';

/// SVG character renderer for Dharen.
///
/// Python/application state remains authoritative. Flutter maps semantic
/// states to presentation motion while Glaxnimate-authored SVG artwork remains
/// a pure visual asset.
class DharenSvgLayer extends StatelessWidget {
  final CharacterVisualState visualState;

  const DharenSvgLayer({super.key, required this.visualState});

  @override
  Widget build(BuildContext context) {
    final state = visualState.characterState;
    final working = state == 'WORK';
    final communicating = state == 'COMMUNICATE';
    final warning = state == 'WARNING';
    final complete = state == 'COMPLETE';
    final duration = visualState.reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 420);

    return Semantics(
      label: 'Dharen animated SVG character',
      value: state,
      child: SizedBox(
        width: 238,
        height: 286,
        child: AnimatedScale(
          scale: visualState.active ? 1 : .94,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedRotation(
            turns: working || communicating ? .015 : 0,
            duration: duration,
            curve: Curves.easeInOut,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 5,
                  child: AnimatedContainer(
                    duration: duration,
                    width: working || warning ? 200 : 184,
                    height: 34,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      gradient: RadialGradient(colors: [
                        Color(0x663F35B6),
                        Color(0x221B174B),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  child: AnimatedRotation(
                    turns: working || communicating ? .01 : 0,
                    duration: duration,
                    child: SvgPicture.asset(
                      'assets/characters/dharen.svg',
                      width: 166,
                      height: 230,
                      fit: BoxFit.contain,
                      semanticsLabel: 'Dharen character artwork',
                    ),
                  ),
                ),
                if (working || communicating || warning)
                  Positioned(
                    top: 10,
                    right: 19,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF17143A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x554D43BA), blurRadius: 15),
                        ],
                      ),
                      child: Text(
                        warning ? '!' : communicating ? '…' : '•',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                if (complete)
                  const Positioned(
                    top: 92,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: Color(0xFF5B4FE4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
