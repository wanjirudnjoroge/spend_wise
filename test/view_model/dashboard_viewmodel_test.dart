import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/budget.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/view_model/dashboard_viewmodel.dart';

void main() {
  final now = DateTime(2026, 10, 17);

  Expense expense(
    String id,
    double amount,
    ExpenseStatus status, {
    ExpenseCategory category = ExpenseCategory.travel,
    DateTime? date,
  }) {
    return Expense(
      id: id,
      title: 'Item $id',
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 10, 10),
      status: status,
    );
  }

  const budgets = [
    Budget(id: 'b1', category: ExpenseCategory.travel, limit: 10000),
    Budget(id: 'b2', category: ExpenseCategory.meals, limit: 5000),
  ];

  test('totals ignore rejected expenses and other months', () {
    final vm = DashboardViewModel(
      now: now,
      budgets: budgets,
      expenses: [
        expense('1', 2000, ExpenseStatus.approved),
        expense(
          '2',
          1000,
          ExpenseStatus.pending,
          category: ExpenseCategory.meals,
        ),
        expense('3', 9999, ExpenseStatus.rejected),
        expense('4', 7777, ExpenseStatus.approved, date: DateTime(2026, 9, 28)),
      ],
    );

    expect(vm.monthlyBudget, 15000.0);
    expect(vm.totalSpent, 3000.0);
    expect(vm.remainingBudget, 12000.0);
    expect(vm.pendingExpenses, 1);
    expect(vm.spentByCategory[ExpenseCategory.travel], 2000.0);
    expect(vm.spendingPercentage, closeTo(0.2, 0.0001));
    expect(vm.isOverBudget, isFalse);
  });

  test('percentage is clamped and over-budget is flagged', () {
    final vm = DashboardViewModel(
      now: now,
      budgets: budgets,
      expenses: [expense('1', 20000, ExpenseStatus.approved)],
    );

    expect(vm.spendingPercentage, 1.0);
    expect(vm.isOverBudget, isTrue);
    expect(vm.remainingBudget, -5000.0);
  });

  test('no budgets means zero percentage and never over budget', () {
    final vm = DashboardViewModel(
      now: now,
      budgets: const [],
      expenses: [expense('1', 500, ExpenseStatus.approved)],
    );

    expect(vm.spendingPercentage, 0.0);
    expect(vm.isOverBudget, isFalse);
  });

  test('recentExpenses returns the five newest', () {
    final vm = DashboardViewModel(
      now: now,
      budgets: budgets,
      expenses: [
        for (var day = 1; day <= 7; day++)
          expense(
            '$day',
            100,
            ExpenseStatus.approved,
            date: DateTime(2026, 10, day),
          ),
      ],
    );

    expect(vm.recentExpenses.length, 5);
    expect(vm.recentExpenses.first.id, '7');
  });
}
