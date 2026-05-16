import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';

class ShipperProfileSetupScreen extends ConsumerStatefulWidget {
  const ShipperProfileSetupScreen({super.key});

  @override
  ConsumerState<ShipperProfileSetupScreen> createState() =>
      _ShipperProfileSetupScreenState();
}

class _ShipperProfileSetupScreenState
    extends ConsumerState<ShipperProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  String _userType = 'individual';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final phone = SupabaseClientManager.instance.client.auth.currentUser?.phone;
    if (phone != null) _phoneController.text = phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      final name = _nameController.text.trim();
      final city = _cityController.text.trim();
      final district = _districtController.text.trim();
      final phone = _phoneController.text.trim();

      await repo.upsertBaseProfile(
        fullName: name,
        city: city,
        district: district,
      );
      await repo.upsertPrivatePhone(phone);
      await repo.upsertShipperProfile(
        companyName: _userType == 'company' ? name : null,
        userType: _userType,
      );

      if (!mounted) return;
      context.go(AppRoutes.shipperHome);
    } catch (e) {
      if (!mounted) return;
      _showError('Profil kaydedilemedi. Lutfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilinizi Tamamlayin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _sectionTitle('Kişisel Bilgiler'),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Ad Soyad / Firma Adi',
                  hint: 'Ahmet Yilmaz',
                  controller: _nameController,
                  validator: (v) => _required(v, 'Ad Soyad'),
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Telefon',
                  hint: '05XX XXX XX XX',
                  controller: _phoneController,
                  validator: (v) => _required(v, 'Telefon'),
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Sehir',
                  hint: 'Istanbul',
                  controller: _cityController,
                  validator: (v) => _required(v, 'Sehir'),
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Ilce',
                  hint: 'Kadikoy',
                  controller: _districtController,
                  validator: (v) => _required(v, 'Ilce'),
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 28),
                _sectionTitle('Kullanici Tipi'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeChip(
                        value: 'individual',
                        label: 'Bireysel',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeChip(
                        value: 'company',
                        label: 'Firma',
                        icon: Icons.business_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                        : const Text('Profili Tamamla'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _userType == value;
    return GestureDetector(
      onTap: () => setState(() => _userType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(20)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.accent : AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field zorunludur.';
    return null;
  }
}
