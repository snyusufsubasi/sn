import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/routing/job_routes.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/theme/motion/app_curves.dart';
import '../../../../core/theme/motion/app_duration.dart';
import '../../../../core/widgets/app_filter_bar.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/job_post.dart';
import '../controllers/jobs_controller.dart';
import '../widgets/job_card.dart';
import 'jobs_filter_sheet.dart';

enum CarrierJobsTab {
  available,
  active,
  completed,
}

class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({
    this.initialCarrierTab = CarrierJobsTab.available,
    super.key,
  });

  final CarrierJobsTab initialCarrierTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final l10n = context.l10n;

    return profileAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        body: AppErrorView(message: e.toString()),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.tabJobs)),
            body: AppEmptyState(
              title: 'Profil bulunamadı',
              subtitle: 'Devam etmek için profilini tamamla.',
              actionLabel: l10n.commonContinue,
              onAction: () => context.go('/role-selection'),
            ),
          );
        }

        return profile.isShipper
            ? const _ShipperJobsView()
            : _CarrierJobsView(initialTab: initialCarrierTab);
      },
    );
  }
}

/// Yükveren görünümü — tüm ilanlar + devam eden.
class _ShipperJobsView extends ConsumerWidget {
  const _ShipperJobsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabJobs),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/jobs/new'),
              tooltip: l10n.jobsCreateNew,
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(AppPalette.ink900),
            unselectedLabelColor: Color(AppPalette.ink600),
            indicatorColor: Color(AppPalette.ink900),
            labelStyle: TextStyle(fontWeight: FontWeight.w800),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Tümü'),
              Tab(text: 'Devam eden'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShipperAllJobsTab(),
            _ShipperInProgressJobsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/jobs/new'),
          backgroundColor: Color(AppPalette.ink900),
          foregroundColor: Color(AppPalette.white),
          icon: const Icon(Icons.add),
          label: Text(l10n.jobsCreateNew),
        ),
      ),
    );
  }
}

class _ShipperAllJobsTab extends ConsumerWidget {
  const _ShipperAllJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myJobsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myJobsProvider),
      color: Color(AppPalette.ink900),
      child: jobsAsync.when(
        loading: () => const _JobListSkeleton(),
        error: (e, _) => AppErrorView(
          message: _readableError(e),
          onRetry: () => ref.invalidate(myJobsProvider),
        ),
        data: (jobs) => jobs.isEmpty
            ? _emptyShipper(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: jobs.length,
                itemBuilder: (_, i) => JobCard(
                  job: jobs[i],
                  onTap: () => context.push(jobDestinationPath(jobs[i])),
                )
                    .animate(
                      delay: Duration(milliseconds: i < 5 ? i * 50 : 200),
                    )
                    .fadeIn(
                      duration: AppDuration.normal,
                      curve: AppCurves.decelerate,
                    )
                    .slideX(begin: 0.05, end: 0),
              ),
      ),
    );
  }
}

class _ShipperInProgressJobsTab extends ConsumerWidget {
  const _ShipperInProgressJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myInProgressShipperJobsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myInProgressShipperJobsProvider),
      color: Color(AppPalette.ink900),
      child: jobsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorView(
          message: _readableError(e),
          onRetry: () => ref.invalidate(myInProgressShipperJobsProvider),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                const AppEmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Devam eden taşıma yok',
                  subtitle: 'Teklif kabul edilen ilanlar burada görünür.',
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ),
            itemCount: jobs.length,
            itemBuilder: (_, i) => JobCard(
              job: jobs[i],
              onTap: () => context.push(jobDestinationPath(jobs[i])),
            )
                .animate(
                  delay: Duration(milliseconds: i < 5 ? i * 50 : 200),
                )
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideX(begin: 0.05, end: 0),
          );
        },
      ),
    );
  }
}

Widget _emptyShipper(BuildContext context) {
  final l10n = context.l10n;
  return ListView(
    // ListView ile sarıyoruz ki pull-to-refresh çalışsın
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
      AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.jobsEmpty,
        subtitle: l10n.jobsEmptyShipperSubtitle,
        actionLabel: l10n.jobsCreateNew,
        onAction: () => GoRouter.of(context).push('/jobs/new'),
      ),
    ],
  );
}

/// Nakliyeci görünümü — açık ilanlar + filtre + aktif taşımalarım.
class _CarrierJobsView extends ConsumerStatefulWidget {
  const _CarrierJobsView({required this.initialTab});

  final CarrierJobsTab initialTab;

  @override
  ConsumerState<_CarrierJobsView> createState() => _CarrierJobsViewState();
}

class _CarrierJobsViewState extends ConsumerState<_CarrierJobsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.removeListener(() => setState(() {}));
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(jobFilterNotifierProvider);
    final isAvailableTab = _tab.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabJobs),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (!filter.isEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(AppPalette.ink900),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => showJobsFilterSheet(context),
            tooltip: l10n.commonFilter,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: Color(AppPalette.ink900),
          unselectedLabelColor: Color(AppPalette.ink600),
          indicatorColor: Color(AppPalette.ink900),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.jobsTabAvailable),
            Tab(text: l10n.jobsTabActive),
            const Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter bar + active filter chips — only on "Mevcut" tab
          if (isAvailableTab) _buildFilterSection(context, filter),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _AvailableJobsTab(),
                _ActiveCarrierJobsTab(),
                _CompletedCarrierJobsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, JobFilter filter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppFilterBar(),
        if (!filter.isEmpty) _buildActiveFilterChips(context, filter),
      ],
    );
  }

  Widget _buildActiveFilterChips(BuildContext context, JobFilter filter) {
    final chips = <Widget>[];
    void addChip(String label, VoidCallback onClear) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: Chip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: onClear,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            labelPadding: const EdgeInsets.only(left: 4, right: 2),
          ),
        ),
      );
    }

    final notifier = ref.read(jobFilterNotifierProvider.notifier);

    if (filter.originCity != null) {
      addChip(filter.originCity!, () => notifier.setOriginCity(null));
    }
    if (filter.destinationCity != null) {
      addChip(
        filter.destinationCity!,
        () => notifier.setDestinationCity(null),
      );
    }
    if (filter.cargoType != null) {
      addChip(filter.cargoType!, () => notifier.setCargoType(null));
    }
    if (filter.trailerType != null) {
      addChip(filter.trailerType!, () => notifier.setTrailerType(null));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }
}

class _AvailableJobsTab extends ConsumerWidget {
  const _AvailableJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobFilterNotifierProvider);
    final jobsAsync = ref.watch(openJobsProvider(filter));
    final l10n = context.l10n;

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async => ref.invalidate(openJobsProvider(filter)),
      child: jobsAsync.when(
        loading: () => const _JobListSkeleton(),
        error: (e, _) => AppErrorView(
          message: _readableError(e),
          onRetry: () => ref.invalidate(openJobsProvider(filter)),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              AppEmptyState(
                icon: Icons.search,
                title: l10n.jobsEmpty,
                subtitle: filter.isEmpty
                    ? l10n.jobsEmptyCarrierSubtitle
                    : l10n.jobsEmptyWithFilters,
                actionLabel: filter.isEmpty ? null : l10n.jobsClearFilters,
                onAction: filter.isEmpty
                    ? null
                    : () =>
                        ref.read(jobFilterNotifierProvider.notifier).clear(),
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ),
            itemCount: jobs.length,
            itemBuilder: (_, i) => JobCard(
              job: jobs[i],
              onTap: () =>
                  GoRouter.of(context).push(jobDestinationPath(jobs[i])),
            )
                .animate(
                  delay: Duration(milliseconds: i < 5 ? i * 50 : 200),
                )
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideX(begin: 0.05, end: 0),
          );
        },
      ),
    );
  }
}

class _ActiveCarrierJobsTab extends ConsumerWidget {
  const _ActiveCarrierJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myActiveCarrierJobsProvider);
    final l10n = context.l10n;

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async => ref.invalidate(myActiveCarrierJobsProvider),
      child: jobsAsync.when(
        loading: () => const _JobListSkeleton(),
        error: (e, _) => AppErrorView(
          message: _readableError(e),
          onRetry: () => ref.invalidate(myActiveCarrierJobsProvider),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              AppEmptyState(
                icon: Icons.local_shipping_outlined,
                title: l10n.jobsNoActiveCarrierJobs,
                subtitle: l10n.jobsNoActiveCarrierJobsSubtitle,
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ),
            itemCount: jobs.length,
            itemBuilder: (_, i) => JobCard(
              job: jobs[i],
              onTap: () =>
                  GoRouter.of(context).push(jobDestinationPath(jobs[i])),
            )
                .animate(
                  delay: Duration(milliseconds: i < 5 ? i * 50 : 200),
                )
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideX(begin: 0.05, end: 0),
          );
        },
      ),
    );
  }
}

class _CompletedCarrierJobsTab extends ConsumerWidget {
  const _CompletedCarrierJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myCompletedCarrierJobsProvider);

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async => ref.invalidate(myCompletedCarrierJobsProvider),
      child: jobsAsync.when(
        loading: () => const _JobListSkeleton(),
        error: (e, _) => AppErrorView(
          message: _readableError(e),
          onRetry: () => ref.invalidate(myCompletedCarrierJobsProvider),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              const AppEmptyState(
                icon: Icons.task_alt_outlined,
                title: 'Henüz tamamlanan işin yok',
                subtitle: 'Teslimatı tamamlanan ve kapanan taşıma işleri '
                    'burada görünür.',
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ),
            itemCount: jobs.length,
            itemBuilder: (_, i) => JobCard(
              job: jobs[i],
              onTap: () =>
                  GoRouter.of(context).push(jobDestinationPath(jobs[i])),
            )
                .animate(
                  delay: Duration(milliseconds: i < 5 ? i * 50 : 200),
                )
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideX(begin: 0.05, end: 0),
          );
        },
      ),
    );
  }
}

String _readableError(Object e) {
  if (e is AppFailure) return e.message;
  if (e is Exception) return e.toString().replaceFirst('Exception: ', '');
  return e.toString();
}

class _JobListSkeleton extends StatelessWidget {
  const _JobListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        AppSkeletonListItem(),
        AppSkeletonListItem(),
        AppSkeletonListItem(),
        AppSkeletonListItem(),
      ],
    );
  }
}
