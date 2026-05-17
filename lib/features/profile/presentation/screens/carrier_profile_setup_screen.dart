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
import '../../data/models/carrier_profile.dart';
import '../controllers/profile_controller.dart';

/// Nakliyeci rolü seçilince doldurulan ek profil ekranı.
///
/// Profile setup'ta role=carrier seçildiğinde bu ekran açılır.
/// Başarılı kayıt sonrası kullanıcı authenticated duruma geçirilir.
class CarrierProfileSetupScreen extends ConsumerStatefulWidget {
  const CarrierProfileSetupScreen({super.key});

  @override
  ConsumerState<CarrierProfileSetupScreen> createState() =>
      _CarrierProfileSetupScreenState();
}

class _CarrierProfileSetupScreenState
    extends ConsumerState<CarrierProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _capacity = TextEditingController();
  final _plate = TextEditingController();
  final _iban = TextEditingController();

  String _vehicleType = 'Kamyon';
  String _trailerType = 'Tenteli';
  bool _saving = false;

  static const _vehicleTypes = ['Kamyon', 'Tır'];
  static const _trailerTypes = [
    'Tenteli',
    'Açık Kasa',
    'Kapalı Kasa',
    'Frigorifik',
    'Damperli',
    'Lowbed',
  ];

  String _vehicleLabel(String value) {
    return switch (value) {
      'Kamyon' => context.l10n.carrierVehicleTruck,
      'Tır' => context.l10n.carrierVehicleSemi,
      _ => value,
    };
  }

  String _trailerLabel(String value) {
    return switch (value) {
      'Tenteli' => context.l10n.carrierTrailerCurtainsider,
      'Açık Kasa' => context.l10n.carrierTrailerOpenBed,
      'Kapalı Kasa' => context.l10n.carrierTrailerClosedBox,
      'Frigorifik' => context.l10n.carrierTrailerReefer,
      'Damperli' => context.l10n.carrierTrailerTipper,
      'Lowbed' => context.l10n.carrierTrailerLowbed,
      _ => value,
    };
  }

  @override
  void dispose() {
    _capacity.dispose();
    _plate.dispose();
    _iban.dispose();
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
      final carrier = CarrierProfile(
        userId: uid,
        vehicleType: _vehicleType,
        capacityTons: double.parse(_capacity.text.replaceAll(',', '.')),
        trailerType: _trailerType,
        plate: _plate.text.toUpperCase().replaceAll(' ', ''),
        iban: _iban.text.replaceAll(' ', '').toUpperCase(),
      );

      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.upsertCarrierProfile(carrier);
      switch (result) {
        case Success():
          await ref
              .read(authControllerProvider.notifier)
              .markProfileCompleted();
          if (mounted) context.go(RoutePaths.home);
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
    return AppScaffold(
      title: l10n.carrierSetupTitle,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.carrierVehicleType,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: _vehicleTypes
                  .map(
                    (v) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppCard(
                          onTap: () => setState(() => _vehicleType = v),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          color: _vehicleType == v
                              ? AppColors.ink900
                              : null,
                          child: Center(
                            child: Text(
                              _vehicleLabel(v),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: _vehicleType == v
                                        ? AppColors.white
                                        : null,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _capacity,
              label: l10n.carrierCapacity,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                LengthLimitingTextInputFormatter(5),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.carrierCapacityRequired;
                }
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return l10n.carrierCapacityInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.carrierTrailerType,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trailerTypes.map((t) {
                final selected = _trailerType == t;
                return GestureDetector(
                  onTap: () => setState(() => _trailerType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.ink900 : AppColors.ink50,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      _trailerLabel(t),
                      style: TextStyle(
                        color: selected ? AppColors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _iban,
              label: l10n.carrierIban,
              hint: 'TR00 0000 0000 0000 0000 0000 00',
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(34),
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 ]')),
              ],
              validator: Validators.iban,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _plate,
              label: l10n.carrierPlate,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 ]')),
              ],
              validator: Validators.plaka,
            ),
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
