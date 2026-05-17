/// Form validator yardımcıları. Hepsi null veya hata mesajı döner.
class Validators {
  Validators._();

  /// +90 5XX XXX XX XX formatı veya 05XX XXX XX XX formatı kabul eder.
  static String? phone(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Telefon numarası gerekli';
    }
    final digits = input.replaceAll(RegExp(r'\D'), '');
    // 90 ile başlayan 12 hane VEYA 0 ile başlayan 11 hane VEYA 10 hane
    if (digits.length == 12 && digits.startsWith('905')) return null;
    if (digits.length == 11 && digits.startsWith('05')) return null;
    if (digits.length == 10 && digits.startsWith('5')) return null;
    return 'Geçerli bir Türkiye GSM numarası gir';
  }

  /// Telefon numarasını her zaman E.164 (+905XXXXXXXXX) formatına çevirir.
  static String normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('90')) return '+$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      return '+90${digits.substring(1)}';
    }
    if (digits.length == 10 && digits.startsWith('5')) return '+90$digits';
    return '+$digits';
  }

  static String? required(String? input, {String label = 'Bu alan'}) {
    if (input == null || input.trim().isEmpty) {
      return '$label gerekli';
    }
    return null;
  }

  static String? minLength(String? input, int min, {String label = 'Bu alan'}) {
    if (input == null || input.length < min) {
      return '$label en az $min karakter olmalı';
    }
    return null;
  }

  /// Türkiye TC kimlik no (11 hane, ilk hane 0 olamaz, basit checksum kontrolü)
  static String? tcKimlik(String? input) {
    if (input == null || input.length != 11) {
      return 'TC kimlik 11 haneli olmalı';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(input)) return 'Sadece rakam kullan';
    if (input[0] == '0') return 'TC kimlik 0 ile başlayamaz';

    final digits = input.split('').map(int.parse).toList();
    final sumOdd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    final sumEven = digits[1] + digits[3] + digits[5] + digits[7];
    final check10 = (sumOdd * 7 - sumEven) % 10;
    final check11 = (sumOdd + sumEven + digits[9]) % 10;
    if (check10 != digits[9] || check11 != digits[10]) {
      return 'Geçersiz TC kimlik no';
    }
    return null;
  }

  /// Vergi numarası (10 hane)
  static String? vergiNo(String? input) {
    if (input == null || input.length != 10) {
      return 'Vergi numarası 10 haneli olmalı';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(input)) return 'Sadece rakam kullan';
    return null;
  }

  /// Türkiye plaka — esnek, sadece format kontrolü
  /// Örn: 34ABC123, 06AB1234, 41AY041
  static String? plaka(String? input) {
    if (input == null || input.trim().isEmpty) return 'Plaka gerekli';
    final normalized = input.replaceAll(' ', '').toUpperCase();
    final regex = RegExp(r'^\d{2}[A-Z]{1,3}\d{1,4}$');
    if (!regex.hasMatch(normalized)) {
      return 'Geçerli bir plaka gir (örn. 34 ABC 123)';
    }
    return null;
  }

  /// TR IBAN (26 karakter, TR ile başlar).
  static String? iban(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'IBAN gerekli';
    }
    final normalized = input.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!normalized.startsWith('TR') || normalized.length != 26) {
      return 'Geçerli bir TR IBAN gir (26 karakter)';
    }
    if (!RegExp(r'^TR\d{24}$').hasMatch(normalized)) {
      return 'IBAN yalnızca harf ve rakam içermeli';
    }
    return null;
  }

  static String? email(String? input) {
    if (input == null || input.isEmpty) return null; // opsiyonel
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(input)) return 'Geçerli bir e-posta gir';
    return null;
  }
}
