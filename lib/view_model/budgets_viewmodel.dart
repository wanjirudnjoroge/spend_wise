import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/utils/safe_notifier.dart';
import '../model/budget.dart';
import '../model/expense.dart';
import '../repositories/budget_repository.dart';

class BudgetsViewModel extends ChangeNotifier with SafeNotifier {
  BudgetsViewModel(this._repository);

  final BudgetRepository _repository;

  List<Budget> _budgets = const [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalLimit =>
      _budgets.fold(0.0, (sum, budget) => sum + budget.limit);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _budgets = await _repository.fetchBudgets();
    } catch (error) {
      _error = errorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setBudget(ExpenseCategory category, double limit) async {
    if (limit <= 0) {
      _error = 'Budget must be greater than 0.';
      notifyListeners();
      return false;
    }
    try {
      final existing = _budgets
          .where((budget) => budget.category == category)
          .firstOrNull;
      final saved = await _repository.saveBudget(
        Budget(id: existing?.id ?? '', category: category, limit: limit),
      );
      _budgets = existing == null
          ? [..._budgets, saved]
          : [
              for (final budget in _budgets)
                budget.id == existing.id ? saved : budget,
            ];
      _error = null;
      return true;
    } catch (error) {
      _error = errorMessage(error);
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> removeBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      _budgets = _budgets.where((budget) => budget.id != id).toList();
      _error = null;
      return true;
    } catch (error) {
      _error = errorMessage(error);
      return false;
    } finally {
      notifyListeners();
    }
  }
}
