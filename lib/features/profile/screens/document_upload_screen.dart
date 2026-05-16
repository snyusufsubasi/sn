import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasima_app/core/theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final Map<String, String?> _documents = {
    'ehliyet': null,
    'k_belgesi': null,
    'ruhsat': null,
  };

  Future<void> _pickDocument(String docKey) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        _documents[docKey] = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Onay Belgeleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesabınızı onaylatmak ve güvenilir nakliyeci rozeti almak için aşağıdaki belgeleri yükleyin.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildDocUploader('Sürücü Belgesi (Ehliyet)', 'ehliyet'),
            const SizedBox(height: 16),
            _buildDocUploader('K Belgesi (Taşıma Yetki)', 'k_belgesi'),
            const SizedBox(height: 16),
            _buildDocUploader('Araç Ruhsatı', 'ruhsat'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belgeler başarıyla gönderildi. Onay bekleniyor.')),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Belgeleri Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocUploader(String title, String docKey) {
    final path = _documents[docKey];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (path != null)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (path != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _pickDocument(docKey),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Fotoğraf Çek / Yükle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }
}
