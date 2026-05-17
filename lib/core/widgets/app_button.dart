import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';
import '../theme/motion/app_curves.dart';
import '../theme/motion/app_duration.dart';

enum AppButtonVariant { primary, secondary, accent, ghost, danger, success }

enum AppButtonSize { small, medium, large }

/// ARACIYOK buton bileşeni.
///
/// | Variant | Kullanım |
/// |---------|----------|
/// | primary | Ana CTA — navy800 dolu, beyaz metin |
/// | secondary | Alternatif — beyaz, navy800 border |
/// | accent | Öne çıkan — amber500 dolu, sıcak |
/// | ghost | Hafif aksiyon — transparan |
/// | danger | Silme/iptal — red600 dolu |
/// | success | Onay — green600 dolu |
///
/// 40+ kullanıcı için büyük touch target (minimum 48px).
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppDuration.instant,
      reverseDuration: AppDuration.fast,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: AppCurves.standard,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final colors = _colorsFor(widget.variant, disabled);
    final height = _heightFor(widget.size);
    final padding = _paddingFor(widget.size);
    final labelSize = _labelSizeFor(widget.size);

    final textStyle = TextStyle(
      fontSize: labelSize,
      fontWeight: FontWeight.w600,
      color: colors.fg,
      letterSpacing: 0.2,
    );

    final child = widget.loading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(colors.fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 22, color: colors.fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(widget.trailingIcon, size: 22, color: colors.fg),
              ],
            ],
          );

    void onButtonTap() {
      if (disabled || widget.onPressed == null) return;
      widget.onPressed!();
    }

    final button = GestureDetector(
      onTap: disabled ? null : onButtonTap,
      onTapDown: disabled ? null : (_) => _scaleController.reverse(),
      onTapUp: disabled
          ? null
          : (_) {
              _scaleController.forward();
            },
      onTapCancel: disabled ? null : () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: colors.border != null
                ? Border.all(color: colors.border!, width: 1.5)
                : null,
            boxShadow: colors.elevation > 0
                ? [
                    BoxShadow(
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                      color: const Color(AppPalette.ink900).withOpacity(0.12),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    final result = Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: disabled ? null : onButtonTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: colors.splash,
        highlightColor: colors.splash,
        child: button,
      ),
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: result)
        : result;
  }

  _ButtonColors _colorsFor(AppButtonVariant v, bool disabled) {
    if (disabled) {
      return _ButtonColors(
        bg: const Color(AppPalette.ink200),
        fg: const Color(AppPalette.ink500),
        splash: const Color(AppPalette.ink200),
        border: null,
        elevation: 0,
      );
    }
    switch (v) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          bg: const Color(AppPalette.navy800),
          fg: const Color(AppPalette.white),
          splash: const Color(AppPalette.navy600),
          border: null,
          elevation: 1,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          bg: const Color(AppPalette.white),
          fg: const Color(AppPalette.navy800),
          splash: const Color(AppPalette.navy100),
          border: const Color(AppPalette.ink300),
          elevation: 0,
        );
      case AppButtonVariant.accent:
        return _ButtonColors(
          bg: const Color(AppPalette.amber500),
          fg: const Color(AppPalette.white),
          splash: const Color(AppPalette.amber400),
          border: null,
          elevation: 1,
        );
      case AppButtonVariant.ghost:
        return _ButtonColors(
          bg: const Color(AppPalette.transparent),
          fg: const Color(AppPalette.navy800),
          splash: const Color(AppPalette.navy100),
          border: null,
          elevation: 0,
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          bg: const Color(AppPalette.red600),
          fg: const Color(AppPalette.white),
          splash: const Color(AppPalette.red600),
          border: null,
          elevation: 1,
        );
      case AppButtonVariant.success:
        return _ButtonColors(
          bg: const Color(AppPalette.green600),
          fg: const Color(AppPalette.white),
          splash: const Color(AppPalette.green600),
          border: null,
          elevation: 1,
        );
    }
  }

  double _heightFor(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.small:
        return 44;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _paddingFor(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
    }
  }

  double _labelSizeFor(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }
}

class _ButtonColors {
  _ButtonColors({
    required this.bg,
    required this.fg,
    required this.splash,
    this.border,
    required this.elevation,
  });
  final Color bg;
  final Color fg;
  final Color splash;
  final Color? border;
  final int elevation;
}
