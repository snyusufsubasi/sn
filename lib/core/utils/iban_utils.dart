/// TR IBAN biçimlendirme ve maskeleme.
class IbanUtils {
  IbanUtils._();

  static String normalize(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toUpperCase();

  static String mask(String iban) {
    final n = normalize(iban);
    if (n.length < 10) return n;
    final start = n.substring(0, 6);
    final end = n.substring(n.length - 4);
    return '$start **** **** $end';
  }

  static String formatDisplay(String iban) {
    final n = normalize(iban);
    final buf = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(n[i]);
    }
    return buf.toString();
  }
}
