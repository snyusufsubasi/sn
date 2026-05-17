import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.length < AppConfig.otpLength) return;
    await context.hideKeyboard();
    await ref.read(authControllerProvider.notifier).verifyOtp(_controller.text);
    // Shake if error state after submission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentState = ref.read(authControllerProvider);
        if (currentState.failure != null) {
          _shakeController.forward(from: 0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final l10n = context.l10n;

    // Auth durumuna göre yönlendirme
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.authenticatedNoProfile) {
        context.go('/role-selection');
      }
    });

    final hasError = state.failure != null;

    final defaultPin = PinTheme(
      width: 52,
      height: 58,
      textStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(AppPalette.ink900),
      ),
      decoration: BoxDecoration(
        color: const Color(AppPalette.ink50),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(AppPalette.ink200)),
      ),
    );

    final focusedPin = defaultPin.copyWith(
      decoration: defaultPin.decoration!.copyWith(
        border: Border.all(
          color: const Color(AppPalette.navy800),
          width: 1.5,
        ),
      ),
    );

    final errorPin = defaultPin.copyWith(
      decoration: defaultPin.decoration!.copyWith(
        border: Border.all(
          color: const Color(AppPalette.red600),
          width: 1.5,
        ),
      ),
    );

    return AppScaffold(
      scrollable: false,
      title: '',
      automaticallyImplyLeading: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.authOtpTitle,
            style: context.textTheme.headlineLarge?.copyWith(
              color: const Color(AppPalette.ink900),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.authOtpSubtitle(
              state.phoneE164 != null
                  ? Formatters.phone(state.phoneE164!)
                  : '',
            ),
            style: context.textTheme.bodyMedium
                ?.copyWith(color: const Color(AppPalette.ink500)),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ListenableBuilder(
            listenable: _shakeAnimation,
            builder: (context, child) {
              final offset = (_shakeAnimation.value * 8).roundToDouble();
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Center(
              child: Pinput(
                controller: _controller,
                length: AppConfig.otpLength,
                autofocus: true,
                defaultPinTheme: defaultPin,
                focusedPinTheme: focusedPin,
                errorPinTheme: errorPin,
                forceErrorState: hasError,
                onCompleted: (_) => _submit(),
                keyboardType: TextInputType.number,
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2,
                      height: 24,
                      color: const Color(AppPalette.amber500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                state.failure!.message,
                style: context.textTheme.labelSmall
                    ?.copyWith(color: const Color(AppPalette.red600)),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: TextButton(
              onPressed: state.otpResendSeconds > 0
                  ? null
                  : () =>
                      ref.read(authControllerProvider.notifier).resendOtp(),
              child: Text(
                state.otpResendSeconds > 0
                    ? l10n.authOtpResendIn(state.otpResendSeconds)
                    : l10n.authOtpResend,
                style: context.textTheme.labelMedium?.copyWith(
                  color: state.otpResendSeconds > 0
                      ? const Color(AppPalette.ink400)
                      : const Color(AppPalette.ink900),
                ),
              ),
            ),
          ),
          const Spacer(),
          AppButton(
            label: l10n.commonContinue,
            onPressed: state.status == AuthStatus.busy ? null : _submit,
            loading: state.status == AuthStatus.busy,
            variant: AppButtonVariant.accent,
            trailingIcon: Icons.arrow_forward,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
