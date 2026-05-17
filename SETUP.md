# İlk Kurulum

Bu projeyi sıfırdan ayağa kaldırmak için adım adım rehber.

> Not: En güvenli yol tek komut bootstrap'tır:
> - Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1`
> - macOS/Linux: `bash scripts/bootstrap.sh`

## Ön Gereksinimler

- Flutter SDK 3.27.x (veya üzeri)
- Dart 3.5+
- Android Studio (Android için)
- Xcode (iOS için, sadece macOS)
- Supabase CLI (opsiyonel, lokal Supabase için)
- Bir Supabase projesi (https://supabase.com/dashboard)

## Adım 1 — Bağımlılıkları çek

```bash
flutter pub get
```

İlk çalıştırmada 1-2 paket version uyumsuzluğu uyarısı görebilirsin. Çoğu kez `flutter pub upgrade --major-versions` ile çözülür.

## Adım 2 — Flutter platform dosyalarını doğrula

Bu repoda `android/` ve `ios/` klasörleri normalde bulunur. Eksikse şu
komutla tekrar üret:

```bash
flutter create --platforms=android,ios .
```

Bu komut sadece platform klasörlerini oluşturur; Dart kodlarına dokunmaz.

NOT: Mevcut dosyaları korumak için `--overwrite` BAYRAĞI VERMEDEN çalıştır. Eğer overwrite gerekirse, yalnızca `--platforms` flag ile çalıştır.

## Adım 3 — .env dosyasını oluştur

```bash
cp .env.example .env
```

Sonra `.env`'i aç ve doldur:

- **Supabase**: Supabase Dashboard → Project Settings → API → URL ve `anon public` key
- **Google Maps**: Google Cloud Console → APIs & Services → Credentials. Android için ayrı, iOS için ayrı key oluştur. SHA-1 restriction'ları doğru ayarla.
- **DEMO_MODE**: İlk geliştirmede `true` yap, Supabase olmadan çalışsın. OTP kodu `123456`.

## Adım 4 — Supabase şemasını uygula

İki yol var:

### Yol A: Supabase Studio (önerilen)

1. Supabase Dashboard → SQL Editor
2. `supabase/migrations/001_initial_schema.sql` içeriğini kopyala, çalıştır
3. Aynı şekilde migration dosyalarını sıra numarasına göre (`001` ... `008`)
   çalıştır

### Yol B: Supabase CLI

```bash
supabase link --project-ref <your-project-ref>
supabase db push
```

## Adım 5 — l10n dosyalarını üret

```bash
flutter gen-l10n
```

Bu komut `lib/l10n/app_localizations.dart` dosyasını üretir. `lib/main.dart` ve diğer dosyalar bu dosyayı import ediyor.

## Adım 6 — Riverpod code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

Bu komut `@riverpod` annotation'larından `*.g.dart` dosyalarını üretir. Olmadan derleme başarısız olur.

## Adım 7 — Firebase config (opsiyonel, push testinden önce gerekli)

Push notification için gerekli. Şimdilik atlayabilirsin.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

`flutterfire configure` CLI ile otomatize edilebilir.

## Adım 8 — Çalıştır!

```bash
# Bağlı emülator/cihaz listesi
flutter devices

# Belirli cihazda çalıştır
flutter run -d <device-id>

# veya
flutter run
```

Beklenen akış (DEMO_MODE=true ise):
1. Splash görünür
2. Telefon giriş ekranı
3. Geçerli format bir numara gir (örn. 5320000001)
4. OTP ekranı → `123456` gir
5. Rol seçim ekranı
6. Profil setup
7. Home (bottom nav ile placeholder ekranlar)

## Sorun Çözüm

### "Target of URI doesn't exist: 'app_localizations.dart'"

Adım 5'i çalıştırmadın. `flutter gen-l10n` çalıştır.

### "Target of URI doesn't exist: '*.g.dart'"

Adım 6'yı çalıştırmadın. `dart run build_runner build --delete-conflicting-outputs`.

### "google_maps_flutter ... requires Android SDK ..."

`android/app/build.gradle` içinde `minSdkVersion 24` veya üzeri olmalı.

### iOS'ta build hatası

```bash
cd ios && pod install && cd ..
```

### Build runner sürekli çakışma

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Supabase auth çalışmıyor

- Supabase Dashboard → Authentication → Providers → Phone provider'ı aç
- SMS Provider olarak Twilio veya MessageBird ekle (test için bedava limit var)
- Veya geliştirme sırasında DEMO_MODE=true kullan
