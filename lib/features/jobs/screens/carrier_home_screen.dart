import 'package:flutter/material.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/auth/data/auth_state.dart';
import 'package:tasima_app/features/jobs/data/job_repository.dart';
import 'package:tasima_app/features/jobs/data/job_state.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';
import 'package:tasima_app/features/profile/data/profile_repository.dart';
import 'package:tasima_app/features/offers/data/offer_state.dart';
import 'package:tasima_app/shared/widgets/notification_bell.dart';
import 'package:tasima_app/shared/widgets/empty_state.dart';

class CarrierHomeScreen extends ConsumerStatefulWidget {
  const CarrierHomeScreen({super.key});

  @override
  ConsumerState<CarrierHomeScreen> createState() => _CarrierHomeScreenState();
}

class _CarrierHomeScreenState extends ConsumerState<CarrierHomeScreen> {
  List<JobPost>? _jobs;
  Set<String> _offeredJobIds = {};
  String? _error;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final jobRepo = ref.read(jobRepositoryProvider);
      final offerRepo = ref.read(offerRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      
      final carrierProfile = await profileRepo.getCarrierProfile();
      final carrierVehicleType = carrierProfile?['vehicle_type'] as String?;
      
      final city = _searchController.text.trim();
      final jobs = await jobRepo.getOpenJobPostsForCarrier(
        city: city.isNotEmpty ? city : null,
        carrierVehicleType: carrierVehicleType,
      );
      final offers = await offerRepo.getMyActiveOffers();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _offeredJobIds = offers.map((o) => o.jobPostId).toSet();
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'İşler yüklenemedi.');
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _switchToShipperDemo() async {
    await DevAuthService.switchToDemoShipper();
    if (!mounted) return;
    context.go(AppRoutes.shipperHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Uygun İşler'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Şehir ara...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (DevAuthService.isActive) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _switchToShipperDemo,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Yük veren demosuna geç'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
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

    if (_jobs == null) return const Center(child: CircularProgressIndicator());

    if (_jobs!.isEmpty) {
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
                  color: AppColors.accent.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Uygun ilan bulunmuyor.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Filtreleri değiştirerek tekrar deneyin.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _jobs!.length,
        itemBuilder: (context, index) => _buildJobCard(_jobs![index]),
      ),
    );
  }

  Widget _buildJobCard(JobPost job) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.jobDetail}/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Açık',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_offeredJobIds.contains(job.id))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Teklif Verdiniz',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                if (job.urgencyLevel != UrgencyLevel.normal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.urgencyLevel == UrgencyLevel.urgent ? 'Acil' : 'Çok Acil',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.cargoType.label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  '${job.pickupCity}/${job.pickupDistrict}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                ),
                const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  '${job.deliveryCity}/${job.deliveryDistrict}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  job.pickupDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (job.cargoDescription != null &&
                job.cargoDescription!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                job.cargoDescription!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
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
