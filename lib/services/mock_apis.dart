import 'dart:math' as math;

import '../core/errors/app_exception.dart';
import '../model/budget.dart';
import '../model/corporate_card.dart';
import '../model/expense.dart';
import '../model/login_response.dart';
import '../model/token_response.dart';
import '../model/user.dart';
import 'auth_api.dart';
import 'budget_api.dart';
import 'card_api.dart';
import 'expense_api.dart';

class _Account {
  const _Account(this.user, this.password);

  final User user;
  final String password;
}

class MockAuthApi implements AuthApi {
  MockAuthApi({this.latency = const Duration(milliseconds: 400)}) {
    _accounts['demo@spendwise.app'] = const _Account(
      User(id: 'u1', name: 'Amina Wanjiru', email: 'demo@spendwise.app'),
      'password123',
    );
  }

  final Duration latency;
  final Map<String, _Account> _accounts = {};
  String? _signedInEmail;
  int _nextId = 2;

  Future<void> _wait() => Future<void>.delayed(latency);

  LoginResponse _session(User user) {
    _signedInEmail = user.email;
    return LoginResponse(
      tokens: TokenResponse(accessToken: 'mock-token-${user.id}'),
      user: user,
    );
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    await _wait();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthenticationException(
        message: 'Incorrect email or password.',
      );
    }
    return _session(account.user);
  }

  @override
  Future<LoginResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await _wait();
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const ValidationException(
        message: 'An account with this email already exists.',
      );
    }
    final user = User(id: 'u${_nextId++}', name: name.trim(), email: key);
    _accounts[key] = _Account(user, password);
    return _session(user);
  }

  @override
  Future<User> currentUser() async {
    await _wait();
    final account = _signedInEmail == null ? null : _accounts[_signedInEmail];
    if (account == null) {
      throw const AuthenticationException(message: 'Session expired.');
    }
    return account.user;
  }
}

class MockExpenseApi implements ExpenseApi {
  MockExpenseApi({this.latency = const Duration(milliseconds: 300)}) {
    final now = DateTime.now();
    DateTime daysAgo(int days) =>
        DateTime(now.year, now.month, math.max(1, now.day - days), 12);

    _expenses.addAll([
      Expense(
        id: 'e1',
        title: 'Flight to Mombasa',
        amount: 4200,
        category: ExpenseCategory.travel,
        date: daysAgo(5),
        status: ExpenseStatus.approved,
        note: 'Client workshop',
      ),
      Expense(
        id: 'e2',
        title: 'Team lunch',
        amount: 1850,
        category: ExpenseCategory.meals,
        date: daysAgo(4),
        status: ExpenseStatus.approved,
      ),
      Expense(
        id: 'e3',
        title: 'Figma subscription',
        amount: 3500,
        category: ExpenseCategory.software,
        date: daysAgo(3),
      ),
      Expense(
        id: 'e4',
        title: 'Printer paper and toner',
        amount: 1200,
        category: ExpenseCategory.office,
        date: daysAgo(2),
      ),
      Expense(
        id: 'e5',
        title: 'Facebook ads',
        amount: 1750,
        category: ExpenseCategory.marketing,
        date: daysAgo(1),
      ),
    ]);
  }

  final Duration latency;
  final List<Expense> _expenses = [];
  int _nextId = 6;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<Expense>> fetchExpenses() async {
    await _wait();
    return List<Expense>.of(_expenses);
  }

  @override
  Future<Expense> createExpense(Expense draft) async {
    await _wait();
    final created = draft.copyWith(id: 'e${_nextId++}');
    _expenses.add(created);
    return created;
  }

  @override
  Future<Expense> updateStatus(String id, ExpenseStatus status) async {
    await _wait();
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index == -1) throw const NotFoundException();
    _expenses[index] = _expenses[index].copyWith(status: status);
    return _expenses[index];
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _wait();
    _expenses.removeWhere((expense) => expense.id == id);
  }
}

class MockBudgetApi implements BudgetApi {
  MockBudgetApi({this.latency = const Duration(milliseconds: 300)}) {
    _budgets.addAll(const [
      Budget(id: 'b1', category: ExpenseCategory.travel, limit: 15000),
      Budget(id: 'b2', category: ExpenseCategory.meals, limit: 8000),
      Budget(id: 'b3', category: ExpenseCategory.software, limit: 12000),
      Budget(id: 'b4', category: ExpenseCategory.office, limit: 5000),
      Budget(id: 'b5', category: ExpenseCategory.marketing, limit: 10000),
    ]);
  }

  final Duration latency;
  final List<Budget> _budgets = [];
  int _nextId = 6;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<Budget>> fetchBudgets() async {
    await _wait();
    return List<Budget>.of(_budgets);
  }

  @override
  Future<Budget> saveBudget(Budget budget) async {
    await _wait();
    if (budget.id.isEmpty) {
      final created = budget.copyWith(id: 'b${_nextId++}');
      _budgets.add(created);
      return created;
    }
    final index = _budgets.indexWhere((item) => item.id == budget.id);
    if (index == -1) throw const NotFoundException();
    _budgets[index] = budget;
    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _wait();
    _budgets.removeWhere((budget) => budget.id == id);
  }
}

class MockCardApi implements CardApi {
  MockCardApi({this.latency = const Duration(milliseconds: 300)}) {
    _cards.addAll(const [
      CorporateCard(
        id: 'c1',
        holderName: 'Amina Wanjiru',
        last4: '4821',
        expiry: '09/28',
        limit: 100000,
        spent: 36200,
      ),
      CorporateCard(
        id: 'c2',
        holderName: 'Brian Otieno',
        last4: '1093',
        expiry: '02/27',
        limit: 60000,
        spent: 12500,
      ),
    ]);
  }

  final Duration latency;
  final List<CorporateCard> _cards = [];

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<CorporateCard>> fetchCards() async {
    await _wait();
    return List<CorporateCard>.of(_cards);
  }

  @override
  Future<CorporateCard> setFrozen(String id, {required bool frozen}) async {
    await _wait();
    final index = _cards.indexWhere((card) => card.id == id);
    if (index == -1) throw const NotFoundException();
    _cards[index] = _cards[index].copyWith(isFrozen: frozen);
    return _cards[index];
  }
}
