import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/reviews_controller.dart';
import '../widgets/star_rating.dart';

Future<bool?> showCreateReviewSheet(
  BuildContext context, {
  required String jobPostId,
  required String revieweeId,
  required String revieweeName,
}) {
  return AppBottomSheet.show<bool>(
    context: context,
    title: 'Değerlendir',
    builder: (_) => _CreateReviewContent(
      jobPostId: jobPostId,
      revieweeId: revieweeId,
      revieweeName: revieweeName,
    ),
  );
}

class _CreateReviewContent extends ConsumerStatefulWidget {
  const _CreateReviewContent({
    required this.jobPostId,
    required this.revieweeId,
    required this.revieweeName,
  });

  final String jobPostId;
  final String revieweeId;
  final String revieweeName;

  @override
  ConsumerState<_CreateReviewContent> createState() =>
      _CreateReviewContentState();
}

class _CreateReviewContentState
    extends ConsumerState<_CreateReviewContent> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az 1 yıldız ver')),
      );
      return;
    }
    setState(() => _saving = true);
    final ok = await ref
        .read(createReviewControllerProvider.notifier)
        .submit(
          jobPostId: widget.jobPostId,
          revieweeId: widget.revieweeId,
          rating: _rating,
          comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Değerlendirmen kaydedildi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu')),
      );
    }
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
          Text(
            widget.revieweeName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Bu taşıma için deneyimini değerlendir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink600),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: StarRating(
              rating: _rating.toDouble(),
              size: 44,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _comment,
            label: 'Yorum (opsiyonel)',
            maxLines: 4,
            minLines: 2,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Gönder',
            onPressed: _saving ? null : _submit,
            loading: _saving,
          ),
        ],
      ),
    );
  }
}
