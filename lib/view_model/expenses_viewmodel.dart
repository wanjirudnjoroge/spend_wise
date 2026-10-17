import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/utils/safe_notifier.dart';
import '../model/expense.dart';
import '../repositories/expense_repository.dart';

class ExpensesViewModel extends ChangeNotifier with SafeNotifier {
  ExpensesViewModel(this._repository);

  final ExpenseRepository _repository;

  List<Expense> _expenses = const [];
  bool _isLoading = false;
  String? _error;
  ExpenseStatus? _filter;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpenseStatus? get filter => _filter;

  List<Expense> get visibleExpenses {
    final list = _expenses
        .where((expense) => _filter == null || expense.status == _filter)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void setFilter(ExpenseStatus? status) {
    _filter = status;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await _repository.fetchExpenses();
    } catch (error) {
      _error = errorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Expense draft) async {
    try {
      final created = await _repository.createExpense(draft);
      _expenses = [created, ..._expenses];
      _error = null;
      return true;
    } catch (error) {
      _error = errorMessage(error);
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> setStatus(String id, ExpenseStatus status) async {
    try {
      final updated = await _repository.updateStatus(id, status);
      _expenses = [
        for (final expense in _expenses) expense.id == id ? updated : expense,
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

  Future<bool> removeExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      _expenses = _expenses.where((expense) => expense.id != id).toList();
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
