import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/expense_tile.dart';
import '../core/widgets/state_views.dart';
import '../core/widgets/status_chip.dart';
import '../model/expense.dart';
import '../view_model/providers.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _openAdd(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(expensesViewModelProvider);
    final visible = vm.visibleExpenses;

    Widget body;
    if (vm.isLoading && vm.expenses.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null && vm.expenses.isEmpty) {
      body = ErrorState(message: vm.error!, onRetry: vm.load);
    } else if (visible.isEmpty) {
      body = const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses here',
        message: 'Expenses that match this filter will show up here.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final expense = visible[index];
            return ExpenseTile(
              expense: expense,
              onTap: () => _showDetails(context, ref, expense),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: vm.filter == null,
                  onSelected: () => vm.setFilter(null),
                ),
                for (final status in ExpenseStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: vm.filter == status,
                    onSelected: () => vm.setFilter(status),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) {
    final vm = ref.read(expensesViewModelProvider);

    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: value),
          ),
        ],
      ),
    );

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(expense.amount),
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                row('Category', Text(expense.category.label)),
                row('Date', Text(formatDate(expense.date))),
                row('Status', StatusChip(status: expense.status)),
                if (expense.note != null && expense.note!.isNotEmpty)
                  row('Note', Text(expense.note!)),
                const SizedBox(height: 16),
                if (expense.status == ExpenseStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            vm.setStatus(expense.id, ExpenseStatus.approved);
                          },
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(64, 50),
                            foregroundColor: AppColors.danger,
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            vm.setStatus(expense.id, ExpenseStatus.rejected);
                          },
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      vm.removeExpense(expense.id);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete expense'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
