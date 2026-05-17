import 'package:araciyok/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.phone', () {
    test('null veya boş → hata', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('   '), isNotNull);
    });

    test('10 hane 5XX ile başlayan → ok', () {
      expect(Validators.phone('5320000001'), isNull);
    });

    test('+905XXXXXXXXX → ok', () {
      expect(Validators.phone('+905320000001'), isNull);
    });

    test('05XX XXX XX XX → ok (boşluklu)', () {
      expect(Validators.phone('0532 000 00 01'), isNull);
    });

    test('Yanlış prefix → hata', () {
      expect(Validators.phone('1234567890'), isNotNull);
      expect(Validators.phone('+901234567890'), isNotNull);
    });

    test('Eksik hane → hata', () {
      expect(Validators.phone('532000'), isNotNull);
    });
  });

  group('Validators.normalizePhone', () {
    test('10 hane → +90 prefix eklenir', () {
      expect(Validators.normalizePhone('5320000001'), '+905320000001');
    });

    test('05XX → +90 prefix dönüşür', () {
      expect(Validators.normalizePhone('05320000001'), '+905320000001');
    });

    test('Boşluklu giriş → temizlenir', () {
      expect(Validators.normalizePhone('0532 000 00 01'), '+905320000001');
    });

    test('Zaten E.164 → değişmez', () {
      expect(Validators.normalizePhone('+905320000001'), '+905320000001');
    });
  });

  group('Validators.tcKimlik', () {
    test('Geçerli TC kimlik → null', () {
      // Bilinen test edilebilir TC: 10000000146
      expect(Validators.tcKimlik('10000000146'), isNull);
    });

    test('Yanlış uzunluk → hata', () {
      expect(Validators.tcKimlik('123'), isNotNull);
      expect(Validators.tcKimlik('123456789012'), isNotNull);
    });

    test('0 ile başlayan → hata', () {
      expect(Validators.tcKimlik('01234567890'), isNotNull);
    });

    test('Harf içeren → hata', () {
      expect(Validators.tcKimlik('1234567890a'), isNotNull);
    });
  });

  group('Validators.vergiNo', () {
    test('10 hane → ok', () {
      expect(Validators.vergiNo('1234567890'), isNull);
    });

    test('Yanlış uzunluk → hata', () {
      expect(Validators.vergiNo('123'), isNotNull);
      expect(Validators.vergiNo('12345678901'), isNotNull);
    });
  });

  group('Validators.plaka', () {
    test('34 ABC 123 → ok', () {
      expect(Validators.plaka('34 ABC 123'), isNull);
    });

    test('06AB1234 → ok', () {
      expect(Validators.plaka('06AB1234'), isNull);
    });

    test('Küçük harf → büyütülerek kabul', () {
      expect(Validators.plaka('06ab1234'), isNull);
    });

    test('Format dışı → hata', () {
      expect(Validators.plaka('ABCD123'), isNotNull);
      expect(Validators.plaka(''), isNotNull);
    });
  });
}
