import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/repositories/expense_repository.dart';
import 'package:spendwise/services/mock_apis.dart';
import 'package:spendwise/view_model/expenses_viewmodel.dart';

void main() {
  late ExpensesViewModel vm;

  setUp(() async {
    vm = ExpensesViewModel(
      ExpenseRepository(MockExpenseApi(latency: Duration.zero)),
    );
    await vm.load();
  });

  test('load fetches the seeded expenses', () {
    expect(vm.expenses.length, 5);
    expect(vm.isLoading, isFalse);
    expect(vm.error, isNull);
  });

  test('filter limits the visible list', () {
    vm.setFilter(ExpenseStatus.approved);
    expect(vm.visibleExpenses.length, 2);

    vm.setFilter(null);
    expect(vm.visibleExpenses.length, 5);
  });

  test('addExpense puts the new expense in the list', () async {
    final ok = await vm.addExpense(
      Expense(
        id: '',
        title: 'Parking',
        amount: 200,
        category: ExpenseCategory.travel,
        date: DateTime.now(),
      ),
    );

    expect(ok, isTrue);
    expect(vm.expenses.length, 6);
    expect(vm.expenses.first.title, 'Parking');
  });

  test('setStatus updates one expense', () async {
    await vm.setStatus('e3', ExpenseStatus.rejected);

    expect(
      vm.expenses.firstWhere((e) => e.id == 'e3').status,
      ExpenseStatus.rejected,
    );
  });

  test('removeExpense deletes it', () async {
    await vm.removeExpense('e1');

    expect(vm.expenses.any((e) => e.id == 'e1'), isFalse);
  });
}
