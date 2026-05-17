import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/jobs/data/models/job_constants.dart';
import '../../features/jobs/presentation/controllers/jobs_controller.dart';
import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';
import 'app_button.dart';
import 'app_city_picker.dart';

/// Sticky filter bar for the jobs listing page.
///
/// Sits between the AppBar and the job cards. 3-row compact layout:
/// - Row 1: Nereden (sec) -> Nereye (sec) — side-by-side city pickers
/// - Row 2: Yuk tipi dropdown + Arac tipi dropdown
/// - Row 3: Filtrele action button (accent, not full width)
class AppFilterBar extends ConsumerWidget {
  const AppFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobFilterNotifierProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(AppPalette.white),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: const Color(AppPalette.ink900).withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Origin ↔ Destination ──────────────────────────
          Row(
            children: [
              Expanded(
                child: _CityChip(
                  label: 'Nereden',
                  city: filter.originCity,
                  icon: Icons.location_on_outlined,
                  onTap: () async {
                    final city = await AppCityPicker.show(context);
                    if (city != null && context.mounted) {
                      ref
                          .read(jobFilterNotifierProvider.notifier)
                          .setOriginCity(city);
                    }
                  },
                  onClear: filter.originCity == null
                      ? null
                      : () => ref
                          .read(jobFilterNotifierProvider.notifier)
                          .setOriginCity(null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: const Color(AppPalette.ink500),
                ),
              ),
              Expanded(
                child: _CityChip(
                  label: 'Nereye',
                  city: filter.destinationCity,
                  icon: Icons.tour_outlined,
                  onTap: () async {
                    final city = await AppCityPicker.show(context);
                    if (city != null && context.mounted) {
                      ref
                          .read(jobFilterNotifierProvider.notifier)
                          .setDestinationCity(city);
                    }
                  },
                  onClear: filter.destinationCity == null
                      ? null
                      : () => ref
                          .read(jobFilterNotifierProvider.notifier)
                          .setDestinationCity(null),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Row 2: Cargo type + Trailer type ────────────────────
          Row(
            children: [
              Expanded(
                child: _CompactDropdown<String>(
                  label: 'Yük tipi',
                  value: filter.cargoType,
                  items: JobConstants.cargoTypes,
                  hint: 'Seç',
                  onChanged: (v) {
                    ref
                        .read(jobFilterNotifierProvider.notifier)
                        .setCargoType(v);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CompactDropdown<String>(
                  label: 'Araç tipi',
                  value: filter.trailerType,
                  items: JobConstants.trailerTypes,
                  hint: 'Seç',
                  onChanged: (v) {
                    ref
                        .read(jobFilterNotifierProvider.notifier)
                        .setTrailerType(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Row 3: Filtrele button (accent, not full width) ────
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Filtrele',
              variant: AppButtonVariant.accent,
              icon: Icons.tune,
              fullWidth: false,
              size: AppButtonSize.small,
              onPressed: () {
                // Filter state is already reactive via the notifier.
                // Button serves as a visual CTA and confirmation trigger.
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable city chip showing the selected city name or a placeholder label.
class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.city,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? city;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = city != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(AppPalette.navy50)
              : const Color(AppPalette.ink100),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: hasValue
                ? const Color(AppPalette.navy200)
                : const Color(AppPalette.ink200),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasValue
                  ? const Color(AppPalette.navy700)
                  : const Color(AppPalette.ink500),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                city ?? label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? const Color(AppPalette.navy800)
                      : const Color(AppPalette.ink600),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: const Color(AppPalette.ink500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A compact dropdown field matching the design system.
///
/// Used for cargo type and trailer type selections in the filter bar.
class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String hint;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: hasValue
            ? const Color(AppPalette.navy50)
            : const Color(AppPalette.ink100),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: hasValue
              ? const Color(AppPalette.navy200)
              : const Color(AppPalette.ink200),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 13,
              color: const Color(AppPalette.ink500),
            ),
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(AppPalette.navy800),
          ),
          icon: Icon(
            Icons.expand_more,
            size: 18,
            color: const Color(AppPalette.ink500),
          ),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(
                'Tümü',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(AppPalette.ink500),
                ),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T?>(
                value: item,
                child: Text('$item'),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
