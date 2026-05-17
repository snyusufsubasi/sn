import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';

/// ARACIYOK text field bileşeni.
///
/// 40+ kullanıcı için optimize:
/// - Font size: 17px (bodyLarge)
/// - Floating label (Material 3)
/// - Büyük touch target
/// - Yüksek kontrast border
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.showCounter = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      textInputAction: textInputAction,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      cursorColor: const Color(AppPalette.navy800),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.sm),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon,
        counterText: showCounter ? null : '',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(AppPalette.navy800), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(AppPalette.red600), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(AppPalette.red600), width: 1.5),
        ),
      ),
    );
  }
}
