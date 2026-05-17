# ARACIYOK Release Checklist

## 1) Kod ve kalite
- `flutter pub get`
- `flutter gen-l10n`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test --coverage`
- `flutter build apk --release`
- `flutter build web --release`
- `flutter build web --release --target=lib/main_admin.dart`

## 2) Backend ve migration
- Yeni migration'lar staging ortamında sıra numarasına göre uygulandı.
- `supabase db push` temiz tamamlandı.
- `008_device_tokens.sql` sonrası token yazma/okuma smoke testi geçti.
- `release_payment` yetki kontrolü shipper/carrier/admin senaryolarında doğrulandı.

## 3) Edge Function ve secret'lar
- `send-push` deploy edildi.
- `FCM_SERVICE_ACCOUNT_JSON` secret set edildi.
- `SEND_PUSH_WEBHOOK_SECRET` secret set edildi.
- Database webhook header'ında `x-webhook-secret` tanımlandı.

## 4) Mobil yayın öncesi
- Android signing key doğrulandı.
- iOS signing/provisioning doğrulandı.
- KVKK / gizlilik / kullanım koşulları linkleri canlı içeriklere yönlendi.
- Crash ve performans izleme açık.

## 5) Go/No-Go
- Kritik akışlar: teklif → taşıma → teslim → değerlendirme uçtan uca test edildi.
- Ödeme akışı en az bir staging senaryosunda geçti.
- Admin panelinden açık dispute ve kullanıcı metrikleri görüldü.
- Rollback planı hazır ve sorumlu kişiler onay verdi.
