import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/theme/colors/app_palette.dart';
import '../../../core/theme/motion/app_curves.dart';
import '../../../core/theme/motion/app_duration.dart';
import '../../messages/presentation/controllers/messages_controller.dart';
import '../../notifications/presentation/controllers/notifications_controller.dart';

/// Bottom navigation shell. Alt sekmeler her zaman aynı sırada:
/// Anasayfa | İlanlar | Bildirimler | Mesajlar | Profil
class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final l10n = context.l10n;

    final unreadNotifs =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final unreadMsgs = ref.watch(unreadMessagesCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppDuration.fast,
        switchInCurve: AppCurves.decelerate,
        switchOutCurve: AppCurves.accelerate,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(AppPalette.white),
          border: Border(
            top: BorderSide(color: Color(AppPalette.ink300)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == currentIndex,
          ),
          backgroundColor: const Color(AppPalette.white),
          surfaceTintColor: const Color(AppPalette.transparent),
          indicatorColor: const Color(AppPalette.ink100),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? const Color(AppPalette.navy800)
                  : const Color(AppPalette.ink500),
            );
          }),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined,
                  color: Color(AppPalette.ink500)),
              selectedIcon:
                  const Icon(Icons.home, color: Color(AppPalette.navy800)),
              label: l10n.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined,
                  color: Color(AppPalette.ink500)),
              selectedIcon: const Icon(
                Icons.inventory_2,
                color: Color(AppPalette.navy800),
              ),
              label: l10n.tabJobs,
            ),
            NavigationDestination(
              icon: _BadgedIcon(
                icon: Icons.notifications_outlined,
                count: unreadNotifs,
              ),
              selectedIcon: _BadgedIcon(
                icon: Icons.notifications,
                count: unreadNotifs,
                iconColor: const Color(AppPalette.navy800),
              ),
              label: l10n.tabNotifications,
            ),
            NavigationDestination(
              icon: _BadgedIcon(
                icon: Icons.chat_bubble_outline,
                count: unreadMsgs,
              ),
              selectedIcon: _BadgedIcon(
                icon: Icons.chat_bubble,
                count: unreadMsgs,
                iconColor: const Color(AppPalette.navy800),
              ),
              label: l10n.tabMessages,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline,
                  color: Color(AppPalette.ink500)),
              selectedIcon:
                  const Icon(Icons.person, color: Color(AppPalette.navy800)),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({
    required this.icon,
    required this.count,
    this.iconColor,
  });
  final IconData icon;
  final int count;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon,
            color: iconColor ?? const Color(AppPalette.ink500)),
        Positioned(
          right: -6,
          top: -4,
          child: AnimatedSwitcher(
            duration: AppDuration.fast,
            switchInCurve: AppCurves.decelerate,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: count > 0
                ? TweenAnimationBuilder<double>(
                    key: ValueKey('badge_$count'),
                    tween: Tween<double>(begin: 1.3, end: 1),
                    duration: AppDuration.normal,
                    curve: AppCurves.gentleSpring,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: const Color(AppPalette.amber500),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(AppPalette.white),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Color(AppPalette.white),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey(0)),
          ),
        ),
      ],
    );
  }
}
