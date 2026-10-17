import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/repositories/budget_repository.dart';
import 'package:spendwise/services/mock_apis.dart';
import 'package:spendwise/view_model/budgets_viewmodel.dart';

void main() {
  late BudgetsViewModel vm;

  setUp(() async {
    vm = BudgetsViewModel(
      BudgetRepository(MockBudgetApi(latency: Duration.zero)),
    );
    await vm.load();
  });

  test('load fetches budgets and totals them', () {
    expect(vm.budgets.length, 5);
    expect(vm.totalLimit, 50000.0);
  });

  test(
    'setBudget updates an existing category without duplicating it',
    () async {
      await vm.setBudget(ExpenseCategory.travel, 20000);

      expect(vm.budgets.length, 5);
      expect(
        vm.budgets
            .firstWhere((b) => b.category == ExpenseCategory.travel)
            .limit,
        20000.0,
      );
    },
  );

  test('setBudget rejects non-positive amounts', () async {
    final ok = await vm.setBudget(ExpenseCategory.other, 0);

    expect(ok, isFalse);
    expect(vm.error, isNotNull);
    expect(vm.budgets.length, 5);
  });

  test('setBudget creates a budget for a new category', () async {
    await vm.setBudget(ExpenseCategory.other, 3000);

    expect(vm.budgets.length, 6);
  });

  test('removeBudget deletes it', () async {
    await vm.removeBudget('b1');

    expect(vm.budgets.any((b) => b.id == 'b1'), isFalse);
  });
}
