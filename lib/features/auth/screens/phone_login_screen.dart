import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/data/supabase_client.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _showError('Geçerli bir telefon numarası girin.');
      return;
    }

    final formattedPhone = _formatPhone(phone);
    if (formattedPhone == null) {
      _showError(
        'Telefon numarasını başında +90 olacak şekilde girin.\nÖrnek: +90 532 111 22 33',
      );
      return;
    }

    if (DevAuthService.isActive) {
      // Dev mode: skip Supabase, go directly to OTP
      context.push(AppRoutes.otpVerification, extra: formattedPhone);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseClientManager.instance.client.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: true,
      );

      if (!mounted) return;
      context.push(AppRoutes.otpVerification, extra: formattedPhone);
    } on AuthException catch (e) {
      if (!mounted) return;
      debugPrint('PHONE OTP ERROR: ${e.message} (code: ${e.statusCode})');
      _showError(_mapSupabaseError(e.message));
    } catch (e) {
      if (!mounted) return;
      debugPrint('PHONE OTP UNEXPECTED: $e');
      _showError('SMS gönderilemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+90$digits';
    if (digits.length == 11 && digits.startsWith('0')) return '+9$digits';
    if (digits.length == 12 && digits.startsWith('90')) return '+$digits';
    if (digits.length == 13 && phone.startsWith('+')) return phone;
    if (phone.startsWith('+90') && digits.length == 12) return phone;
    return null;
  }

  String _mapSupabaseError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid') && m.contains('phone')) {
      return 'Geçerli bir telefon numarası girin.';
    }
    if (m.contains('sms') || m.contains('provider')) {
      return 'SMS gönderilemedi. SMS sağlayıcısı ayarlanmamış olabilir.';
    }
    if (m.contains('network') || m.contains('timeout')) {
      return 'Bağlantı hatası oluştu.';
    }
    if (m.contains('rate') || m.contains('limit')) {
      return 'Çok fazla deneme yaptınız. Biraz bekleyip tekrar deneyin.';
    }
    return 'SMS gönderilemedi. Lütfen tekrar deneyin.';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Hoş Geldiniz',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Telefon numaranızla devam edin.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (DevAuthService.isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Demo modu kodu: 123456',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Size SMS ile doğrulama kodu göndereceğiz.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  'Telefon Numarası',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendOtp(),
                  decoration: const InputDecoration(
                    hintText: '+90 5XX XXX XX XX',
                    prefixIcon: Icon(Icons.phone_android_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Telefon numaranızı başında +90 olacak şekilde girin.',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
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
                        : const Text('SMS Kodu Gönder'),
                  ),
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
