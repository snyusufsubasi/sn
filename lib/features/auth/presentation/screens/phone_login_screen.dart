import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_constants.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.hideKeyboard();
    final normalized = Validators.normalizePhone(_controller.text);
    await ref.read(authControllerProvider.notifier).sendOtp(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final l10n = context.l10n;

    // OTP ekranına geçiş: app_router redirect (login + awaitingOtp → /otp)

    return Scaffold(
      backgroundColor: const Color(AppPalette.white),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Üst bant: navy800 ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: AppSpacing.massive,
                  bottom: AppSpacing.xxxl,
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                ),
                decoration: const BoxDecoration(
                  color: Color(AppPalette.navy800),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.phone_android_outlined,
                      size: AppIconSize.hero,
                      color: const Color(AppPalette.amber500),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.authPhoneTitle,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: const Color(AppPalette.white),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authPhoneSubtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(AppPalette.navy200),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // ── Beyaz alan ──────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      AppTextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        hint: '5XX XXX XX XX',
                        autofocus: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              '+90',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(AppPalette.ink900),
                              ),
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: Validators.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (AppConfig.demoMode) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Demo Yükveren',
                                onPressed: () {
                                  _controller.text =
                                      DemoConstants.shipperPhone.substring(3);
                                  _submit();
                                },
                                variant: AppButtonVariant.secondary,
                                icon: Icons.storefront_outlined,
                                fullWidth: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: 'Demo Nakliyeci',
                                onPressed: () {
                                  _controller.text =
                                      DemoConstants.carrierPhone.substring(3);
                                  _submit();
                                },
                                variant: AppButtonVariant.secondary,
                                icon: Icons.local_shipping_outlined,
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Demo OTP: ${AppConfig.demoOtpCode}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(AppPalette.ink500),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (state.failure != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.failure!.message,
                          style: context.textTheme.labelSmall
                              ?.copyWith(color: const Color(AppPalette.red600)),
                        ),
                      ],
                      const Spacer(),
                      AppButton(
                        label: l10n.authSendCode,
                        onPressed:
                            state.status == AuthStatus.busy ? null : _submit,
                        loading: state.status == AuthStatus.busy,
                        variant: AppButtonVariant.accent,
                        trailingIcon: Icons.arrow_forward,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
