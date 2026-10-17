class User {
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String email;

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first.isEmpty ? 'there' : parts.first;
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
