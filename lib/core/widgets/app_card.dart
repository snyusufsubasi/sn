import 'package:flutter/material.dart';

import '../theme/dimensions/app_spacing.dart';
import '../theme/motion/app_curves.dart';
import '../theme/motion/app_duration.dart';

/// ARACIYOK kart bileşeni.
///
/// Varsayılan: elevation=1 (hafif gölgeli)
/// Tap edilebilir: elevation animasyonlu artış
/// Padding: 20px (AppSpacing.cardPadding)
/// Radius: lg (16px) — AppRadius from app_spacing.dart
///
/// NOT: Bu dosya kendi AppRadius/AppElevation tanımlamaz.
/// Bunun için app_spacing.dart kullanılır.
class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevation = 1,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.color,
    this.borderColor,
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final int elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _elevationController;
  Animation<double>? _elevationAnim;

  @override
  void initState() {
    super.initState();
    if (widget.onTap != null) {
      _elevationController = AnimationController(
        vsync: this,
        duration: AppDuration.fast,
        reverseDuration: AppDuration.fast,
        value: 0,
      );
      _elevationAnim = CurvedAnimation(
        parent: _elevationController!,
        curve: AppCurves.standard,
      );
    }
  }

  @override
  void dispose() {
    _elevationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = widget.color ?? theme.colorScheme.surface;
    final anim = _elevationAnim;
    final currentElev = widget.onTap != null && anim != null
        ? widget.elevation + (anim.value * AppElevation.medium)
        : widget.elevation.toDouble();

    final card = Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(widget.radius),
      elevation: currentElev,
      shadowColor: theme.shadowColor.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: widget.onTap != null
            ? (_) => _elevationController?.forward()
            : null,
        onTapUp: widget.onTap != null
            ? (_) => _elevationController?.reverse()
            : null,
        onTapCancel: widget.onTap != null
            ? () => _elevationController?.reverse()
            : null,
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!)
                : null,
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    return Padding(
      padding: widget.margin,
      child: widget.onTap != null && anim != null
          ? ListenableBuilder(
              listenable: anim,
              builder: (context, _) => card,
            )
          : card,
    );
  }
}

/// Gölgesiz, hafif border kart — ikincil içerik için.
class AppSubtleCard extends StatelessWidget {
  const AppSubtleCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.dividerColor),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Küçük etiket/badge — profil, durum göstergeleri için.
/// @Deprecated: Yeni kodlarda AppStatusBadge kullanın.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.color,
    this.backgroundColor,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = color ?? theme.colorScheme.onSurface;
    final bg = backgroundColor ?? theme.colorScheme.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
