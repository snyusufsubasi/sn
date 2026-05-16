import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/auth/data/auth_state.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _roleProfile;
  Map<String, dynamic>? _phoneData;
  Map<String, dynamic>? _plateData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final profile = await repo.getCurrentProfile();
      if (!mounted) return;
      _profile = profile;
      final role = profile?['role'] as String?;

      if (role == 'shipper') {
        _roleProfile = await repo.getShipperProfile();
      } else if (role == 'carrier') {
        _roleProfile = await repo.getCarrierProfile();
        _plateData = await repo.getCarrierPlate();
      }
      _phoneData = await repo.getPrivatePhone();

      if (!mounted) return;
      setState(() {
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Profil yüklenemedi.');
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
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
    if (confirm != true) return;
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final role = _profile!['role'] as String?;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _profile!['full_name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (role == 'shipper' && _roleProfile?['user_type'] == 'company') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text(
                            'Kurumsal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_roleProfile?['company_name'] != null)
              Center(
                child: Text(
                  _roleProfile!['company_name'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Stats
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Puan',
                    (_roleProfile?['rating_avg'] as num?)?.toStringAsFixed(1) ??
                        '-',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'İş',
                    '${_roleProfile?['completed_jobs_count'] ?? 0}',
                    Icons.work_outline,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _sectionTitle('Kişisel Bilgiler'),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, _profile!['full_name'] ?? ''),
            if (_phoneData?['phone'] != null)
              _infoRow(Icons.phone_outlined, _phoneData!['phone']),
            _infoRow(
              Icons.location_on_outlined,
              '${_profile!['city'] ?? ''} / ${_profile!['district'] ?? ''}',
            ),
            if (role == 'shipper') ...[
              const SizedBox(height: 28),
              _sectionTitle('Hesap Tipi'),
              const SizedBox(height: 12),
              _infoRow(
                Icons.business_outlined,
                _roleProfile?['user_type'] == 'company' ? 'Firma' : 'Bireysel',
              ),
            ],
            if (role == 'carrier') ...[
              const SizedBox(height: 28),
              _sectionTitle('Araç Bilgileri'),
              const SizedBox(height: 12),
              _infoRow(
                Icons.local_shipping_outlined,
                _roleProfile?['vehicle_type'] ?? '',
              ),
              if (_roleProfile?['capacity_text'] != null)
                _infoRow(
                  Icons.balance_outlined,
                  _roleProfile!['capacity_text'],
                ),
              if (_plateData?['plate_number'] != null)
                _infoRow(Icons.numbers_outlined, _plateData!['plate_number']),
              const SizedBox(height: 28),
              _sectionTitle('Çalışma Tercihleri'),
              const SizedBox(height: 12),
              _infoRow(
                Icons.map_outlined,
                (_roleProfile?['service_areas'] as List?)?.join(', ') ?? '',
              ),
              _infoRow(
                Icons.category_outlined,
                (_roleProfile?['job_type_preferences'] as List?)?.join(', ') ??
                    '',
              ),
            ],
            const SizedBox(height: 28),
            _sectionTitle('Hızlı Erişim'),
            const SizedBox(height: 12),
            if (role == 'shipper')
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textHint,
                ),
                title: const Text(
                  'İlanlarım',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
                onTap: () => context.push(AppRoutes.myJobPosts),
              ),
            if (role == 'carrier')
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.send_outlined,
                  color: AppColors.textHint,
                ),
                title: const Text(
                  'Tekliflerim',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
                onTap: () => context.push(AppRoutes.myOffers),
              ),
            if (role == 'carrier')
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.success,
                ),
                title: const Text(
                  'Onay Belgeleri',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Ehliyet, K-Belgesi, Ruhsat',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
                onTap: () => context.push(AppRoutes.documentUpload),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.support_outlined,
                color: AppColors.textHint,
              ),
              title: const Text(
                'Destek',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
              onTap: () => context.push(AppRoutes.support),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.settings_outlined,
                color: AppColors.textHint,
              ),
              title: const Text(
                'Ayarlar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
              onTap: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    context.push(AppRoutes.editProfile).then((_) => _load()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Profili Düzenle'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Çıkış Yap'),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    ),
  );
  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textHint),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
