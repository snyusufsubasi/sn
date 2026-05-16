import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, OtpType;
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/data/supabase_client.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      _showError('Lütfen 6 haneli doğrulama kodunu girin.');
      return;
    }

    if (DevAuthService.isActive) {
      if (code == '123456') {
        await DevAuthService.setLoggedIn(true);
        if (!mounted) return;
        _navigateAfterAuth();
      } else {
        _showError('Demo modunda kod 123456 olmalıdır.');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseClientManager.instance.client.auth.verifyOTP(
        phone: widget.phone,
        token: code,
        type: OtpType.sms,
      );
      if (!mounted) return;
      _navigateAfterAuth();
    } on AuthException catch (e) {
      if (!mounted) return;
      debugPrint('OTP VERIFY ERROR: ${e.message} (code: ${e.statusCode})');
      _showError(_mapOtpError(e.message));
    } catch (e) {
      if (!mounted) return;
      debugPrint('OTP VERIFY UNEXPECTED: $e');
      _showError('Doğrulama yapılamadı. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (DevAuthService.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Demo modu: kod 123456'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isResending = true);
    try {
      await SupabaseClientManager.instance.client.auth.signInWithOtp(
        phone: widget.phone,
        shouldCreateUser: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kod tekrar gönderildi.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(_mapOtpError(e.message));
    } catch (e) {
      if (!mounted) return;
      _showError('Kod tekrar gönderilemedi.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _mapOtpError(String message) {
    final m = message.toLowerCase();
    if (m.contains('expired')) {
      return 'Kodun süresi doldu. Lütfen tekrar kod isteyin.';
    }
    if (m.contains('invalid')) return 'Kod hatalı.';
    if (m.contains('not found')) return 'Kod geçerli değil veya süresi dolmuş.';
    return 'Kod hatalı veya süresi dolmuş.';
  }

  Future<void> _navigateAfterAuth() async {
    try {
      if (DevAuthService.isActive) {
        final role = await DevAuthService.getRole();
        if (role == null || role.isEmpty) {
          if (!mounted) return;
          context.go(AppRoutes.roleSelection);
          return;
        }
        final setupComplete = await DevAuthService.isProfileSetupComplete();
        if (!mounted) return;
        if (role == 'shipper') {
          context.go(
            setupComplete
                ? AppRoutes.shipperHome
                : AppRoutes.shipperProfileSetup,
          );
        } else if (role == 'carrier') {
          context.go(
            setupComplete
                ? AppRoutes.carrierHome
                : AppRoutes.carrierProfileSetup,
          );
        } else {
          context.go(AppRoutes.roleSelection);
        }
        return;
      }

      final userId = SupabaseClientManager.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        context.go(AppRoutes.roleSelection);
        return;
      }

      final profile = await SupabaseClientManager.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (!mounted) return;
      if (profile == null || profile['role'] == null) {
        context.go(AppRoutes.roleSelection);
        return;
      }

      final role = profile['role'] as String;
      if (role == 'shipper') {
        context.go(AppRoutes.shipperHome);
      } else if (role == 'carrier') {
        context.go(AppRoutes.carrierHome);
      } else {
        context.go(AppRoutes.roleSelection);
      }
    } catch (e) {
      if (!mounted) return;
      context.go(AppRoutes.roleSelection);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 40,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Doğrulama Kodu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  DevAuthService.isActive
                      ? 'Demo modu'
                      : 'Kod şu numaraya gönderildi:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phone,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                if (DevAuthService.isActive)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Kod: 123456',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  onChanged: (v) {
                    if (v.length == 6) _verify();
                  },
                  decoration: const InputDecoration(
                    hintText: '123456',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_outlined, size: 20),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kodu Doğrula'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kodu Tekrar Gönder'),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
