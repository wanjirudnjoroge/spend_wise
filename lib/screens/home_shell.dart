import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/providers.dart';
import 'budgets_screen.dart';
import 'cards_screen.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      refreshAll(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DashboardScreen(),
          ExpensesScreen(),
          BudgetsScreen(),
          CardsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            ref.read(tabIndexProvider.notifier).select(value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card_rounded),
            label: 'Cards',
          ),
        ],
      ),
    );
  }
}
