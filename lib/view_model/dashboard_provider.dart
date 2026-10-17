import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_viewmodel.dart';
import 'providers.dart';

final dashboardViewModelProvider = Provider<DashboardViewModel>((ref) {
  final expenses = ref.watch(expensesViewModelProvider);
  final budgets = ref.watch(budgetsViewModelProvider);

  return DashboardViewModel(
    expenses: expenses.expenses,
    budgets: budgets.budgets,
  );
});
