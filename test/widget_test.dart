import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/app.dart';

import 'helpers/test_helpers.dart';

void main() {
  testWidgets('SpendWise launches and shows the login screen', (tester) async {
    await tester.pumpWidget(buildTestApp(const SpendWiseApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
