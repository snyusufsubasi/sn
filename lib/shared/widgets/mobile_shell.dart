import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';
import 'package:tasima_app/features/messages/data/message_state.dart';

class ResponsiveMobileFrame extends StatelessWidget {
  final Widget? child;

  const ResponsiveMobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width <= 520) return child ?? const SizedBox.shrink();

    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class AppTabShell extends ConsumerWidget {
  final Widget child;

  const AppTabShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = _tabsForRole(ref);
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = tabs.indexWhere((tab) => tab.route == location);
    final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          final route = tabs[index].route;
          if (route != location) context.go(route);
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: tab.badge != null && tab.badge! > 0
                  ? Badge(
                      label: Text(tab.badge! > 99 ? '99+' : ''),
                      child: Icon(tab.icon),
                    )
                  : Icon(tab.icon),
              selectedIcon: tab.badge != null && tab.badge! > 0
                  ? Badge(
                      label: Text(tab.badge! > 99 ? '99+' : ''),
                      child: Icon(tab.selectedIcon),
                    )
                  : Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  List<_AppTab> _tabsForRole(WidgetRef ref) {
    String? role;
    final profile = ref.watch(currentProfileProvider);
    role = profile.maybeWhen(
      data: (value) => value?['role'] as String?,
      orElse: () => null,
    );

    final msgUnread = ref.watch(unreadMessageCountProvider);
    final msgBadge = msgUnread.valueOrNull;

    if (role == 'shipper') {
      return [
        const _AppTab('Ana Sayfa', Icons.home_outlined, Icons.home, AppRoutes.shipperHome),
        const _AppTab('İlanlarım', Icons.inventory_2_outlined, Icons.inventory_2, AppRoutes.myJobPosts),
        _AppTab('Mesajlar', Icons.chat_bubble_outline, Icons.chat_bubble, AppRoutes.messages, badge: msgBadge),
        const _AppTab('Bildirimler', Icons.notifications_outlined, Icons.notifications, AppRoutes.notifications),
        const _AppTab('Profil', Icons.person_outline, Icons.person, AppRoutes.profile),
      ];
    }

    return [
      const _AppTab('İşler', Icons.local_shipping_outlined, Icons.local_shipping, AppRoutes.carrierHome),
      const _AppTab('Tekliflerim', Icons.send_outlined, Icons.send, AppRoutes.myOffers),
      _AppTab('Mesajlar', Icons.chat_bubble_outline, Icons.chat_bubble, AppRoutes.messages, badge: msgBadge),
      const _AppTab('Bildirimler', Icons.notifications_outlined, Icons.notifications, AppRoutes.notifications),
      const _AppTab('Profil', Icons.person_outline, Icons.person, AppRoutes.profile),
    ];
  }
}

class _AppTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final int? badge;

  const _AppTab(this.label, this.icon, this.selectedIcon, this.route, {this.badge});
}
