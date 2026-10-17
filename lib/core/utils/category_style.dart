import 'package:flutter/material.dart';

import '../../model/expense.dart';

extension CategoryStyle on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.meals:
        return Icons.restaurant_rounded;
      case ExpenseCategory.software:
        return Icons.laptop_mac_rounded;
      case ExpenseCategory.office:
        return Icons.business_center_rounded;
      case ExpenseCategory.marketing:
        return Icons.campaign_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.travel:
        return const Color(0xFF2563EB);
      case ExpenseCategory.meals:
        return const Color(0xFFEA580C);
      case ExpenseCategory.software:
        return const Color(0xFF7C3AED);
      case ExpenseCategory.office:
        return const Color(0xFF0891B2);
      case ExpenseCategory.marketing:
        return const Color(0xFFDB2777);
      case ExpenseCategory.other:
        return const Color(0xFF64748B);
    }
  }
}
