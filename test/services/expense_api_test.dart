import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendwise/core/errors/app_exception.dart';
import 'package:spendwise/core/network/api_client.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/services/expense_api.dart';

import '../helpers/test_helpers.dart';

void main() {
  final storage = InMemoryTokenStorage()..access = 'token-123';

  HttpExpenseApi buildApi(http.Response Function(http.Request) handler) {
    final client = ApiClient(
      tokenStorage: storage,
      client: MockClient((request) async => handler(request)),
      baseUrl: 'https://api.test',
    );
    return HttpExpenseApi(client);
  }

  Map<String, dynamic> expenseJson(String id) => {
    'id': id,
    'title': 'Taxi',
    'amount': 850,
    'category': 'travel',
    'date': '2026-10-01T09:30:00.000',
  };

  test(
    'fetchExpenses parses a JSON array and sends the bearer token',
    () async {
      late http.Request captured;
      final api = buildApi((request) {
        captured = request;
        return http.Response(
          jsonEncode([expenseJson('1'), expenseJson('2')]),
          200,
        );
      });

      final expenses = await api.fetchExpenses();

      expect(expenses.length, 2);
      expect(captured.headers['Authorization'], 'Bearer token-123');
    },
  );

  test('updateStatus sends a PATCH with the new status', () async {
    late http.Request captured;
    final api = buildApi((request) {
      captured = request;
      return http.Response(
        jsonEncode({...expenseJson('9'), 'status': 'approved'}),
        200,
      );
    });

    final updated = await api.updateStatus('9', ExpenseStatus.approved);

    expect(captured.method, 'PATCH');
    expect(captured.url.path, '/expenses/9');
    expect(jsonDecode(captured.body), {'status': 'approved'});
    expect(updated.status, ExpenseStatus.approved);
  });

  test('server errors become ServerException', () async {
    final api = buildApi((_) => http.Response('{}', 500));

    expect(api.fetchExpenses(), throwsA(isA<ServerException>()));
  });
}
