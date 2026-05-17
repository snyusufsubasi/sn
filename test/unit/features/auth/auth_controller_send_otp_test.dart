import 'package:araciyok/core/demo/demo_provider.dart';
import 'package:araciyok/core/demo/demo_store.dart';
import 'package:araciyok/features/auth/presentation/controllers/auth_controller.dart';
import 'package:araciyok/features/auth/presentation/controllers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sendOtp demo modda awaitingOtp durumuna geçer', () async {
    final container = ProviderContainer(
      overrides: [
        demoStoreProvider.overrideWith(
          (ref) => DemoStore(
            onStateChanged: () =>
                ref.read(demoRevisionProvider.notifier).state++,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authControllerProvider.notifier);
    await notifier.sendOtp('+905551111111');

    final auth = container.read(authControllerProvider);
    expect(auth.status, AuthStatus.awaitingOtp);
    expect(auth.phoneE164, '+905551111111');
  });
}
