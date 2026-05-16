import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';

class CarrierProfileSetupScreen extends ConsumerStatefulWidget {
  const CarrierProfileSetupScreen({super.key});

  @override
  ConsumerState<CarrierProfileSetupScreen> createState() =>
      _CarrierProfileSetupScreenState();
}

class _CarrierProfileSetupScreenState
    extends ConsumerState<CarrierProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();

  String _vehicleType = 'kamyonet';
  final _serviceAreas = <String>{};
  final _jobTypePrefs = <String>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final phone = SupabaseClientManager.instance.client.auth.currentUser?.phone;
    if (phone != null) _phoneController.text = phone;
  }

  static const _vehicleTypes = [
    'kamyonet',
    'kamyon',
    'tir',
    'panelvan',
    'acik_kasa',
    'kapali_kasa',
    'Diğer',
  ];
  static const _serviceAreaOptions = ['sehir_ici', 'sehirler_arasi'];
  static const _jobTypeOptions = [
    'evden_eve',
    'parca_esya',
    'komple_yuk',
    'ticari_yuk',
    'Diğer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_serviceAreas.isEmpty) {
      _showError('En az bir calisma turu secin.');
      return;
    }
    if (_jobTypePrefs.isEmpty) {
      _showError('En az bir is turu secin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      final name = _nameController.text.trim();
      final city = _cityController.text.trim();
      final district = _districtController.text.trim();
      final phone = _phoneController.text.trim();
      final plate = _plateController.text.trim();
      final capacity = _capacityController.text.trim();

      await repo.upsertBaseProfile(
        fullName: name,
        city: city,
        district: district,
      );
      await repo.upsertPrivatePhone(phone);
      await repo.upsertCarrierProfile(
        companyName: name,
        vehicleType: _vehicleTypeDisplay,
        capacityText: capacity,
        serviceAreas: _serviceAreas.toList(),
        jobTypePreferences: _jobTypePrefs.toList(),
      );
      await repo.upsertCarrierPrivateInfo(plate);

      if (!mounted) return;
      context.go(AppRoutes.carrierHome);
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

  String get _vehicleTypeDisplay {
    const map = {
      'kamyonet': 'Kamyonet',
      'kamyon': 'Kamyon',
      'tir': 'Tir',
      'panelvan': 'Panelvan',
      'acik_kasa': 'Acik Kasa',
      'kapali_kasa': 'Kapali Kasa',
      'Diğer': 'Diğer',
    };
    return map[_vehicleType] ?? _vehicleType;
  }

  String? _required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field zorunludur.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arac Bilgileriniz'),
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
                _sectionTitle('Araç Bilgileri'),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Plaka',
                  hint: '34 ABC 123',
                  controller: _plateController,
                  validator: (v) => _required(v, 'Plaka'),
                  icon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'Tasima Kapasitesi',
                  hint: '3.5 ton',
                  controller: _capacityController,
                  validator: (v) => _required(v, 'Kapasite'),
                  icon: Icons.balance_outlined,
                ),
                const SizedBox(height: 20),
                Text(
                  'Araç Tipi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _vehicleTypes
                      .map(
                        (t) => _buildChip(
                          t,
                          _vehicleType == t,
                          () => setState(() => _vehicleType = t),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),
                _sectionTitle('Calisma Turu'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _serviceAreaOptions
                      .map(
                        (o) => _buildChip(
                          o,
                          _serviceAreas.contains(o),
                          () => setState(
                            () => _serviceAreas.contains(o)
                                ? _serviceAreas.remove(o)
                                : _serviceAreas.add(o),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),
                _sectionTitle('Is Turu Tercihleri'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _jobTypeOptions
                      .map(
                        (o) => _buildChip(
                          o,
                          _jobTypePrefs.contains(o),
                          () => setState(
                            () => _jobTypePrefs.contains(o)
                                ? _jobTypePrefs.remove(o)
                                : _jobTypePrefs.add(o),
                          ),
                        ),
                      )
                      .toList(),
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

  Widget _buildChip(String value, bool selected, VoidCallback onTap) {
    final labelMap = {
      'kamyonet': 'Kamyonet',
      'kamyon': 'Kamyon',
      'tir': 'Tir',
      'panelvan': 'Panelvan',
      'acik_kasa': 'Acik Kasa',
      'kapali_kasa': 'Kapali Kasa',
      'Diğer': 'Diğer',
      'sehir_ici': 'Şehir İçi',
      'sehirler_arasi': 'Şehirler Arası',
      'evden_eve': 'Evden Eve',
      'parca_esya': 'Parça Eşya',
      'komple_yuk': 'Komple Yük',
      'ticari_yuk': 'Ticari Yük',
    };
    final label = labelMap[value] ?? value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
