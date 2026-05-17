import 'package:araciyok/core/utils/iban_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mask hides middle digits', () {
    const iban = 'TR330006100519786457841326';
    expect(IbanUtils.mask(iban), 'TR3300 **** **** 1326');
  });

  test('normalize strips spaces', () {
    expect(
      IbanUtils.normalize('tr33 0006 1005 1978 6457 8413 26'),
      'TR330006100519786457841326',
    );
  });
}
