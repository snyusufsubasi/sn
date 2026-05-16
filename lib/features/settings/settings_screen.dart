import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/auth/data/auth_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (c == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }

  Future<void> _showDemoSwitcher(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const ListTile(
              title: Text('Demo Kullanıcı Değiştir'),
              subtitle: Text(
                'Seçilen role göre ana sayfa ve sekmeler yenilenir.',
              ),
            ),
            _personaTile(ctx, 'Demo Shipper', 'shipper'),
            _personaTile(ctx, 'Demo Carrier', 'carrier'),
            _personaTile(ctx, 'Çok ilanı olan shipper', 'shipper-heavy'),
            _personaTile(ctx, 'Çok teklif vermiş carrier', 'carrier-heavy'),
            _personaTile(
              ctx,
              'Kabul edilmiş işi olan carrier',
              'carrier-accepted',
            ),
            _personaTile(
              ctx,
              'Tamamlanmış işi olan kullanıcı',
              'shipper-completed',
            ),
            _personaTile(
              ctx,
              'Bildirimi çok olan kullanıcı',
              'shipper-notifications',
            ),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    if (selected.startsWith('carrier')) {
      await DevAuthService.switchToDemoCarrier();
      if (context.mounted) context.go(AppRoutes.carrierHome);
    } else {
      await DevAuthService.switchToDemoShipper();
      if (context.mounted) context.go(AppRoutes.shipperHome);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          if (DevAuthService.isActive) ...[
            _tile(
              Icons.switch_account_outlined,
              'Demo Kullanıcı Değiştir',
              () => _showDemoSwitcher(context),
            ),
            const Divider(height: 32),
          ],
          _tile(
            Icons.person_outline,
            'Profilim',
            () => context.push(AppRoutes.profile),
          ),
          _tile(
            Icons.inventory_2_outlined,
            'İlanlarım',
            () => context.push(AppRoutes.myJobPosts),
          ),
          _tile(
            Icons.send_outlined,
            'Tekliflerim',
            () => context.push(AppRoutes.myOffers),
          ),
          _tile(
            Icons.notifications_outlined,
            'Bildirimler',
            () => context.push(AppRoutes.notifications),
          ),
          _tile(
            Icons.support_outlined,
            'Destek',
            () => context.push(AppRoutes.support),
          ),
          const Divider(height: 32),
          _tile(
            Icons.privacy_tip_outlined,
            'Gizlilik Politikası',
            () => context.push(AppRoutes.privacyPolicy),
          ),
          _tile(
            Icons.description_outlined,
            'Kullanım Şartları',
            () => context.push(AppRoutes.terms),
          ),
          const Divider(height: 32),
          _tile(
            Icons.logout,
            'Çıkış Yap',
            () => _signOut(context, ref),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.textHint),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _personaTile(BuildContext context, String title, String value) {
    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: Text(title),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
