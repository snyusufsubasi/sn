import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/admin_controller.dart';
import 'admin_disputes_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overviewAsync = ref.watch(adminOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(e.toString()),
          ),
        ),
        data: (overview) => ListView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(l10n.adminUsers),
              subtitle: Text(l10n.adminUsersList),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminUsersScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: Text(l10n.adminDisputes),
              subtitle: Text(l10n.adminDisputesSubtitle),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminDisputesScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _MetricCard(
              label: l10n.adminMetricUsers,
              value: '${overview.totalUsers}',
              icon: Icons.people_alt_outlined,
            ),
            _MetricCard(
              label: l10n.adminMetricJobs,
              value: '${overview.openJobs}',
              icon: Icons.local_shipping_outlined,
            ),
            _MetricCard(
              label: l10n.adminMetricDisputes,
              value: '${overview.openDisputes}',
              icon: Icons.report_problem_outlined,
              highlight: overview.openDisputes > 0,
            ),
            _MetricCard(
              label: l10n.adminMetricPayments,
              value: '${overview.pendingPayments}',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        color: highlight ? AppColors.ink50 : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: scheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
