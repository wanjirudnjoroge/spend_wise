import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/card_repository.dart';
import '../repositories/expense_repository.dart';
import '../services/auth_api.dart';
import '../services/budget_api.dart';
import '../services/card_api.dart';
import '../services/expense_api.dart';
import '../services/mock_apis.dart';
import 'config/app_config.dart';
import 'network/api_client.dart';
import 'security/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
  ref.onDispose(client.close);
  return client;
});

final authApiProvider = Provider<AuthApi>((ref) {
  if (AppConfig.useMockApi) return MockAuthApi();
  return HttpAuthApi(ref.watch(apiClientProvider));
});

final expenseApiProvider = Provider<ExpenseApi>((ref) {
  if (AppConfig.useMockApi) return MockExpenseApi();
  return HttpExpenseApi(ref.watch(apiClientProvider));
});

final budgetApiProvider = Provider<BudgetApi>((ref) {
  if (AppConfig.useMockApi) return MockBudgetApi();
  return HttpBudgetApi(ref.watch(apiClientProvider));
});

final cardApiProvider = Provider<CardApi>((ref) {
  if (AppConfig.useMockApi) return MockCardApi();
  return HttpCardApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(ref.watch(expenseApiProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(ref.watch(budgetApiProvider)),
);

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => CardRepository(ref.watch(cardApiProvider)),
);
