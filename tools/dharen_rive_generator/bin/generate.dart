import 'package:co_rive/co_rive.dart';

final purple = RiveColor.fromArgb(0xFF8B78FF);
final deepPurple = RiveColor.fromArgb(0xFF34286F);
final pale = RiveColor.fromArgb(0xFFEAE8F8);
final dark = RiveColor.fromArgb(0xFF17143A);
final cyan = RiveColor.fromArgb(0xFF63D7C1);

void main() async {
  final file = RiveFileBuilder();
  final artboard = file.addArtboard(name: 'Dharen', width: 420, height: 520);
  final torso = artboard.addRectangle(x: 210, y: 390, shapeWidth: 170, shapeHeight: 150, cornerRadius: 55, fill: deepPurple, stroke: purple, strokeWidth: 3, shapeName: 'DharenBody');
  final head = artboard.addCircle(x: 210, y: 210, radius: 112, fill: pale, stroke: purple, strokeWidth: 9, shapeName: 'DharenHead');
  final leftEye = artboard.addEllipse(x: 170, y: 215, radiusX: 13, radiusY: 20, fill: dark, shapeName: 'LeftEye');
  final rightEye = artboard.addEllipse(x: 250, y: 215, radiusX: 13, radiusY: 20, fill: dark, shapeName: 'RightEye');
  final core = artboard.addCircle(x: 210, y: 390, radius: 27, fill: cyan, stroke: pale, strokeWidth: 3, shapeName: 'Core');
  final ring = artboard.addCircle(x: 210, y: 210, radius: 137, stroke: purple, strokeWidth: 5, shapeName: 'OrbitRing');
  final leftHand = artboard.addCircle(x: 105, y: 392, radius: 22, fill: deepPurple, stroke: purple, strokeWidth: 3, shapeName: 'LeftHand');
  final rightHand = artboard.addCircle(x: 315, y: 392, radius: 22, fill: deepPurple, stroke: purple, strokeWidth: 3, shapeName: 'RightHand');

  final idle = artboard.addAnimation('IDLE', fps: 60, durationFrames: 120, loop: LoopType.loop, animatedProperties: [
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 0, value: 210),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 60, value: 205, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 120, value: 210, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: torso, propertyKey: CoreProperty.scaleY, frame: 0, value: 1),
    AnimatedProperty(targetObjectId: torso, propertyKey: CoreProperty.scaleY, frame: 60, value: 1.025, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: torso, propertyKey: CoreProperty.scaleY, frame: 120, value: 1, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: leftEye, propertyKey: CoreProperty.scaleY, frame: 57, value: 1),
    AnimatedProperty(targetObjectId: leftEye, propertyKey: CoreProperty.scaleY, frame: 61, value: .12, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: leftEye, propertyKey: CoreProperty.scaleY, frame: 66, value: 1, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightEye, propertyKey: CoreProperty.scaleY, frame: 57, value: 1),
    AnimatedProperty(targetObjectId: rightEye, propertyKey: CoreProperty.scaleY, frame: 61, value: .12, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightEye, propertyKey: CoreProperty.scaleY, frame: 66, value: 1, interpolation: InterpolationType.cubic),
  ]);
  final receive = artboard.addAnimation('RECEIVE', fps: 60, durationFrames: 36, loop: LoopType.oneShot, animatedProperties: [
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.scaleX, frame: 0, value: .94),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.scaleX, frame: 18, value: 1.04, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.scaleX, frame: 36, value: 1, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 18, value: 1.35, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 36, value: 1, interpolation: InterpolationType.cubic),
  ]);
  final work = artboard.addAnimation('WORK', fps: 60, durationFrames: 90, loop: LoopType.loop, animatedProperties: [
    AnimatedProperty(targetObjectId: ring, propertyKey: CoreProperty.rotation, frame: 0, value: 0),
    AnimatedProperty(targetObjectId: ring, propertyKey: CoreProperty.rotation, frame: 90, value: 360, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 0, value: 210),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 45, value: 202, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 90, value: 210, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.y, frame: 0, value: 392),
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.y, frame: 45, value: 378, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.y, frame: 90, value: 392, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.y, frame: 0, value: 392),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.y, frame: 45, value: 378, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.y, frame: 90, value: 392, interpolation: InterpolationType.cubic),
  ]);
  final communicate = artboard.addAnimation('COMMUNICATE', fps: 60, durationFrames: 72, loop: LoopType.loop, animatedProperties: [
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 0, value: -4),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 24, value: 4, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 48, value: -2, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 72, value: 0, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 36, value: 1.45, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 72, value: 1, interpolation: InterpolationType.cubic),
  ]);
  final handoff = artboard.addAnimation('HANDOFF', fps: 60, durationFrames: 60, loop: LoopType.oneShot, animatedProperties: [
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.x, frame: 0, value: 105),
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.x, frame: 30, value: 82, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: leftHand, propertyKey: CoreProperty.x, frame: 60, value: 105, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.x, frame: 0, value: 315),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.x, frame: 30, value: 338, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: rightHand, propertyKey: CoreProperty.x, frame: 60, value: 315, interpolation: InterpolationType.cubic),
  ]);
  final complete = artboard.addAnimation('COMPLETE', fps: 60, durationFrames: 60, loop: LoopType.oneShot, animatedProperties: [
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 0, value: 210),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 24, value: 190, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.y, frame: 60, value: 210, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 20, value: 1.65, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 60, value: 1, interpolation: InterpolationType.cubic),
  ]);
  final warningAnim = artboard.addAnimation('WARNING', fps: 60, durationFrames: 48, loop: LoopType.loop, animatedProperties: [
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 0, value: -5),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 12, value: 5, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 24, value: -5, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 36, value: 5, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: head, propertyKey: CoreProperty.rotation, frame: 48, value: 0, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 24, value: 1.35, interpolation: InterpolationType.cubic),
    AnimatedProperty(targetObjectId: core, propertyKey: CoreProperty.scaleX, frame: 48, value: 1, interpolation: InterpolationType.cubic),
  ]);

  final states = [('IDLE', idle), ('RECEIVE', receive), ('WORK', work), ('COMMUNICATE', communicate), ('HANDOFF', handoff), ('COMPLETE', complete), ('WARNING', warningAnim)];
  artboard.addStateMachine('DharenLifecycle', inputs: [for (final state in states) TriggerInput(state.$1)], layers: [
    StateMachineLayerDef(
      name: 'DharenLifecycleLayer',
      states: [for (final state in states) AnimationStateDef(name: state.$1, animationId: state.$2)],
      transitions: [for (final state in states) TransitionDef(durationMs: 260, conditions: [TriggerCondition(state.$1)])],
    ),
  ]);

  await file.exportToFile('presentation/assets/characters/dharen.riv');
}
