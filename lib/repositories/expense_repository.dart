import '../model/expense.dart';
import '../services/expense_api.dart';

class ExpenseRepository {
  ExpenseRepository(this._api);

  final ExpenseApi _api;

  Future<List<Expense>> fetchExpenses() => _api.fetchExpenses();

  Future<Expense> createExpense(Expense draft) => _api.createExpense(draft);

  Future<Expense> updateStatus(String id, ExpenseStatus status) =>
      _api.updateStatus(id, status);

  Future<void> deleteExpense(String id) => _api.deleteExpense(id);
}
