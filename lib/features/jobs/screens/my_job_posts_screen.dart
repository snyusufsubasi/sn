import 'package:flutter/material.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:tasima_app/features/jobs/data/job_repository.dart';
import 'package:tasima_app/features/jobs/data/job_state.dart';

class MyJobPostsScreen extends ConsumerStatefulWidget {
  const MyJobPostsScreen({super.key});

  @override
  ConsumerState<MyJobPostsScreen> createState() => _MyJobPostsScreenState();
}

class _MyJobPostsScreenState extends ConsumerState<MyJobPostsScreen> {
  List<JobPost>? _jobs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(jobRepositoryProvider);
      final jobs = await repo.getMyJobPosts();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Ilanlar yuklenemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İlanlarım'),
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

    if (_jobs == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Henuz ilan olusturmadiniz.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ilk yuk ilaninizi olusturarak nakliyecilerden teklif almaya baslayin.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.createJob),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yeni Ilan Olustur'),
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
                _statusBadge(job.status),
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
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(JobStatus status) {
    final map = {
      JobStatus.open.name: ('Açık', AppColors.warning),
      JobStatus.offer_accepted.name: ('Teklif Kabul Edildi', AppColors.accent),
      JobStatus.in_progress.name: ('Tasima Basladi', AppColors.primary),
      JobStatus.completed.name: ('Tamamlandı', AppColors.success),
      JobStatus.cancelled.name: ('iptal edildi', AppColors.error),
    };
    final info = map[status.name] ?? (status.name, AppColors.textHint);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.$2.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        info.$1,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: info.$2,
        ),
      ),
    );
  }
}
