import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension BuildContextX on BuildContext {
  // i18n kısayolu
  AppLocalizations get l10n => AppLocalizations.of(this);

  // Theme kısayolları
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  // Media query kısayolları
  MediaQueryData get media => MediaQuery.of(this);
  Size get screenSize => media.size;
  double get screenWidth => media.size.width;
  double get screenHeight => media.size.height;
  EdgeInsets get viewInsets => media.viewInsets;
  EdgeInsets get viewPadding => media.viewPadding;
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  // Navigation kısayolları
  NavigatorState get nav => Navigator.of(this);
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<void> hideKeyboard() async => FocusScope.of(this).unfocus();
}
