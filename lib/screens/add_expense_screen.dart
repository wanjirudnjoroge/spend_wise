import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/category_style.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../core/widgets/primary_button.dart';
import '../model/expense.dart';
import '../view_model/providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final vm = ref.read(expensesViewModelProvider);
    final note = _note.text.trim();
    final success = await vm.addExpense(
      Expense(
        id: '',
        title: _title.text.trim(),
        amount: double.parse(_amount.text.trim()),
        category: _category,
        date: _date,
        note: note.isEmpty ? null : note,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Expense added')));
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Could not save the expense.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('title_field'),
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => Validators.required(value, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('amount_field'),
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KES ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in ExpenseCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(category.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.muted,
                      ),
                    ),
                    child: Text(formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  key: const Key('save_expense_button'),
                  label: 'Save expense',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
