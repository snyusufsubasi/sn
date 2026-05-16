import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _capacityController = TextEditingController();
  final _plateController = TextEditingController();
  String? _role;
  String _userType = 'individual';
  String _vehicleType = 'kamyonet';
  Set<String> _serviceAreas = {};
  Set<String> _jobTypePrefs = {};
  bool _isLoading = false;
  bool _initialized = false;

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
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getCurrentProfile();
    if (!mounted) return;
    _role = profile?['role'] as String?;
    _nameController.text = profile?['full_name'] ?? '';
    _cityController.text = profile?['city'] ?? '';
    _districtController.text = profile?['district'] ?? '';

    final phone = await repo.getPrivatePhone();
    _phoneController.text = phone?['phone'] ?? '';

    if (_role == 'shipper') {
      final sp = await repo.getShipperProfile();
      if (sp != null) _userType = sp['user_type'] as String? ?? 'individual';
    } else if (_role == 'carrier') {
      final cp = await repo.getCarrierProfile();
      if (cp != null) {
        _vehicleType = cp['vehicle_type'] as String? ?? 'kamyonet';
        _capacityController.text = cp['capacity_text'] ?? '';
        _serviceAreas =
            (cp['service_areas'] as List?)?.map((e) => e.toString()).toSet() ??
            {};
        _jobTypePrefs =
            (cp['job_type_preferences'] as List?)
                ?.map((e) => e.toString())
                .toSet() ??
            {};
      }
      final plate = await repo.getCarrierPlate();
      _plateController.text = plate?['plate_number'] ?? '';
    }

    if (!mounted) return;
    setState(() => _initialized = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.upsertBaseProfile(
        fullName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
      );
      await repo.upsertPrivatePhone(_phoneController.text.trim());

      if (_role == 'shipper') {
        await repo.upsertShipperProfile(userType: _userType);
      } else if (_role == 'carrier') {
        await repo.upsertCarrierProfile(
          vehicleType: _vehicleType,
          capacityText: _capacityController.text.trim(),
          serviceAreas: _serviceAreas.toList(),
          jobTypePreferences: _jobTypePrefs.toList(),
        );
        await repo.upsertCarrierPrivateInfo(_plateController.text.trim());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil guncellendi.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil guncellenemedi.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _capacityController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profili Düzenle'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Kişisel Bilgiler'),
              const SizedBox(height: 12),
              _field(
                'Ad Soyad / Firma Adi',
                'Ahmet Yilmaz',
                _nameController,
                (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
              ),
              const SizedBox(height: 14),
              _field(
                'Telefon',
                '05XX XXX XX XX',
                _phoneController,
                (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
              ),
              const SizedBox(height: 14),
              _field(
                'Sehir',
                'Istanbul',
                _cityController,
                (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
              ),
              const SizedBox(height: 14),
              _field(
                'Ilce',
                'Kadikoy',
                _districtController,
                (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
              ),
              if (_role == 'shipper') ...[
                const SizedBox(height: 24),
                _section('Hesap Tipi'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _chip(
                        'Bireysel',
                        _userType == 'individual',
                        () => setState(() => _userType = 'individual'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _chip(
                        'Firma',
                        _userType == 'company',
                        () => setState(() => _userType = 'company'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_role == 'carrier') ...[
                const SizedBox(height: 24),
                _section('Araç Bilgileri'),
                const SizedBox(height: 12),
                _field(
                  'Plaka',
                  '34 ABC 123',
                  _plateController,
                  (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
                ),
                const SizedBox(height: 14),
                _field(
                  'Kapasite',
                  '3.5 ton',
                  _capacityController,
                  (v) => v == null || v.trim().isEmpty ? 'Zorunludur.' : null,
                ),
                const SizedBox(height: 16),
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
                        (t) => _chip(
                          _vtLabel(t),
                          _vehicleType == t,
                          () => setState(() => _vehicleType = t),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                _section('Calisma Turu'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _serviceAreaOptions
                      .map(
                        (o) => _chipToggle(
                          _saLabel(o),
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
                const SizedBox(height: 24),
                _section('Is Turu Tercihleri'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _jobTypeOptions
                      .map(
                        (o) => _chipToggle(
                          _jtLabel(o),
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
              ],
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
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
                      : const Text('Kaydet'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Text(
    t,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    ),
  );
  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl,
    String? Function(String?) validate,
  ) => Column(
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
        controller: ctrl,
        validator: validate,
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withAlpha(20)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.accent : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      );

  Widget _chipToggle(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withAlpha(20)
                : AppColors.surface,
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );

  String _vtLabel(String v) {
    const m = {
      'kamyonet': 'Kamyonet',
      'kamyon': 'Kamyon',
      'tir': 'Tir',
      'panelvan': 'Panelvan',
      'acik_kasa': 'Acik Kasa',
      'kapali_kasa': 'Kapali Kasa',
      'Diğer': 'Diğer',
    };
    return m[v] ?? v;
  }

  String _saLabel(String v) {
    const m = {'sehir_ici': 'Şehir İçi', 'sehirler_arasi': 'Şehirler Arası'};
    return m[v] ?? v;
  }

  String _jtLabel(String v) {
    const m = {
      'evden_eve': 'Evden Eve',
      'parca_esya': 'Parça Eşya',
      'komple_yuk': 'Komple Yük',
      'ticari_yuk': 'Ticari Yük',
      'Diğer': 'Diğer',
    };
    return m[v] ?? v;
  }
}
