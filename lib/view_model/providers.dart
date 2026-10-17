import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/dependencies.dart';
import 'auth_view.dart';
import 'budgets_viewmodel.dart';
import 'cards_viewmodel.dart';
import 'expenses_viewmodel.dart';

final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>(
  (ref) => AuthViewModel(ref.watch(authRepositoryProvider)),
);

final _userIdProvider = Provider<String?>(
  (ref) => ref.watch(authViewModelProvider.select((auth) => auth.user?.id)),
);

final expensesViewModelProvider = ChangeNotifierProvider<ExpensesViewModel>((
  ref,
) {
  ref.watch(_userIdProvider);
  return ExpensesViewModel(ref.watch(expenseRepositoryProvider));
});

final budgetsViewModelProvider = ChangeNotifierProvider<BudgetsViewModel>((
  ref,
) {
  ref.watch(_userIdProvider);
  return BudgetsViewModel(ref.watch(budgetRepositoryProvider));
});

final cardsViewModelProvider = ChangeNotifierProvider<CardsViewModel>((ref) {
  ref.watch(_userIdProvider);
  return CardsViewModel(ref.watch(cardRepositoryProvider));
});

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);

Future<void> refreshAll(WidgetRef ref) {
  return Future.wait([
    ref.read(expensesViewModelProvider).load(),
    ref.read(budgetsViewModelProvider).load(),
    ref.read(cardsViewModelProvider).load(),
  ]);
}

Future<void> signOut(WidgetRef ref) {
  ref.invalidate(tabIndexProvider);
  return ref.read(authViewModelProvider).logout();
}
