import 'expense.dart';

class Budget {
  const Budget({required this.id, required this.category, required this.limit});

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'].toString(),
      category: ExpenseCategory.fromName(json['category'] as String?),
      limit: (json['limit'] as num).toDouble(),
    );
  }

  final String id;
  final ExpenseCategory category;
  final double limit;

  Map<String, dynamic> toJson() => {'category': category.name, 'limit': limit};

  Budget copyWith({String? id, double? limit}) {
    return Budget(
      id: id ?? this.id,
      category: category,
      limit: limit ?? this.limit,
    );
  }
}
