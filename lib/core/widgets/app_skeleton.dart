import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';
import '../theme/motion/app_duration.dart';

/// ARACIYOK skeleton yükleme bileşenleri.
///
/// Daha yavaş shimmer (2000ms) — 40+ kullanıcı için sakin.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    required this.width,
    required this.height,
    super.key,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(AppPalette.ink200),
      highlightColor: const Color(AppPalette.ink100),
      period: AppDuration.shimmer,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(AppPalette.ink200),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Liste öğesi skeleton'u (kart formatında).
class AppSkeletonListItem extends StatelessWidget {
  const AppSkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(AppPalette.ink200),
      highlightColor: const Color(AppPalette.ink100),
      period: AppDuration.shimmer,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(AppPalette.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(AppPalette.ink300)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppPalette.ink200),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(AppPalette.ink200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 14,
                    width: 160,
                    decoration: BoxDecoration(
                      color: const Color(AppPalette.ink200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kart skeleton'u.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(AppPalette.ink200),
      highlightColor: const Color(AppPalette.ink100),
      period: AppDuration.shimmer,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        height: height,
        decoration: BoxDecoration(
          color: const Color(AppPalette.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(AppPalette.ink300)),
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 18,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(AppPalette.ink200),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(AppPalette.ink200),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 14,
              width: 260,
              decoration: BoxDecoration(
                color: const Color(AppPalette.ink200),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar skeleton'u (yuvarlak).
class AppSkeletonAvatar extends StatelessWidget {
  const AppSkeletonAvatar({super.key, this.radius = 32});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(AppPalette.ink200),
      highlightColor: const Color(AppPalette.ink100),
      period: AppDuration.shimmer,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(AppPalette.ink200),
      ),
    );
  }
}
