class Validators {
  Validators._();

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? amount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return 'Enter an amount greater than 0';
    return null;
  }
}
