import 'package:araciyok/core/errors/failures.dart';
import 'package:araciyok/core/errors/result.dart';
import 'package:araciyok/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  group('AuthRepository contract (mock üzerinden)', () {
    test('sendOtp başarılı dönerse Success', () async {
      when(() => repo.sendOtp(phoneE164: any(named: 'phoneE164')))
          .thenAnswer((_) async => const Success(null));

      final result = await repo.sendOtp(phoneE164: '+905320000001');

      expect(result, isA<Success<void>>());
      verify(() => repo.sendOtp(phoneE164: '+905320000001')).called(1);
    });

    test('verifyOtp hatalı OTP → ResultFailure(AuthFailure.invalidOtp)',
        () async {
      when(() => repo.verifyOtp(
            phoneE164: any(named: 'phoneE164'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const ResultFailure(AuthFailure.invalidOtp()));

      final result =
          await repo.verifyOtp(phoneE164: '+905320000001', otp: '999999');

      expect(result, isA<ResultFailure<String>>());
      result.when(
        success: (_) => fail('should fail'),
        failure: (f) => expect(f, isA<AuthFailure>()),
      );
    });

    test('signOut başarılı', () async {
      when(repo.signOut).thenAnswer((_) async => const Success(null));
      final result = await repo.signOut();
      expect(result.isSuccess, isTrue);
    });
  });
}
