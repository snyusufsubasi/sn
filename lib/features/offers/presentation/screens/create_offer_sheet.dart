import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/mini_route_widget.dart';
import '../../../jobs/data/models/job_post.dart';
import '../controllers/offers_controller.dart';

Future<void> showCreateOfferSheet(
  BuildContext context, {
  required JobPost job,
}) {
  return AppBottomSheet.show<void>(
    context: context,
    title: '💰 Teklif Ver',
    builder: (_) => _CreateOfferContent(job: job),
  );
}

class _CreateOfferContent extends ConsumerStatefulWidget {
  const _CreateOfferContent({required this.job});
  final JobPost job;

  @override
  ConsumerState<_CreateOfferContent> createState() =>
      _CreateOfferContentState();
}

class _CreateOfferContentState extends ConsumerState<_CreateOfferContent> {
  final _formKey = GlobalKey<FormState>();
  final _price = TextEditingController();
  final _message = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _price.dispose();
    _message.dispose();
    super.dispose();
  }

  String? _validatePrice(String? v) {
    if (v == null || v.isEmpty) return 'Fiyat gerekli';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null || n <= 0) return 'Geçerli bir fiyat girin';
    if (n > 9999999) return 'Çok yüksek';
    return null;
  }

  String? _suggestedRange() {
    final j = widget.job;
    if (j.budgetMin != null && j.budgetMax != null) {
      return 'Bütçe aralığı: ${Formatters.currency(j.budgetMin!)}'
          ' – ${Formatters.currency(j.budgetMax!)}';
    }
    if (j.budgetMax != null) {
      return 'Maksimum bütçe: ${Formatters.currency(j.budgetMax!)}';
    }
    if (j.budgetMin != null) {
      return 'Minimum bütçe: ${Formatters.currency(j.budgetMin!)}';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.parse(_price.text.replaceAll(',', '.'));

    setState(() => _saving = true);
    try {
      final offer =
          await ref.read(createOfferControllerProvider.notifier).submit(
                jobPostId: widget.job.id,
                price: price,
                message: _message.text.trim().isEmpty
                    ? null
                    : _message.text.trim(),
              );
      if (!mounted) return;
      if (offer != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teklifin gönderildi')),
        );
      } else {
        final err = ref.read(createOfferControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${err ?? 'bilinmeyen'}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final theme = Theme.of(context);
    final range = _suggestedRange();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Minimal job özeti — rota + kargo
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiniRouteWidget(
                    originCity: j.originCity,
                    destinationCity: j.destinationCity,
                    compact: true,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${j.cargoType} · ${Formatters.weight(j.weightTons)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(AppPalette.ink500),
                    ),
                  ),
                ],
              ),
            ),

            // Büyük fiyat input'u
            AppTextField(
              controller: _price,
              label: 'Fiyatın (₺)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,\\.]')),
              ],
              validator: _validatePrice,
              autofocus: true,
            ),

            // Önerilen fiyat aralığı
            if (range != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '💡 $range',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(AppPalette.ink500),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Mesaj — opsiyonel, küçük
            AppTextField(
              controller: _message,
              label: 'Mesaj (opsiyonel)',
              hint: 'Kısa bir not bırakabilirsin...',
              maxLines: 2,
              minLines: 1,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Teklif Ver butonu
            AppButton(
              label: 'Teklif Ver',
              variant: AppButtonVariant.accent,
              onPressed: _saving ? null : _submit,
              loading: _saving,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}
