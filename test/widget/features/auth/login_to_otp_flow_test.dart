import 'package:araciyok/core/demo/demo_provider.dart';
import 'package:araciyok/core/demo/demo_store.dart';
import 'package:araciyok/core/routing/app_router.dart';
import 'package:araciyok/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Kodu Gönder sonrası OTP ekranına yönlendirir', (tester) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('tr'),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Demo Yükveren'), findsOneWidget);

    await tester.tap(find.text('Demo Yükveren'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  await tester.pump();

    expect(find.text('Doğrulama kodu'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
  });
}
