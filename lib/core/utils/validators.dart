class AppValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresinizi girin.';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'Gecerli bir e-posta adresi girin.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Sifrenizi girin.';
    if (value.length < 6) return 'Sifre en az 6 karakter olmalidir.';
    return null;
  }

  static String? required(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) return '$fieldName zorunludur.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numaranizi girin.';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Gecerli bir telefon numarasi girin.';
    return null;
  }

  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tutar girin.';
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return 'Gecerli bir tutar girin.';
    return null;
  }
}
