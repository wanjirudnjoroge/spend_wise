import 'package:flutter/material.dart';

import '../../model/expense.dart';
import '../constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ExpenseStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (status) {
      ExpenseStatus.pending => (AppColors.warning, AppColors.warningBg),
      ExpenseStatus.approved => (AppColors.success, AppColors.successBg),
      ExpenseStatus.rejected => (AppColors.danger, AppColors.dangerBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
