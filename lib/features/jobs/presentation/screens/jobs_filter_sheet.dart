import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/job_constants.dart';
import '../controllers/jobs_controller.dart';

Future<void> showJobsFilterSheet(BuildContext context) {
  return AppBottomSheet.show<void>(
    context: context,
    title: 'Hızlı filtreler',
    builder: (_) => const _JobsFilterContent(),
  );
}

class _JobsFilterContent extends ConsumerStatefulWidget {
  const _JobsFilterContent();

  @override
  ConsumerState<_JobsFilterContent> createState() => _JobsFilterContentState();
}

class _JobsFilterContentState extends ConsumerState<_JobsFilterContent> {
  String? _origin;
  String? _destination;
  String? _cargoType;
  String? _trailerType;

  @override
  void initState() {
    super.initState();
    final f = ref.read(jobFilterNotifierProvider);
    _origin = f.originCity;
    _destination = f.destinationCity;
    _cargoType = f.cargoType;
    _trailerType = f.trailerType;
  }

  void _apply() {
    final notifier = ref.read(jobFilterNotifierProvider.notifier);
    notifier
      ..setOriginCity(_origin)
      ..setDestinationCity(_destination)
      ..setCargoType(_cargoType)
      ..setTrailerType(_trailerType);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _origin = null;
      _destination = null;
      _cargoType = null;
      _trailerType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownField(
            label: 'Çıkış şehri',
            value: _origin,
            items: JobConstants.turkishCities,
            onChanged: (v) => setState(() => _origin = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Varış şehri',
            value: _destination,
            items: JobConstants.turkishCities,
            onChanged: (v) => setState(() => _destination = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Yük tipi',
            value: _cargoType,
            items: JobConstants.cargoTypes,
            onChanged: (v) => setState(() => _cargoType = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Araç tipi',
            value: _trailerType,
            items: JobConstants.trailerTypes,
            onChanged: (v) => setState(() => _trailerType = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Temizle',
                  variant: AppButtonVariant.secondary,
                  onPressed: _clear,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Uygula',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      decoration: InputDecoration(
        labelText: label,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: const Text('İl seç'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Tümü'),
            ),
            ...items.map(
              (i) => DropdownMenuItem<String?>(value: i, child: Text(i)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
