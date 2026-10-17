import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/app.dart';

import '../helpers/test_helpers.dart';

void main() {
  testWidgets('sign in with the demo account shows the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildTestApp(const SpendWiseApp()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'demo@spendwise.app',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Amina'), findsOneWidget);
    expect(find.text('Remaining budget'), findsOneWidget);

    expect(find.text('KES 37,500'), findsOneWidget);
  });
}
