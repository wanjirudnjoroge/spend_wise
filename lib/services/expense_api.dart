import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../model/expense.dart';

abstract class ExpenseApi {
  Future<List<Expense>> fetchExpenses();
  Future<Expense> createExpense(Expense draft);
  Future<Expense> updateStatus(String id, ExpenseStatus status);
  Future<void> deleteExpense(String id);
}

class HttpExpenseApi implements ExpenseApi {
  HttpExpenseApi(this._client);

  final ApiClient _client;

  @override
  Future<List<Expense>> fetchExpenses() async {
    final json = await _client.get(AppConstants.expensesEndpoint);
    final items = json['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Expense> createExpense(Expense draft) async {
    final json = await _client.post(
      AppConstants.expensesEndpoint,
      body: draft.toJson(),
    );
    return Expense.fromJson(json);
  }

  @override
  Future<Expense> updateStatus(String id, ExpenseStatus status) async {
    final json = await _client.patch(
      '${AppConstants.expensesEndpoint}/$id',
      body: {'status': status.name},
    );
    return Expense.fromJson(json);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _client.delete('${AppConstants.expensesEndpoint}/$id');
  }
}
