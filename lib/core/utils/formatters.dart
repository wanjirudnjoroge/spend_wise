import '../constants/app_constants.dart';

String formatMoney(double amount) {
  final whole = amount.abs().round().toString();
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final sign = amount < 0 ? '-' : '';
  return '$sign${AppConstants.currencyCode} $grouped';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
