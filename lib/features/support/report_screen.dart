import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/features/support/data/report_repository.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String? jobPostId;
  final String? reportedUserId;
  const ReportScreen({super.key, this.jobPostId, this.reportedUserId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _reasonController = TextEditingController();
  String _reason = 'sahte_ilan';
  bool _isSending = false;
  bool _sent = false;

  static const _reasons = [
    'sahte_ilan',
    'yanlis_bilgi',
    'uygunsuz_davranis',
    'odeme_anlasmazligi',
    'Diğer',
  ];

  String _reasonLabel(String v) {
    const m = {
      'sahte_ilan': 'Sahte Ilan',
      'yanlis_bilgi': 'Yanlis Bilgi',
      'uygunsuz_davranis': 'Uygunsuz Davranis',
      'odeme_anlasmazligi': 'Odeme Anlasmazligi',
      'Diğer': 'Diğer',
    };
    return m[v] ?? v;
  }

  Future<void> _submit() async {
    setState(() => _isSending = true);
    try {
      await ReportRepository().createReport(
        reason: _reason,
        description: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        reportedUserId: widget.reportedUserId,
        jobPostId: widget.jobPostId,
      );
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _sent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sikayet gonderilemedi.'),
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
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sikayet Bildir'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sikayet Bildir',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Uygunsuz icerik veya kullanici bildirmek icin bu formu kullanin.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Text(
          'Sikayet Nedeni',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons
              .map(
                (r) => GestureDetector(
                  onTap: () => setState(() => _reason = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _reason == r
                          ? AppColors.accent.withAlpha(20)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _reason == r
                            ? AppColors.accent
                            : AppColors.border,
                        width: _reason == r ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      _reasonLabel(r),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _reason == r
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Aciklama (opsiyonel)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Detayli aciklama...'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isSending ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Sikayeti Gonder'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sikayetiniz Alindi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ekibimiz en kisa surede inceleyecek.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tamam'),
            ),
          ),
        ],
      ),
    );
  }
}
