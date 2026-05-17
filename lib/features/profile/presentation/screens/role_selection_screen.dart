import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/user_profile.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? _selected;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() => _selected = role);
    _scaleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      automaticallyImplyLeading: false,
      scrollable: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.huge),
          Text(
            l10n.rolePickTitle,
            style: context.textTheme.headlineLarge?.copyWith(
              color: const Color(AppPalette.ink900),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.rolePickSubtitle,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: const Color(AppPalette.ink500)),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _buildRoleCard(
            role: UserRole.shipper,
            title: l10n.roleShipper,
            description: l10n.roleShipperDesc,
            icon: Icons.inventory_2_outlined,
            borderColor: const Color(AppPalette.navy800),
            isSelected: _selected == UserRole.shipper,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildRoleCard(
            role: UserRole.carrier,
            title: l10n.roleCarrier,
            description: l10n.roleCarrierDesc,
            icon: Icons.local_shipping_outlined,
            borderColor: const Color(AppPalette.amber500),
            isSelected: _selected == UserRole.carrier,
          ),
          const Spacer(),
          AppButton(
            label: l10n.commonContinue,
            onPressed: _selected == null
                ? null
                : () => context.push(
                      '/profile-setup',
                      extra: _selected,
                    ),
            variant: AppButtonVariant.accent,
            trailingIcon: Icons.arrow_forward,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required Color borderColor,
    required bool isSelected,
  }) {
    final scale = isSelected ? 1.02 : 1.0;
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? borderColor.withOpacity(0.08)
                : const Color(AppPalette.ink50),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? borderColor : const Color(AppPalette.ink200),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // İkon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? borderColor.withOpacity(0.12)
                      : const Color(AppPalette.ink100),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: AppIconSize.xl,
                  color: isSelected ? borderColor : const Color(AppPalette.ink700),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Metin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: const Color(AppPalette.ink900),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(AppPalette.ink600),
                      ),
                    ),
                  ],
                ),
              ),
              // Seçim göstergesi
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? borderColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? borderColor : const Color(AppPalette.ink300),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(AppPalette.white),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
