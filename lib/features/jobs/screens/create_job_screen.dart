import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:tasima_app/features/jobs/data/job_state.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final _descriptionController = TextEditingController();
  final _pickupCityController = TextEditingController();
  final _pickupDistrictController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _deliveryCityController = TextEditingController();
  final _deliveryDistrictController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeWindowController = TextEditingController();
  final _notesController = TextEditingController();

  CargoType _cargoType = CargoType.ev_esyasi;
  VehicleType _vehicleType = VehicleType.diger;
  bool _isDateFlexible = false;
  UrgencyLevel _urgency = UrgencyLevel.normal;
  List<String> _photoPaths = [];
  bool _isSubmitting = false;

  static const _cargoTypes = CargoType.values;
  static const _vehicleTypes = VehicleType.values;
  static const _urgencyLevels = UrgencyLevel.values;

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _pickupCityController.dispose();
    _pickupDistrictController.dispose();
    _pickupAddressController.dispose();
    _deliveryCityController.dispose();
    _deliveryDistrictController.dispose();
    _deliveryAddressController.dispose();
    _dateController.dispose();
    _timeWindowController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(jobRepositoryProvider);

      final jobId = await repo.createJobWithDetails(
        cargoType: _cargoType,
        vehicleType: _vehicleType,
        cargoDescription: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        pickupCity: _pickupCityController.text.trim(),
        pickupDistrict: _pickupDistrictController.text.trim(),
        deliveryCity: _deliveryCityController.text.trim(),
        deliveryDistrict: _deliveryDistrictController.text.trim(),
        pickupDate: _dateController.text.trim(),
        pickupTimeWindow: _timeWindowController.text.trim().isEmpty
            ? null
            : _timeWindowController.text.trim(),
        isDateFlexible: _isDateFlexible,
        urgencyLevel: _urgency.name,
        extraNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        pickupAddress: _pickupAddressController.text.trim().isEmpty
            ? null
            : _pickupAddressController.text.trim(),
        deliveryAddress: _deliveryAddressController.text.trim().isEmpty
            ? null
            : _deliveryAddressController.text.trim(),
        photoPaths: _photoPaths.isNotEmpty ? _photoPaths : null,
      );

      if (!mounted) return;
      context.go('${AppRoutes.jobCreatedSuccess}?jobId=$jobId');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ilan yayinlanamadi: ${e.toString().length > 100 ? 'Lutfen tekrar deneyin.' : e.toString()}',
          ),
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

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      setState(() => _photoPaths = files.map((f) => f.path).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Ilan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentStep = p),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.surface,
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i <= _currentStep;
          final isCurrent = i == _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: i > 0
                          ? Container(
                              height: 2,
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.border,
                            )
                          : const SizedBox(),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isCurrent || i < _currentStep
                                ? Colors.white
                                : AppColors.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: i < 3
                          ? Container(
                              height: 2,
                              color: i < _currentStep
                                  ? AppColors.accent
                                  : AppColors.border,
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ['Yuk', 'Rota', 'Tarih', 'Ozet'][i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.accent : AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      color: AppColors.surface,
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Geri'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: _currentStep < 3
                  ? ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Devam'),
                    )
                  : ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ilani Yayinla'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yuk Bilgileri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yuk Turu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cargoTypes
                  .map(
                    (t) => _chip(
                      t.name,
                      t.label,
                      _cargoType == t,
                      () => setState(() => _cargoType = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'İhtiyaç Duyulan Araç Tipi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vehicleTypes
                  .map(
                    (v) => _chip(
                      v.name,
                      v.label,
                      _vehicleType == v,
                      () => setState(() => _vehicleType = v),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Aciklama (opsiyonel)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Yukunuz hakkinda kisa bilgi verin...',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fotograf (opsiyonel)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickPhotos,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _photoPaths.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fotograf Ekle',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_photoPaths.first),
                              fit: BoxFit.cover,
                            ),
                            if (_photoPaths.length > 1)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${_photoPaths.length - 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nereden / Nereye',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _section('Yükleme'),
            const SizedBox(height: 12),
            _input(
              'Yukleme Ili',
              'Istanbul',
              _pickupCityController,
              (v) => _required(v, 'Yukleme ili'),
            ),
            const SizedBox(height: 12),
            _input(
              'Yukleme Ilcesi',
              'Kadikoy',
              _pickupDistrictController,
              (v) => _required(v, 'Yukleme ilcesi'),
            ),
            const SizedBox(height: 12),
            _input(
              'Acik Adres (opsiyonel)',
              'Mahalle, sokak, no...',
              _pickupAddressController,
              null,
            ),
            const SizedBox(height: 24),
            _section('Teslim'),
            const SizedBox(height: 12),
            _input(
              'Teslim Ili',
              'Ankara',
              _deliveryCityController,
              (v) => _required(v, 'Teslim ili'),
            ),
            const SizedBox(height: 12),
            _input(
              'Teslim Ilcesi',
              'Cankaya',
              _deliveryDistrictController,
              (v) => _required(v, 'Teslim ilcesi'),
            ),
            const SizedBox(height: 12),
            _input(
              'Acik Adres (opsiyonel)',
              'Mahalle, sokak, no...',
              _deliveryAddressController,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarih ve Detaylar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yukleme Tarihi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              validator: (v) => _required(v, 'Yukleme tarihi'),
              decoration: const InputDecoration(
                hintText: 'GG.AA.YYYY',
                suffixIcon: Icon(Icons.calendar_today, size: 20),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('tr'),
                );
                if (date != null) {
                  _dateController.text =
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Saat Araligi (opsiyonel)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _timeWindowController,
              decoration: const InputDecoration(hintText: '09:00 - 17:00'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Tarih Esnek',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Tarihte kucuk degisiklikler kabul edilebilir.',
                style: TextStyle(fontSize: 13),
              ),
              value: _isDateFlexible,
              activeTrackColor: AppColors.accent,
              onChanged: (v) => setState(() => _isDateFlexible = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Aciliyet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _urgencyLevels
                  .map(
                    (u) => _chip(
                      u.name,
                      u.name == 'normal' ? 'Normal' : (u.name == 'urgent' ? 'Acil' : 'Çok Acil'),
                      _urgency == u,
                      () => setState(() => _urgency = u),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Ek Notlar (opsiyonel)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tasimayla ilgili ek bilgiler...',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Telefon, acik adres veya kisisel bilgi yazmayin. Bu bilgiler yalnizca teklif kabul edildikten sonra paylasilir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning.withAlpha(200),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ozet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _summaryCard(
            'Yuk Turu',
            _cargoType.label,
            Icons.inventory_2_outlined,
          ),
          _summaryCard(
            'Arac Tipi',
            _vehicleType.label,
            Icons.local_shipping_outlined,
          ),
          if (_descriptionController.text.trim().isNotEmpty)
            _summaryCard(
              'Aciklama',
              _descriptionController.text.trim(),
              Icons.description_outlined,
            ),
          _summaryCard(
            'Yükleme',
            '${_pickupCityController.text.trim()} / ${_pickupDistrictController.text.trim()}',
            Icons.location_on_outlined,
          ),
          _summaryCard(
            'Teslim',
            '${_deliveryCityController.text.trim()} / ${_deliveryDistrictController.text.trim()}',
            Icons.flag_outlined,
          ),
          if (_pickupAddressController.text.trim().isNotEmpty)
            _summaryCard(
              'Yukleme Adresi',
              _pickupAddressController.text.trim(),
              Icons.home_outlined,
            ),
          if (_deliveryAddressController.text.trim().isNotEmpty)
            _summaryCard(
              'Teslim Adresi',
              _deliveryAddressController.text.trim(),
              Icons.home_work_outlined,
            ),
          _summaryCard(
            'Tarih',
            _dateController.text.trim(),
            Icons.calendar_today_outlined,
          ),
          if (_timeWindowController.text.trim().isNotEmpty)
            _summaryCard(
              'Saat',
              _timeWindowController.text.trim(),
              Icons.access_time_outlined,
            ),
          _summaryCard(
            'Esneklik',
            _isDateFlexible ? 'Tarih esnek' : 'Tarih kesin',
            Icons.autorenew_outlined,
          ),
          _summaryCard(
            'Aciliyet',
            _urgency.name == 'normal' ? 'Normal' : (_urgency.name == 'urgent' ? 'Acil' : 'Çok Acil'),
            Icons.priority_high_outlined,
          ),
          if (_notesController.text.trim().isNotEmpty)
            _summaryCard(
              'Notlar',
              _notesController.text.trim(),
              Icons.note_outlined,
            ),
          _summaryCard(
            'Fotograf',
            _photoPaths.isEmpty ? 'Eklenmedi' : '${_photoPaths.length} adet',
            Icons.photo_camera_outlined,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
      ),
    );
  }

  Widget _input(
    String label,
    String hint,
    TextEditingController ctrl,
    String? Function(String?)? validator,
  ) {
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
          controller: ctrl,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _chip(String value, String label, bool selected, VoidCallback onTap) {
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
  }

  String? _required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field zorunludur.';
    return null;
  }
}
