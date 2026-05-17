import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// 905320000001 → +90 532 000 00 01
  static String phone(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('90')) {
      final body = digits.substring(2);
      return '+90 ${body.substring(0, 3)} '
          '${body.substring(3, 6)} '
          '${body.substring(6, 8)} '
          '${body.substring(8, 10)}';
    }
    return e164;
  }

  /// 12500 → 12.500 ₺
  static String currency(num amount, {int decimals = 0}) {
    final f = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: decimals,
    );
    return f.format(amount);
  }

  /// 12500 → 12.500 (sembolsüz)
  static String number(num value, {int decimals = 0}) {
    final f = NumberFormat.decimalPattern('tr_TR')
      ..maximumFractionDigits = decimals
      ..minimumFractionDigits = decimals;
    return f.format(value);
  }

  /// 2026-05-16 → 16 May 2026
  static String date(DateTime dt) =>
      DateFormat('d MMM y', 'tr_TR').format(dt);

  /// 2026-05-16 14:30 → 16 May, 14:30
  static String dateTime(DateTime dt) =>
      DateFormat('d MMM, HH:mm', 'tr_TR').format(dt);

  /// 14:30
  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// "şimdi", "5 dk önce", "3 saat önce", "dün", "16 May"
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays == 1) return 'dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return date(dt);
  }

  /// 14.5 → 14,5 ton
  static String weight(double tons) {
    final f = NumberFormat('#,##0.#', 'tr_TR');
    return '${f.format(tons)} ton';
  }
}
