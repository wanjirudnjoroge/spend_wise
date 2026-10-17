import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/repositories/auth_repository.dart';
import 'package:spendwise/services/mock_apis.dart';
import 'package:spendwise/view_model/auth_view.dart';

import '../helpers/test_helpers.dart';

void main() {
  late AuthViewModel vm;

  setUp(() {
    vm = AuthViewModel(
      AuthRepository(
        api: MockAuthApi(latency: Duration.zero),
        tokenStorage: InMemoryTokenStorage(),
      ),
    );
  });

  test(
    'starts unknown and becomes unauthenticated without a session',
    () async {
      expect(vm.status, AuthStatus.unknown);
      await vm.restoreSession();
      expect(vm.status, AuthStatus.unauthenticated);
    },
  );

  test('successful login authenticates', () async {
    final ok = await vm.login(
      email: 'demo@spendwise.app',
      password: 'password123',
    );

    expect(ok, isTrue);
    expect(vm.status, AuthStatus.authenticated);
    expect(vm.user?.firstName, 'Amina');
    expect(vm.error, isNull);
  });

  test('failed login exposes an error and stays signed out', () async {
    final ok = await vm.login(
      email: 'demo@spendwise.app',
      password: 'wrong-password',
    );

    expect(ok, isFalse);
    expect(vm.error, 'Incorrect email or password.');
    expect(vm.status, isNot(AuthStatus.authenticated));
    expect(vm.isLoading, isFalse);
  });

  test('logout returns to unauthenticated', () async {
    await vm.login(email: 'demo@spendwise.app', password: 'password123');
    await vm.logout();

    expect(vm.status, AuthStatus.unauthenticated);
    expect(vm.user, isNull);
  });
}
