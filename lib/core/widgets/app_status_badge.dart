import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';

/// Durum rozeti — navlun durumunu renk + ikon + label ile gösterir.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    required this.status,
    super.key,
    this.size = AppStatusBadgeSize.md,
  });

  /// Görünen metin
  final String label;

  /// Durum tipi (renk + ikon seçimi için)
  final AppStatusBadgeType status;

  /// Boyut
  final AppStatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == AppStatusBadgeSize.sm;
    final iconData = _iconFor(status);
    final color = _colorFor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: isSmall ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(AppStatusBadgeType type) {
    switch (type) {
      case AppStatusBadgeType.open:
        return Icons.radio_button_unchecked;
      case AppStatusBadgeType.inProgress:
        return Icons.local_shipping_outlined;
      case AppStatusBadgeType.completed:
        return Icons.check_circle_outline;
      case AppStatusBadgeType.cancelled:
        return Icons.cancel_outlined;
      case AppStatusBadgeType.info:
        return Icons.info_outline;
      case AppStatusBadgeType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  Color _colorFor(AppStatusBadgeType type) {
    switch (type) {
      case AppStatusBadgeType.open:
        return const Color(AppPalette.blue600);
      case AppStatusBadgeType.inProgress:
        return const Color(AppPalette.amber500);
      case AppStatusBadgeType.completed:
        return const Color(AppPalette.green600);
      case AppStatusBadgeType.cancelled:
        return const Color(AppPalette.ink500);
      case AppStatusBadgeType.info:
        return const Color(AppPalette.blue600);
      case AppStatusBadgeType.warning:
        return const Color(AppPalette.gold600);
    }
  }
}

enum AppStatusBadgeType {
  open,
  inProgress,
  completed,
  cancelled,
  info,
  warning,
}

enum AppStatusBadgeSize { sm, md }
