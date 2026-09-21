/// Formats a number the way prices are shown in the wireframes, e.g.
/// 990000 -> "990 000".
String formatPrice(num value) {
  final isWhole = value == value.roundToDouble();
  final wholePart = value.truncate().abs();
  final digits = wholePart.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  final decimals = isWhole ? '' : (value.abs() - wholePart).toStringAsFixed(2).substring(1);
  return '$sign${buffer.toString()}$decimals';
}

const _uzbekMonths = [
  'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
  'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
];

/// Formats a DateTime the way the wireframes show dates, e.g. "20 Sentabr 2026".
String formatDate(DateTime date) {
  return '${date.day} ${_uzbekMonths[date.month - 1]} ${date.year}';
}

/// A compact relative label for recently created listings, e.g. "Bugun".
String formatListingDate(DateTime date) {
  final now = DateTime.now();
  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return 'Bugun';
  return formatDate(date);
}
