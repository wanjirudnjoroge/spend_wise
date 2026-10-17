import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/category_style.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/expense_tile.dart';
import '../model/expense.dart';
import '../view_model/dashboard_provider.dart';
import '../view_model/providers.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final summary = ref.watch(dashboardViewModelProvider);
    final expenses = ref.watch(expensesViewModelProvider);
    final percent = (summary.spendingPercentage * 100).round();
    final spentByCategory = summary.spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent = summary.totalSpent;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.blue,
              size: 27,
            ),
            SizedBox(width: 10),
            Text('SpendWise'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'logout') signOut(ref);
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(auth.user?.email ?? ''),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Sign out'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.blue,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshAll(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (expenses.isLoading) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 8),
            Text(
              'Hello, ${auth.user?.firstName ?? 'there'}',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your spending this month.",
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF142B4A), Color(0xFF24558A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remaining budget',
                    style: TextStyle(color: Color(0xFFD7E5F7), fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatMoney(summary.remainingBudget),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Monthly budget',
                          style: TextStyle(
                            color: Color(0xFFD7E5F7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        formatMoney(summary.monthlyBudget),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: summary.spendingPercentage,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        summary.isOverBudget
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFF93C5FD),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    summary.monthlyBudget <= 0
                        ? 'No budgets set yet'
                        : summary.isOverBudget
                        ? 'Over budget this month'
                        : '$percent% of your budget used',
                    style: const TextStyle(
                      color: Color(0xFFD7E5F7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total spent',
                    value: formatMoney(totalSpent),
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.danger,
                    iconBackground: AppColors.dangerBg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Pending expenses',
                    value: '${summary.pendingExpenses}',
                    icon: Icons.pending_actions_rounded,
                    iconColor: AppColors.warning,
                    iconBackground: AppColors.warningBg,
                    onTap: () {
                      ref
                          .read(expensesViewModelProvider)
                          .setFilter(ExpenseStatus.pending);
                      ref.read(tabIndexProvider.notifier).select(1);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AddExpenseScreen(),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.blue,
                    size: 26,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Add expense',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.subtle),
                ],
              ),
            ),
            if (spentByCategory.isNotEmpty) ...[
              const SizedBox(height: 26),
              const _SectionTitle('Where your money goes'),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    for (final entry in spentByCategory)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Icon(
                              entry.key.icon,
                              color: entry.key.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.key.label,
                                          style: const TextStyle(
                                            color: AppColors.navy,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatMoney(entry.value),
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: totalSpent <= 0
                                          ? 0
                                          : entry.value / totalSpent,
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFFE8EEF7),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        entry.key.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(child: _SectionTitle('Recent expenses')),
                TextButton(
                  onPressed: () {
                    ref.read(expensesViewModelProvider).setFilter(null);
                    ref.read(tabIndexProvider.notifier).select(1);
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (summary.recentExpenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No expenses yet.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              for (final expense in summary.recentExpenses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExpenseTile(expense: expense),
                ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
