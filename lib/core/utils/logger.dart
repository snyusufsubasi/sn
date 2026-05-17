import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Uygulama genelinde logger.
/// Debug build'lerde print eder, release'de no-op.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: kDebugMode ? Level.debug : Level.warning,
  );

  static void d(String msg) => _logger.d(msg);
  static void i(String msg) => _logger.i(msg);
  static void w(String msg) => _logger.w(msg);
  static void e(String msg, [Object? error, StackTrace? stack]) {
    _logger.e(msg, error: error, stackTrace: stack);
  }
}
