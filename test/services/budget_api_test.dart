import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendwise/core/network/api_client.dart';
import 'package:spendwise/model/budget.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/services/budget_api.dart';

import '../helpers/test_helpers.dart';

void main() {
  test('saveBudget POSTs new budgets and PUTs existing ones', () async {
    final methods = <String>[];
    final client = ApiClient(
      tokenStorage: InMemoryTokenStorage(),
      client: MockClient((request) async {
        methods.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({'id': '5', 'category': 'meals', 'limit': 8000}),
          200,
        );
      }),
      baseUrl: 'https://api.test',
    );
    final api = HttpBudgetApi(client);

    await api.saveBudget(
      const Budget(id: '', category: ExpenseCategory.meals, limit: 8000),
    );
    await api.saveBudget(
      const Budget(id: '5', category: ExpenseCategory.meals, limit: 9000),
    );

    expect(methods, ['POST /budgets', 'PUT /budgets/5']);
  });
}
