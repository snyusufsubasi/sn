import 'package:flutter/material.dart';

import '../theme/dimensions/app_spacing.dart';
import 'app_button.dart';

/// ARACIYOK sayfa iskeleti.
///
/// Özellikler:
/// - Scroll-aware appbar (opsiyonel)
/// - Standart padding
/// - Loading, error, empty state wrapper'ları
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.body,
    this.bottomBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
    this.scrollable = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? body;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: body ?? const SizedBox.shrink(),
    );

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null || titleWidget != null || actions != null
          ? AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
            )
          : null,
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: content,
              )
            : content,
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Section başlığı + opsiyonel "Tümünü gör" linki.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sectionGap / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Tam ekran yükleme göstergesi.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              label!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Boş durum görseli + mesaj + opsiyonel CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(icon, size: 36, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hata durumu için retry'lı görsel.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    super.key,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Bir sorun oluştu',
      subtitle: message,
      actionLabel: onRetry == null ? null : 'Tekrar dene',
      onAction: onRetry,
    );
  }
}
