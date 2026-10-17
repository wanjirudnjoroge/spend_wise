import '../model/budget.dart';
import '../model/expense.dart';

class DashboardViewModel {
  DashboardViewModel({
    required this._expenses,
    required this._budgets,
    DateTime? now,
  }) : _now = now ?? DateTime.now();

  final List<Expense> _expenses;
  final List<Budget> _budgets;
  final DateTime _now;

  List<Expense> get _countedThisMonth => _expenses
      .where(
        (expense) =>
            expense.status != ExpenseStatus.rejected &&
            expense.date.year == _now.year &&
            expense.date.month == _now.month,
      )
      .toList();

  double get monthlyBudget =>
      _budgets.fold(0.0, (sum, budget) => sum + budget.limit);

  double get totalSpent =>
      _countedThisMonth.fold(0.0, (sum, expense) => sum + expense.amount);

  double get remainingBudget => monthlyBudget - totalSpent;

  bool get isOverBudget => monthlyBudget > 0 && totalSpent > monthlyBudget;

  double get spendingPercentage {
    if (monthlyBudget <= 0) return 0;
    return (totalSpent / monthlyBudget).clamp(0.0, 1.0);
  }

  int get pendingExpenses => _expenses
      .where((expense) => expense.status == ExpenseStatus.pending)
      .length;

  List<Expense> get recentExpenses {
    final list = List<Expense>.of(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(5).toList();
  }

  Map<ExpenseCategory, double> get spentByCategory {
    final totals = <ExpenseCategory, double>{};
    for (final expense in _countedThisMonth) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }
}
