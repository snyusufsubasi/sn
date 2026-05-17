import 'package:flutter/material.dart';

import '../theme/dimensions/app_spacing.dart';

/// ARACIYOK bottom sheet bileşeni.
///
/// Animasyonlu açılış (slide up + fade, 400ms)
/// Drag handle, title, kapatma ikonu standart.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Theme.of(context).shadowColor.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.sm,
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        );
      },
    );
  }
}
