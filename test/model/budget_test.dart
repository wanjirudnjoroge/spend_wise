import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/budget.dart';
import 'package:spendwise/model/expense.dart';

void main() {
  test('Budget round-trips through JSON', () {
    final budget = Budget.fromJson({
      'id': 1,
      'category': 'software',
      'limit': 12000,
    });

    expect(budget.category, ExpenseCategory.software);
    expect(budget.limit, 12000.0);
    expect(budget.toJson(), {'category': 'software', 'limit': 12000.0});
  });
}
