import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart' hide AppRadius;
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/job_constants.dart';
import '../../data/models/job_post.dart';
import '../controllers/jobs_controller.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Genel
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _cargoType = JobConstants.cargoTypes.first;
  final _weight = TextEditingController();
  final _volume = TextEditingController();

  // Origin
  String? _originCity;
  final _originDistrict = TextEditingController();
  final _originAddress = TextEditingController();

  // Destination
  String? _destinationCity;
  final _destinationDistrict = TextEditingController();
  final _destinationAddress = TextEditingController();

  // Tarihler ve fiyat
  DateTime? _pickupDate;
  DateTime? _deliveryDate;
  String? _trailerType;
  final _budgetMin = TextEditingController();
  final _budgetMax = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _weight.dispose();
    _volume.dispose();
    _originDistrict.dispose();
    _originAddress.dispose();
    _destinationDistrict.dispose();
    _destinationAddress.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isPickup) async {
    final base = isPickup ? _pickupDate : _deliveryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: base ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr'),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
        } else {
          _deliveryDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yükleme tarihi seç')),
      );
      return;
    }
    if (_originCity == null || _destinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şehirleri seç')),
      );
      return;
    }
    final budgetMin = double.tryParse(_budgetMin.text.replaceAll(',', '.'));
    final budgetMax = double.tryParse(_budgetMax.text.replaceAll(',', '.'));
    if (budgetMin != null && budgetMax != null && budgetMax < budgetMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maks bütçe min bütçeden büyük olmalı')),
      );
      return;
    }

    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;

    final originGeo = await _geocodeAddress(
      city: _originCity!,
      district: _originDistrict.text.trim(),
      address: _originAddress.text.trim(),
    );
    final destinationGeo = await _geocodeAddress(
      city: _destinationCity!,
      district: _destinationDistrict.text.trim(),
      address: _destinationAddress.text.trim(),
    );

    final input = JobPostInput(
      title: _title.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      cargoType: _cargoType,
      weightTons: double.parse(_weight.text.replaceAll(',', '.')),
      volumeM3: _volume.text.trim().isEmpty
          ? null
          : double.parse(_volume.text.replaceAll(',', '.')),
      originCity: _originCity!,
      originDistrict: _originDistrict.text.trim(),
      destinationCity: _destinationCity!,
      destinationDistrict: _destinationDistrict.text.trim(),
      originAddress: _originAddress.text.trim().isEmpty
          ? null
          : _originAddress.text.trim(),
      destinationAddress: _destinationAddress.text.trim().isEmpty
          ? null
          : _destinationAddress.text.trim(),
      originLat: originGeo?.$1,
      originLng: originGeo?.$2,
      destinationLat: destinationGeo?.$1,
      destinationLng: destinationGeo?.$2,
      pickupDate: _pickupDate!,
      deliveryDate: _deliveryDate,
      preferredTrailerType: _trailerType,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
    );

    setState(() => _saving = true);
    try {
      final job = await ref
          .read(createJobControllerProvider.notifier)
          .submit(input, profile.id);
      if (!mounted) return;
      if (job != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan yayına alındı')),
        );
        context.go('/jobs/${job.id}');
      } else {
        final err = ref.read(createJobControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${err ?? 'bilinmeyen'}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<(double, double)?> _geocodeAddress({
    required String city,
    required String district,
    required String address,
  }) async {
    if (kIsWeb) return null;
    final query = [address, district, city, 'Türkiye']
        .where((e) => e.trim().isNotEmpty)
        .join(', ');
    if (query.trim().isEmpty) return null;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;
      final loc = locations.first;
      return (loc.latitude, loc.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yeni İlan',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(text: 'Başlık'),
            AppTextField(
              controller: _title,
              hint: 'Örn. İstanbul – Konya tekstil yükü',
              validator: (v) =>
                  Validators.required(v, label: 'Başlık'),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionLabel(text: 'Açıklama (opsiyonel)'),
            AppTextField(
              controller: _description,
              hint: 'Yük hakkında ek detaylar',
              maxLines: 3,
              minLines: 2,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionLabel(text: 'Kargo'),
            _DropdownField<String>(
              label: 'Kargo tipi',
              value: _cargoType,
              items: JobConstants.cargoTypes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _cargoType = v!),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _weight,
                    label: 'Ağırlık (ton)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ağırlık gerekli';
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Geçerli bir değer';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _volume,
                    label: 'Hacim (m³)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DropdownField<String?>(
              label: 'Tercih edilen kasa (opsiyonel)',
              value: _trailerType,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Fark etmez'),
                ),
                ...JobConstants.trailerTypes.map(
                  (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                ),
              ],
              onChanged: (v) => setState(() => _trailerType = v),
            ),

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(text: 'Çıkış'),
            _DropdownField<String>(
              label: 'Şehir',
              value: _originCity,
              items: JobConstants.turkishCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _originCity = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _originDistrict,
              label: 'İlçe',
              validator: (v) => Validators.required(v, label: 'İlçe'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _originAddress,
              label: 'Açık adres (opsiyonel, teklif kabul edilince görünür)',
              maxLines: 2,
              minLines: 1,
            ),

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(text: 'Varış'),
            _DropdownField<String>(
              label: 'Şehir',
              value: _destinationCity,
              items: JobConstants.turkishCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _destinationCity = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _destinationDistrict,
              label: 'İlçe',
              validator: (v) => Validators.required(v, label: 'İlçe'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _destinationAddress,
              label: 'Açık adres (opsiyonel)',
              maxLines: 2,
              minLines: 1,
            ),

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(text: 'Tarihler ve bütçe'),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Yükleme',
                    date: _pickupDate,
                    onTap: () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'Teslim',
                    date: _deliveryDate,
                    onTap: () => _pickDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _budgetMin,
                    label: 'Min bütçe ₺',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _budgetMax,
                    label: 'Maks bütçe ₺',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: _saving ? 'Gönderiliyor...' : 'Yayına Al',
              onPressed: _saving ? null : _submit,
              loading: _saving,
              icon: Icons.publish,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(AppPalette.ink900),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          hint: const Text('Seç'),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color(AppPalette.ink50),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, size: 18, color: Color(AppPalette.ink600)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(AppPalette.ink500)),
                  ),
                  Text(
                    date == null ? 'Seç' : Formatters.date(date!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
