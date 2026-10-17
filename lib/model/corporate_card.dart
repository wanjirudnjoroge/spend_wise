class CorporateCard {
  const CorporateCard({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.expiry,
    required this.limit,
    required this.spent,
    this.isFrozen = false,
  });

  factory CorporateCard.fromJson(Map<String, dynamic> json) {
    return CorporateCard(
      id: json['id'].toString(),
      holderName: json['holder_name'] as String? ?? '',
      last4: json['last4'] as String? ?? '0000',
      expiry: json['expiry'] as String? ?? '--/--',
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num? ?? 0).toDouble(),
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }

  final String id;
  final String holderName;
  final String last4;
  final String expiry;
  final double limit;
  final double spent;
  final bool isFrozen;

  double get available => limit - spent;

  double get usage {
    if (limit <= 0) return 0;
    return (spent / limit).clamp(0.0, 1.0);
  }

  CorporateCard copyWith({bool? isFrozen}) {
    return CorporateCard(
      id: id,
      holderName: holderName,
      last4: last4,
      expiry: expiry,
      limit: limit,
      spent: spent,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}
