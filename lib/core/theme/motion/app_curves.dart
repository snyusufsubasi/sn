import 'package:flutter/material.dart';

/// ARACIYOK motion curve'ları.
///
/// - Daha yavaş, daha doğal, daha öngörülebilir
/// - 40+ kullanıcı sürprizlerden hoşlanmaz
class AppCurves {
  AppCurves._();

  /// Genel geçiş — CSS ease karşılığı
  static const standard = Cubic(0.25, 0.1, 0.25, 1.0);

  /// Öğe girerken — yavaşlayarak durur
  static const decelerate = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Öğe çıkarken — hızlanarak kaybolur
  static const accelerate = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Özel vurgu girişi — biraz overshoot
  static const emphasize = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Hafif bounce — buton, kart
  static const spring = Curves.easeOutBack;

  /// iOS-like yay efekti
  static const gentleSpring = Cubic(0.34, 1.56, 0.64, 1.0);
}
