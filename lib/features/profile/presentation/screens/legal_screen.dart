import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_scaffold.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.kind, super.key});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final data = _contentFor(kind);
    return AppScaffold(
      title: data.$1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            data.$2,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  (String, String) _contentFor(String kind) {
    switch (kind) {
      case 'terms':
        return (
          'Kullanım Koşulları',
          'Bu demo sürümünde ARACIYOK uygulaması yalnızca örnek '
              'senaryoları göstermek için hazırlanmıştır. '
              'Taşıma teklifleri ve operasyon adımları simüle edilir.',
        );
      case 'privacy':
        return (
          'Gizlilik / KVKK',
          'Demo modda veriler cihaz içinde tutulur ve harici servislere '
              'gönderilmez. Üretim modunda kişisel veriler, ilgili mevzuata '
              'uygun şekilde işlenecek biçimde güncellenecektir.',
        );
      case 'help':
        return (
          'Yardım & Destek',
          'Demo akışı için: ilan oluştur, teklif kabul et, taşıma akışından '
              'onay adımlarını tamamla. Sorun yaşarsan uygulamayı yeniden '
              'başlatıp DEMO_MODE=true ile tekrar dene.',
        );
      default:
        return ('Bilgi', 'İçerik bulunamadı.');
    }
  }
}
