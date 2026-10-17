import '../model/budget.dart';
import '../services/budget_api.dart';

class BudgetRepository {
  BudgetRepository(this._api);

  final BudgetApi _api;

  Future<List<Budget>> fetchBudgets() => _api.fetchBudgets();

  Future<Budget> saveBudget(Budget budget) => _api.saveBudget(budget);

  Future<void> deleteBudget(String id) => _api.deleteBudget(id);
}
