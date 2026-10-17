import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/screens/login_screen.dart';

import '../helpers/test_helpers.dart';

void main() {
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows validation errors for empty fields', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildTestApp(const LoginScreen()));

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows the server error for bad credentials', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildTestApp(const LoginScreen()));

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'demo@spendwise.app',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'not-the-password',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
