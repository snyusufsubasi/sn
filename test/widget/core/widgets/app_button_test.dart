import 'package:araciyok/core/theme/app_theme.dart';
import 'package:araciyok/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        )),
      ),
    );
  }

  group('AppButton', () {
    testWidgets('Label render olur', (tester) async {
      await pump(tester, AppButton(label: 'Devam Et', onPressed: () {}));
      expect(find.text('Devam Et'), findsOneWidget);
    });

    testWidgets('onPressed null ise tap çalışmaz', (tester) async {
      var tapped = false;
      await pump(
        tester,
        AppButton(label: 'Pasif', onPressed: null),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('Loading durumunda spinner görünür', (tester) async {
      await pump(
        tester,
        AppButton(label: 'Yükle', onPressed: () {}, loading: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Yükle'), findsNothing);
    });

    testWidgets('Tap callback tetiklenir', (tester) async {
      var tapped = false;
      await pump(
        tester,
        AppButton(label: 'Tap', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });
  });
}
