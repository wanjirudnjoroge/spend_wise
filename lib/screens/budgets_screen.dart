import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/category_style.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/state_views.dart';
import '../model/budget.dart';
import '../model/expense.dart';
import '../view_model/dashboard_provider.dart';
import '../view_model/providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(budgetsViewModelProvider);
    final spent = ref.watch(dashboardViewModelProvider).spentByCategory;

    Widget body;
    if (vm.isLoading && vm.budgets.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null && vm.budgets.isEmpty) {
      body = ErrorState(message: vm.error!, onRetry: vm.load);
    } else if (vm.budgets.isEmpty) {
      body = const EmptyState(
        icon: Icons.pie_chart_outline_rounded,
        title: 'No budgets yet',
        message: 'Tap "Set budget" to add a monthly limit for a category.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          itemCount: vm.budgets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final budget = vm.budgets[index];
            return _BudgetTile(
              budget: budget,
              spent: spent[budget.category] ?? 0,
              onTap: () => _openDialog(context, ref, existing: budget),
              onDelete: () => vm.removeBudget(budget.id),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Set budget'),
      ),
      body: body,
    );
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref, {
    Budget? existing,
  }) async {
    final result = await showDialog<(ExpenseCategory, double)>(
      context: context,
      builder: (_) => _BudgetDialog(existing: existing),
    );
    if (result == null) return;
    await ref.read(budgetsViewModelProvider).setBudget(result.$1, result.$2);
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.spent,
    required this.onTap,
    required this.onDelete,
  });

  final Budget budget;
  final double spent;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = budget.category;
    final over = spent > budget.limit;
    final progress = budget.limit <= 0
        ? 0.0
        : (spent / budget.limit).clamp(0.0, 1.0);
    final remaining = budget.limit - spent;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove budget',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.subtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEF7),
              valueColor: AlwaysStoppedAnimation<Color>(
                over ? AppColors.danger : AppColors.blue,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatMoney(spent)} of ${formatMoney(budget.limit)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              Text(
                over
                    ? '${formatMoney(-remaining)} over'
                    : '${formatMoney(remaining)} left',
                style: TextStyle(
                  color: over ? AppColors.danger : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({this.existing});

  final Budget? existing;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late ExpenseCategory _category;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ?? ExpenseCategory.travel;
    _amount = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.limit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;

    return AlertDialog(
      title: Text(editing ? 'Edit budget' : 'Set budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in ExpenseCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
              ],
              onChanged: editing
                  ? null
                  : (value) {
                      if (value != null) setState(() => _category = value);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                prefixText: 'KES ',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                final parsed = double.tryParse(text);
                if (parsed == null || parsed <= 0) {
                  return 'Enter an amount greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(
              context,
            ).pop((_category, double.parse(_amount.text.trim())));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
