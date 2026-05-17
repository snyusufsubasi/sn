import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/user_profile.dart';
import '../controllers/profile_controller.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({required this.role, super.key});

  final UserRole role;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _companyName = TextEditingController();
  final _taxNumber = TextEditingController();

  UserType _userType = UserType.individual;
  bool _saving = false;

  @override
  void dispose() {
    _fullName.dispose();
    _city.dispose();
    _district.dispose();
    _companyName.dispose();
    _taxNumber.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.hideKeyboard();
    final auth = ref.read(authControllerProvider);
    final uid = auth.userId;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final profile = UserProfile(
        id: uid,
        role: widget.role,
        userType: _userType,
        fullName: _fullName.text.trim(),
        city: _city.text.trim(),
        district: _district.text.trim(),
        companyName:
            _userType == UserType.company ? _companyName.text.trim() : null,
        taxNumber:
            _userType == UserType.company ? _taxNumber.text.trim() : null,
      );

      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.createProfile(profile);

      switch (result) {
        case Success():
          // Telefonu private tabloya yaz
          if (auth.phoneE164 != null) {
            await repo.savePhoneNumber(
              userId: uid,
              phoneE164: auth.phoneE164!,
            );
          }
          ref.invalidate(currentProfileProvider);
          if (!mounted) return;
          if (widget.role == UserRole.carrier) {
            context.go(RoutePaths.carrierProfileSetup);
          } else {
            await ref
                .read(authControllerProvider.notifier)
                .markProfileCompleted();
            if (!mounted) return;
            context.go(RoutePaths.home);
          }
        case ResultFailure(:final failure):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCompany = _userType == UserType.company;

    return AppScaffold(
      title: l10n.profileSetupTitle,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _UserTypeChoice(
                    label: l10n.userTypeIndividual,
                    icon: Icons.person_outline,
                    selected: _userType == UserType.individual,
                    onTap: () =>
                        setState(() => _userType = UserType.individual),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UserTypeChoice(
                    label: l10n.userTypeCompany,
                    icon: Icons.business_outlined,
                    selected: _userType == UserType.company,
                    onTap: () => setState(() => _userType = UserType.company),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: _fullName,
              label: l10n.profileFullName,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  Validators.required(v, label: l10n.profileFullName),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _city,
                    label: l10n.profileCity,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.required(v, label: l10n.profileCity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _district,
                    label: l10n.profileDistrict,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.required(v, label: l10n.profileDistrict),
                  ),
                ),
              ],
            ),
            if (isCompany) ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _companyName,
                label: l10n.profileCompanyName,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(
                  v,
                  label: l10n.profileCompanyName,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _taxNumber,
                label: l10n.profileTaxNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: Validators.vergiNo,
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: l10n.commonContinue,
              onPressed: _saving ? null : _submit,
              loading: _saving,
              trailingIcon: Icons.arrow_forward,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _UserTypeChoice extends StatelessWidget {
  const _UserTypeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: selected ? AppColors.ink900 : AppColors.white,
      borderColor: selected ? AppColors.ink900 : AppColors.ink200,
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? AppColors.white : AppColors.ink800,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.white : AppColors.ink900,
            ),
          ),
        ],
      ),
    );
  }
}
