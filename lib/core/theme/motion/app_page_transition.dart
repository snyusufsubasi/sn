import 'package:flutter/material.dart';

import 'app_curves.dart';
import 'app_duration.dart';

/// ARACIYOK sayfa geçiş animasyonları.
///
/// İleri giderken: slide sağdan sola + fade (yavaş)
/// Geri dönerken: slide soldan sağa + fade (daha hızlı)
class AppPageTransition {
  AppPageTransition._();

  /// Standart slide + fade geçişi.
  static PageRouteBuilder<T> fadeSlide<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppCurves.decelerate,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppCurves.standard,
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AppDuration.slow,
      reverseTransitionDuration: AppDuration.normal,
    );
  }

  /// Bottom sheet tarzı — aşağıdan yukarı + fade.
  static PageRouteBuilder<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppCurves.decelerate,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppCurves.standard,
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AppDuration.slow,
      reverseTransitionDuration: AppDuration.normal,
    );
  }

  /// Minimal fade geçişi — hafif, basit.
  static PageRouteBuilder<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppCurves.standard,
          ),
          child: child,
        );
      },
      transitionDuration: AppDuration.normal,
      reverseTransitionDuration: AppDuration.fast,
    );
  }
}
