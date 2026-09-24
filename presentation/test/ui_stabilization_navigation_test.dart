import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main(){
  testWidgets('Introduction explains product, workflow, world and human territory',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.tap(find.text('App Introduction')); await tester.pump();
    expect(find.text('WHAT IS CRITERIVOX'),findsOneWidget);
    expect(find.text('WHAT CAN I DO HERE'),findsOneWidget);
    expect(find.text('HOW TO USE IT'),findsOneWidget);
    expect(find.text('WHY DOES THE WORLD EXIST?'),findsOneWidget);
    expect(find.text('WHAT IS BLOOM?'),findsOneWidget);
    expect(find.text('HUMAN TERRITORY'),findsOneWidget);
  });

  testWidgets('Human Territory exposes distinct decision and results destinations',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    expect(find.text('Decision Desk'),findsOneWidget);
    expect(find.text('Results Journal'),findsOneWidget);
    await tester.tap(find.text('Decision Desk')); await tester.pump();
    expect(find.byKey(const ValueKey('decision-desk')),findsOneWidget);
  });

  testWidgets('Collaboration Commons children are distinct destinations',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    await tester.tap(find.text('Meeting Hall')); await tester.pump();
    expect(find.text('MEETING HALL'),findsOneWidget);
    await tester.tap(find.text('Project Rooms')); await tester.pump();
    expect(find.text('PROJECT ROOMS'),findsOneWidget);
    await tester.tap(find.text('Shared Workspaces')); await tester.pump();
    expect(find.text('SHARED WORKSPACES'),findsOneWidget);
  });

  testWidgets('Character focus destination is separate from Gate 1',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    await tester.tap(find.text('App Introduction')); await tester.pump();
    await tester.tap(find.text('Dharen · Context Architecture')); await tester.pump();
    expect(find.byKey(const ValueKey('character-focus-dharen')),findsOneWidget);
    expect(find.text('CHARACTER FOCUS'),findsOneWidget);
    expect(find.text('GATE 1 · CRITERIVOX CIVILIZATION'),findsNothing);
  });
}
