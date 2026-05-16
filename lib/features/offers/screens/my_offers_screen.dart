import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/offers/data/offer_repository.dart';
import 'package:tasima_app/features/offers/data/offer_state.dart';

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  List<Offer>? _offers;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final offers = await ref
          .read(offerRepositoryProvider)
          .getMyActiveOffers();
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Teklifler yüklenemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tekliflerim'),
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
    if (_offers == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_offers!.isEmpty) {
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
                  Icons.send_outlined,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Henüz teklif vermediniz.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: _offers!.length,
        itemBuilder: (_, i) {
          final o = _offers![i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${o.amount.toStringAsFixed(0)} TL',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    _statusBadge(o.status),
                  ],
                ),
                if (o.note != null && o.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    o.note!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Ilan: ${o.jobPostId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String s) {
    final m = {
      'pending': ('Beklemede', AppColors.warning),
      'accepted': ('Kabul Edildi', AppColors.success),
      'rejected': ('Reddedildi', AppColors.error),
      'withdrawn': ('Geri Çekildi', AppColors.textHint),
    };
    final i = m[s] ?? (s, AppColors.textHint);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: i.$2.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        i.$1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: i.$2,
        ),
      ),
    );
  }
}
