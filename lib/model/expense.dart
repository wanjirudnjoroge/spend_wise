enum ExpenseCategory {
  travel('Travel'),
  meals('Meals'),
  software('Software'),
  office('Office'),
  marketing('Marketing'),
  other('Other');

  const ExpenseCategory(this.label);

  final String label;

  static ExpenseCategory fromName(String? name) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => ExpenseCategory.other,
    );
  }
}

enum ExpenseStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const ExpenseStatus(this.label);

  final String label;

  static ExpenseStatus fromName(String? name) {
    return ExpenseStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => ExpenseStatus.pending,
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.status = ExpenseStatus.pending,
    this.note,
    this.cardId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.fromName(json['category'] as String?),
      date: DateTime.parse(json['date'] as String),
      status: ExpenseStatus.fromName(json['status'] as String?),
      note: json['note'] as String?,
      cardId: json['card_id']?.toString(),
    );
  }

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final ExpenseStatus status;
  final String? note;
  final String? cardId;

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'category': category.name,
    'date': date.toIso8601String(),
    'status': status.name,
    if (note != null) 'note': note,
    if (cardId != null) 'card_id': cardId,
  };

  Expense copyWith({String? id, ExpenseStatus? status}) {
    return Expense(
      id: id ?? this.id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      status: status ?? this.status,
      note: note,
      cardId: cardId,
    );
  }
}
