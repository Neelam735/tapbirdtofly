import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tapbirdtofly/main.dart';

void main() {
  testWidgets('App launches with waiting overlay', (tester) async {
    await tester.pumpWidget(const TapBirdApp());
    await tester.pump();

    expect(find.text('Tap Bird to Fly'), findsOneWidget);
    expect(find.text('Tap anywhere to start'), findsOneWidget);
  });

  testWidgets('Tap dismisses waiting overlay', (tester) async {
    await tester.pumpWidget(const TapBirdApp());
    await tester.pump();

    await tester.tap(find.byType(MaterialApp));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Tap Bird to Fly'), findsNothing);
  });
}
