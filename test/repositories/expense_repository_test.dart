import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/expense.dart';
import 'package:spendwise/repositories/expense_repository.dart';
import 'package:spendwise/services/mock_apis.dart';

void main() {
  late ExpenseRepository repository;

  setUp(() {
    repository = ExpenseRepository(MockExpenseApi(latency: Duration.zero));
  });

  test('create, update and delete go through to the API', () async {
    final created = await repository.createExpense(
      Expense(
        id: '',
        title: 'Coffee',
        amount: 300,
        category: ExpenseCategory.meals,
        date: DateTime.now(),
      ),
    );
    expect(created.id, isNotEmpty);

    final approved = await repository.updateStatus(
      created.id,
      ExpenseStatus.approved,
    );
    expect(approved.status, ExpenseStatus.approved);

    await repository.deleteExpense(created.id);
    final remaining = await repository.fetchExpenses();
    expect(remaining.any((e) => e.id == created.id), isFalse);
  });
}
