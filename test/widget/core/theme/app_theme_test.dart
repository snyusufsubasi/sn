import 'package:araciyok/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light theme uses dark CTA on light surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    final scheme = Theme.of(context).colorScheme;

    expect(Theme.of(context).brightness, Brightness.light);
    expect(scheme.surface.computeLuminance(), greaterThan(0.9));
    expect(scheme.onSurface.computeLuminance(), lessThan(0.1));
  });

  testWidgets('dark theme uses light text on dark surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    final scheme = Theme.of(context).colorScheme;

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(scheme.surface.computeLuminance(), lessThan(0.1));
    expect(scheme.onSurface.computeLuminance(), greaterThan(0.8));
  });
}
