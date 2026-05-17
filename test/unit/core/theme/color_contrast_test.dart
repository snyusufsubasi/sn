import 'dart:math';

import 'package:araciyok/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final bright = max(l1, l2);
  final dark = min(l1, l2);
  return (bright + 0.05) / (dark + 0.05);
}

void main() {
  test('light semantic text contrast is WCAG-friendly', () {
    final s = AppColors.semanticLight;
    expect(_contrastRatio(s.textPrimary, s.surface), greaterThan(10));
    expect(_contrastRatio(s.textSecondary, s.surface), greaterThan(7));
    expect(_contrastRatio(s.cta, s.onCta), greaterThan(10));
  });

  test('dark semantic text contrast is WCAG-friendly', () {
    final s = AppColors.semanticDark;
    expect(_contrastRatio(s.textPrimary, s.surface), greaterThan(10));
    expect(_contrastRatio(s.textSecondary, s.surface), greaterThan(5));
    expect(_contrastRatio(s.cta, s.onCta), greaterThan(10));
  });

  test('status colors remain semantically distinct', () {
    expect(AppColors.statusOpen, isNot(AppColors.statusCompleted));
    expect(AppColors.statusAccepted, isNot(AppColors.statusCancelled));
    expect(AppColors.statusInProgress, isNot(AppColors.statusOpen));
  });
}
