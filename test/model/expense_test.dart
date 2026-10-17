import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/expense.dart';

void main() {
  test('Expense.fromJson parses a backend payload', () {
    final expense = Expense.fromJson({
      'id': 3,
      'title': 'Taxi',
      'amount': 850,
      'category': 'travel',
      'date': '2026-10-01T09:30:00.000',
      'status': 'approved',
      'note': 'Airport',
    });

    expect(expense.id, '3');
    expect(expense.amount, 850.0);
    expect(expense.category, ExpenseCategory.travel);
    expect(expense.status, ExpenseStatus.approved);
    expect(expense.date.month, 10);
  });

  test('unknown category and status fall back to safe defaults', () {
    final expense = Expense.fromJson({
      'id': '1',
      'title': 'x',
      'amount': 1,
      'category': 'nonsense',
      'date': '2026-10-01T00:00:00.000',
      'status': 'nonsense',
    });

    expect(expense.category, ExpenseCategory.other);
    expect(expense.status, ExpenseStatus.pending);
  });

  test('toJson omits the id and optional empty fields', () {
    final json = Expense(
      id: 'ignored',
      title: 'Lunch',
      amount: 500,
      category: ExpenseCategory.meals,
      date: DateTime(2026, 10, 5),
    ).toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('note'), isFalse);
    expect(json['category'], 'meals');
    expect(json['status'], 'pending');
  });

  test('copyWith changes only what is passed', () {
    final original = Expense(
      id: '1',
      title: 'Lunch',
      amount: 500,
      category: ExpenseCategory.meals,
      date: DateTime(2026, 10, 5),
    );
    final approved = original.copyWith(status: ExpenseStatus.approved);

    expect(approved.status, ExpenseStatus.approved);
    expect(approved.title, 'Lunch');
    expect(original.status, ExpenseStatus.pending);
  });
}
