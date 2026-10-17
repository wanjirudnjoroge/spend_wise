import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendwise/core/errors/app_exception.dart';
import 'package:spendwise/core/network/api_client.dart';
import 'package:spendwise/services/auth_api.dart';

import '../helpers/test_helpers.dart';

void main() {
  HttpAuthApi buildApi(http.Response Function(http.Request) handler) {
    final client = ApiClient(
      tokenStorage: InMemoryTokenStorage(),
      client: MockClient((request) async => handler(request)),
      baseUrl: 'https://api.test',
    );
    return HttpAuthApi(client);
  }

  test('login posts credentials and parses the response', () async {
    late http.Request captured;
    final api = buildApi((request) {
      captured = request;
      return http.Response(
        jsonEncode({
          'access_token': 'tok',
          'user': {'id': '1', 'name': 'Amina', 'email': 'a@b.co'},
        }),
        200,
      );
    });

    final response = await api.login(email: 'a@b.co', password: 'secret123');

    expect(captured.url.toString(), 'https://api.test/auth/login');
    expect(jsonDecode(captured.body), {
      'email': 'a@b.co',
      'password': 'secret123',
    });
    expect(response.tokens.accessToken, 'tok');
    expect(response.user.name, 'Amina');
  });

  test(
    'a 401 becomes an AuthenticationException with the server message',
    () async {
      final api = buildApi(
        (_) => http.Response(jsonEncode({'detail': 'Bad credentials'}), 401),
      );

      expect(
        api.login(email: 'a@b.co', password: 'nope'),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'message',
            'Bad credentials',
          ),
        ),
      );
    },
  );
}
