import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../jobs/data/models/job_constants.dart';
import '../../data/models/user_profile.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _companyName;
  late final TextEditingController _taxNumber;
  late final TextEditingController _district;
  late final TextEditingController _iban;
  String? _city;
  bool _ibanInitialized = false;

  /// Yerel önizleme — yüklenmeden önce gösterilen byte verisi.
  Uint8List? _pendingAvatarBytes;
  String? _pendingAvatarExt;

  /// Yüklendikten sonra dönen public URL.
  String? _uploadedAvatarUrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fullName = TextEditingController(text: p.fullName);
    _companyName = TextEditingController(text: p.companyName ?? '');
    _taxNumber = TextEditingController(text: p.taxNumber ?? '');
    _district = TextEditingController(text: p.district);
    _iban = TextEditingController();
    _city = p.city;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _companyName.dispose();
    _taxNumber.dispose();
    _district.dispose();
    _iban.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();

    setState(() {
      _pendingAvatarBytes = bytes;
      _pendingAvatarExt = ext;
      _uploadedAvatarUrl = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şehir seç')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      var avatarUrl = widget.profile.avatarUrl;

      // 1. Avatar değiştirildiyse önce yükle
      if (_pendingAvatarBytes != null && _pendingAvatarExt != null) {
        final uploaded =
            await ref.read(uploadAvatarControllerProvider.notifier).upload(
                  bytes: _pendingAvatarBytes!,
                  fileExt: _pendingAvatarExt!,
                );
        if (uploaded == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar yüklenemedi')),
          );
          setState(() => _saving = false);
          return;
        }
        avatarUrl = uploaded;
        _uploadedAvatarUrl = uploaded;
      }

      // 2. Profili güncelle
      final updated = widget.profile.copyWith(
        fullName: _fullName.text.trim(),
        companyName: _companyName.text.trim().isEmpty
            ? null
            : _companyName.text.trim(),
        taxNumber:
            _taxNumber.text.trim().isEmpty ? null : _taxNumber.text.trim(),
        city: _city,
        district: _district.text.trim(),
        avatarUrl: avatarUrl,
      );

      final ok =
          await ref.read(editProfileControllerProvider.notifier).save(updated);

      if (!mounted) return;
      if (!ok) {
        final err = ref.read(editProfileControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${err ?? 'bilinmeyen'}')),
        );
        return;
      }

      // Nakliyeci ise IBAN güncelle
      if (!widget.profile.isShipper && _iban.text.trim().isNotEmpty) {
        final ibanOk = await ref
            .read(updateCarrierIbanControllerProvider.notifier)
            .update(widget.profile.id, _iban.text.trim());
        if (!mounted) return;
        if (!ibanOk) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('IBAN güncellenemedi')),
          );
          return;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi')),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    // Nakliyeci ise mevcut IBAN'ı bir kez yükle
    if (!p.isShipper && !_ibanInitialized) {
      final carrierAsync = ref.watch(carrierProfileByUserProvider(p.id));
      carrierAsync.whenData((carrier) {
        if (!_ibanInitialized && carrier?.iban != null) {
          _iban.text = carrier!.iban!;
          _ibanInitialized = true;
        } else if (!_ibanInitialized && carrier != null) {
          _ibanInitialized = true;
        }
      });
    }

    return AppScaffold(
      title: 'Profili Düzenle',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.ink100,
                      backgroundImage: _avatarImage(p),
                      child: _avatarImage(p) == null
                          ? Text(
                              _initials(p.fullName),
                              style: const TextStyle(
                                color: AppColors.ink900,
                                fontWeight: FontWeight.w700,
                                fontSize: 36,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.ink900,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Fotoğrafı değiştirmek için dokun',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.ink500,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // İsim
            AppTextField(
              controller: _fullName,
              label: 'Ad Soyad',
              validator: (v) =>
                  Validators.required(v, label: 'Ad soyad'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),

            // Şirket (opsiyonel — bireysel için boş)
            if (p.isCompany) ...[
              AppTextField(
                controller: _companyName,
                label: 'Firma adı',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _taxNumber,
                label: 'Vergi numarası',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return Validators.vergiNo(v);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Şehir
            _DropdownField(
              label: 'Şehir',
              value: _city,
              items: JobConstants.turkishCities,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // İlçe
            AppTextField(
              controller: _district,
              label: 'İlçe',
              validator: (v) => Validators.required(v, label: 'İlçe'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),

            // IBAN (sadece nakliyeci)
            if (!p.isShipper) ...[
              AppTextField(
                controller: _iban,
                label: 'IBAN (opsiyonel)',
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return Validators.iban(v.trim());
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Read-only: rol ve telefon
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: AppColors.ink50,
              borderColor: AppColors.ink100,
              child: Column(
                children: [
                  _ReadOnlyRow(
                    icon: Icons.badge_outlined,
                    label: 'Rol',
                    value: p.isShipper ? 'Yükveren' : 'Nakliyeci',
                  ),
                  const Divider(height: 16, color: AppColors.ink100),
                  _ReadOnlyRow(
                    icon: Icons.account_circle_outlined,
                    label: 'Tip',
                    value: p.isCompany ? 'Kurumsal' : 'Bireysel',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rol ve hesap tipi sonradan değiştirilemez.',
              style: TextStyle(fontSize: 12, color: AppColors.ink500),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            AppButton(
              label: _saving ? 'Kaydediliyor...' : 'Kaydet',
              onPressed: _saving ? null : _save,
              loading: _saving,
              icon: Icons.check,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  ImageProvider? _avatarImage(UserProfile p) {
    if (_pendingAvatarBytes != null) {
      return MemoryImage(_pendingAvatarBytes!);
    }
    if (_uploadedAvatarUrl != null) return NetworkImage(_uploadedAvatarUrl!);
    if (p.avatarUrl != null) return NetworkImage(p.avatarUrl!);
    return null;
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: const Text('Seç'),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.ink500),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppColors.ink500, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
