import 'package:intl/intl.dart';

class AppFormatters {
  static final _dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final _shortDateFormatter = DateFormat('dd MMM', 'tr_TR');
  static final _dateTimeFormatter = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');
  static final _currencyFormatter = NumberFormat.currency(
    symbol: 'TL',
    locale: 'tr_TR',
    decimalDigits: 0,
  );

  static String formatDate(DateTime date) => _dateFormatter.format(date);
  static String formatShortDate(DateTime date) =>
      _shortDateFormatter.format(date);
  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);
  static String formatCurrency(num amount) => _currencyFormatter.format(amount);

  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    }
    if (digits.length == 11) {
      return '(${digits.substring(1, 4)}) ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    }
    return phone;
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika once';
    if (diff.inHours < 24) return '${diff.inHours} saat once';
    if (diff.inDays < 7) return '${diff.inDays} gun once';
    return formatShortDate(date);
  }
}
