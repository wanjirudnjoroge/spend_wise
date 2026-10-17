import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/auth_exception.dart';
import 'package:spendwise/repositories/auth_repository.dart';
import 'package:spendwise/services/mock_apis.dart';

import '../helpers/test_helpers.dart';

void main() {
  late InMemoryTokenStorage storage;
  late AuthRepository repository;

  setUp(() {
    storage = InMemoryTokenStorage();
    repository = AuthRepository(
      api: MockAuthApi(latency: Duration.zero),
      tokenStorage: storage,
    );
  });

  test('login stores the access token and returns the user', () async {
    final user = await repository.login(
      email: 'demo@spendwise.app',
      password: 'password123',
    );

    expect(user.name, 'Amina Wanjiru');
    expect(storage.access, isNotNull);
  });

  test('wrong password throws AuthException and stores nothing', () async {
    await expectLater(
      repository.login(email: 'demo@spendwise.app', password: 'wrongpass1'),
      throwsA(isA<AuthException>()),
    );
    expect(storage.access, isNull);
  });

  test('signup then restoreSession returns the same user', () async {
    final created = await repository.signup(
      name: 'Brian Otieno',
      email: 'brian@example.com',
      password: 'longenough1',
    );
    final restored = await repository.restoreSession();

    expect(restored?.id, created.id);
  });

  test('duplicate signup is rejected', () async {
    await expectLater(
      repository.signup(
        name: 'Copy',
        email: 'demo@spendwise.app',
        password: 'longenough1',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('restoreSession returns null without a token', () async {
    expect(await repository.restoreSession(), isNull);
  });

  test('an expired token is cleared on restoreSession', () async {
    storage.access = 'stale-token';

    expect(await repository.restoreSession(), isNull);
    expect(storage.access, isNull);
  });

  test('logout clears the tokens', () async {
    await repository.login(
      email: 'demo@spendwise.app',
      password: 'password123',
    );
    await repository.logout();

    expect(storage.access, isNull);
  });
}
