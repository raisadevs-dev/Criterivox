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
    expect(find.text('HUMAN TERRITORY'),findsWidgets);
  });

  testWidgets('Human Territory exposes distinct decision and results destinations',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    expect(find.text('Decision Desk'),findsOneWidget);
    expect(find.text('Results Journal'),findsOneWidget);
    final decisionDeskNav = find.text('Decision Desk');
    await tester.ensureVisible(decisionDeskNav);
    await tester.tap(decisionDeskNav); await tester.pump();
    expect(find.byKey(const ValueKey('decision-desk')),findsOneWidget);
  });

  testWidgets('Collaboration Commons children are distinct destinations',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    final meetingHallNav = find.text('Meeting Hall');
    await tester.ensureVisible(meetingHallNav);
    await tester.tap(meetingHallNav); await tester.pump();
    expect(find.text('MEETING HALL'),findsOneWidget);
    final projectRoomsNav = find.text('Project Rooms');
    await tester.ensureVisible(projectRoomsNav);
    await tester.tap(projectRoomsNav); await tester.pump();
    expect(find.text('PROJECT ROOMS'),findsOneWidget);
    final sharedWorkspacesNav = find.text('Shared Workspaces');
    await tester.ensureVisible(sharedWorkspacesNav);
    await tester.tap(sharedWorkspacesNav); await tester.pump();
    expect(find.text('SHARED WORKSPACES'),findsOneWidget);
  });

  testWidgets('Character focus destination is separate from Gate 1',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:CriterivoxShell(connectRuntime:false)));
    await tester.pump();
    await tester.tap(find.text('App Introduction')); await tester.pump();
    final dharenChip = find.text('Dharen · Context Architecture');
    await tester.ensureVisible(dharenChip);
    await tester.tap(dharenChip); await tester.pump();
    expect(find.byKey(const ValueKey('character-focus-dharen')),findsOneWidget);
    expect(find.text('CHARACTER FOCUS'),findsOneWidget);
    expect(find.text('GATE 1 · CRITERIVOX CIVILIZATION'),findsNothing);
  });
}
