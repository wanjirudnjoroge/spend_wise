import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/screens/signup_screen.dart';

import '../helpers/test_helpers.dart';

void main() {
  testWidgets('rejects mismatched passwords', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildTestApp(const SignupScreen()));

    await tester.enterText(find.byKey(const Key('name_field')), 'Brian Otieno');
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'brian@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'longenough1',
    );
    await tester.enterText(
      find.byKey(const Key('confirm_field')),
      'different123',
    );
    await tester.tap(find.byKey(const Key('signup_button')));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
