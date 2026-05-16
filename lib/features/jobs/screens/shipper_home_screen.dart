import 'package:flutter/material.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:tasima_app/features/auth/data/auth_state.dart';
import 'package:tasima_app/features/jobs/data/job_repository.dart';
import 'package:tasima_app/features/jobs/data/job_state.dart';
import 'package:tasima_app/shared/widgets/notification_bell.dart';

class ShipperHomeScreen extends ConsumerStatefulWidget {
  const ShipperHomeScreen({super.key});

  @override
  ConsumerState<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends ConsumerState<ShipperHomeScreen> {
  List<JobPost>? _recentJobs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(jobRepositoryProvider);
      final jobs = await repo.getMyJobPosts(limit: 3);
      if (!mounted) return;
      setState(() {
        _recentJobs = jobs;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recentJobs = [];
      });
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _switchToCarrierDemo() async {
    await DevAuthService.switchToDemoCarrier();
    if (!mounted) return;
    context.go(AppRoutes.carrierHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yük Veren Paneli'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          TextButton(
            onPressed: _signOut,
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Merhaba, bugün ne taşıtmak istersiniz?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.createJob).then((_) => _load()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: const Text(
                    'Yeni Yük İlanı Oluştur',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              if (DevAuthService.isActive) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _switchToCarrierDemo,
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Nakliyeci demosuna geç'),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (_recentJobs != null && _recentJobs!.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Aktif İlanlarım',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.myJobPosts),
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(_recentJobs!.map(_jobCard)),
              ] else if (_recentJobs != null && _recentJobs!.isEmpty) ...[
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(15),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Henüz ilan oluşturmadınız.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'İlk yük ilanınızı oluşturarak nakliyecilerden teklif almaya başlayın.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard(JobPost job) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.jobDetail}/${job.id}'),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.cargoType.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.pickupCity} → ${job.deliveryCity} · ${job.pickupDate}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _statusDot(job.status),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(JobStatus status) {
    final map = {
      JobStatus.open: AppColors.warning,
      JobStatus.offer_accepted: AppColors.accent,
      JobStatus.in_progress: AppColors.primary,
      JobStatus.completed: AppColors.success,
      JobStatus.cancelled: AppColors.error,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: map[status] ?? AppColors.textHint,
        shape: BoxShape.circle,
      ),
    );
  }

  String _cargoLabel(String v) {
    const m = {
      'ev_esyasi': 'Ev Eşyası',
      'parca_esya': 'Parça Eşya',
      'paletli_urun': 'Paletli Ürün',
      'insaat_malzemesi': 'İnşaat Malzemesi',
      'makine': 'Makine',
      'mobilya': 'Mobilya',
      'gida_disi': 'Gıda Harici Ürün',
      'Diğer': 'Diğer',
    };
    return m[v] ?? v;
  }
}
