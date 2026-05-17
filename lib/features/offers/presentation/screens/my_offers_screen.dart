import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../controllers/offers_controller.dart';
import '../widgets/offer_card.dart';

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tekliflerim')),
      body: RefreshIndicator(
        color: const Color(AppPalette.ink900),
        onRefresh: () async => ref.invalidate(myOffersProvider),
        child: offersAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(myOffersProvider),
          ),
          data: (offers) {
            if (offers.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const AppEmptyState(
                    icon: Icons.local_offer_outlined,
                    title: 'Henüz teklifin yok',
                    subtitle:
                        'Açık ilanlara teklif verdiğinde burada listelenecek.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final offer = offers[i];
                return Column(
                  children: [
                    OfferCard(
                      offer: offer,
                      showCarrierActions: offer.isPending,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context
                            .push('/jobs/${offer.jobPostId}?view=detail'),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('İlanı Aç'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
