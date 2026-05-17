# ARACIYOK

Yükveren ile kamyon/tır nakliyecisini aracısız buluşturan Türkiye odaklı yük pazarı. **Flutter mobil** (Android + iOS) + Supabase, Uber-benzeri tasarım.

## Uygulamayı hemen aç (Windows)

| Ne yapmak istiyorsun? | Ne yap |
|------------------------|--------|
| **İlk kez / hata alıyorsan** | `HAZIRLA.bat` çift tıkla |
| **Her gün uygulamayı aç** | `AC.bat` çift tıkla → Chrome → http://127.0.0.1:8080 |
| **Gerçek telefon/emülatör** | `scripts\open_mobile.bat` |
| **Tam rehber** | [`docs/ERISIM.md`](docs/ERISIM.md) |

**Demo giriş:** `555 111 11 11` veya `555 222 22 22` · OTP: `123456` · `.env` içinde `DEMO_MODE=true`

## Hızlı Başlangıç (terminal)

```powershell
cd C:\Users\snyus\Desktop\claude\araciyok
powershell -File scripts\setup.ps1    # kurulum
.\AC.bat                              # veya: flutter run -d chrome --web-port=8080
```

## Deterministik Çalıştırma (Önerilen)

Her ortamda aynı çıktıyı almak için toolchain ve lockfile pinlidir.

- Flutter: `3.27.x` (bkz. `.fvmrc`, `.tool-versions`)
- Dependency çözümü: `pubspec.lock` üzerinden (`--enforce-lockfile`)
- Satır sonları: `.gitattributes` ile sabitlenmiş

Tek komutla kurulum ve doğrulama:

```bash
# macOS/Linux
bash scripts/bootstrap.sh
```

```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
```

Pinned Flutter yüklü değilse script bilinçli olarak fail eder.
Geçici lokal deneme için (önerilmez):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -SkipVersionCheck
```

Bu scriptler sırasıyla:
1) Flutter sürümünü doğrular
2) `.env` dosyasını yoksa üretir
3) `flutter pub get --enforce-lockfile`
4) `flutter gen-l10n`
5) `build_runner` codegen
6) `flutter analyze --no-fatal-infos`
7) `flutter test`

İlk derlemeden önce: Android için `android/app/google-services.json`, iOS için `ios/Runner/GoogleService-Info.plist` Firebase Console'dan indirilip yerleştirilmeli. Yoksa push notification adımları çalışmaz, ama uygulama derlenir.

## Klasör Yapısı

```
lib/
├── core/              # tüm feature'ların ortak kullandığı altyapı
│   ├── config/        # AppConfig, env okuma
│   ├── errors/        # AppFailure, Result tipleri
│   ├── network/       # SupabaseClient sarmalayıcı, Dio interceptors
│   ├── routing/       # go_router config, route guards
│   ├── theme/         # Uber tasarım sistemi (tokens + theme)
│   ├── utils/         # logger, formatters, validators
│   ├── extensions/    # BuildContext, String, DateTime extensions
│   └── widgets/       # her yerde kullanılan atomic widgets
│
├── features/          # her feature kendi kendine yeter
│   ├── auth/
│   │   ├── data/      # datasources, models, repositories
│   │   └── presentation/  # controllers (Riverpod), screens, widgets
│   ├── profile/
│   ├── jobs/
│   ├── offers/
│   ├── messages/
│   ├── notifications/
│   ├── reviews/
│   ├── payments/
│   ├── tracking/
│   ├── admin/
│   └── shell/         # bottom nav shell
│
├── shared/widgets/    # birden fazla feature'da kullanılan kompozit widget
├── l10n/              # i18n .arb dosyaları
└── main.dart
```

## Mimari

**Feature-first + hafif clean ayrımı.** Her feature kendi `data/` ve `presentation/` katmanına sahip. Saf clean architecture'ın bürokrasisi yok (use case katmanı yok — Riverpod notifier'lar o işi görür). Cross-feature ortak kod `lib/core/` ve `lib/shared/` altında.

Veri akışı tek yönlü:

```
UI (Screen)
  ↓ ref.watch / ref.read
Controller (Riverpod Notifier)
  ↓ Repository interface
Repository (Impl)
  ↓
Datasource (Supabase / Local cache)
```

## Renk Sistemi Kuralı

- Önizleme için light sabit (`ThemeMode.light`); production'da system'e alınabilir.
- Renk tokenları yalnızca `lib/core/theme/app_colors.dart` dosyasında tanımlanır.
- Theme eşlemeleri yalnızca `lib/core/theme/app_theme.dart` içinde yapılır.
- UI/feature dosyalarında hard-coded renk (`Color(0x...)`, `Colors.*`) kullanılmaz.

## State Management

Riverpod 2.x + `riverpod_generator` (annotation tabanlı). `@riverpod` ile yazılır, codegen `.g.dart` üretir.

## Test

```bash
flutter test                 # unit + widget
flutter test integration_test  # integration (cihazda)
flutter test --coverage      # coverage raporu
```

## Codex İçin

Codex'le çalışırken **`AGENTS.md`** dosyasını oku. Kalıcı mimari kurallar, hangi katman ne yapar, neye dokunma, hangi paketleri kullan — hepsi orada.

Sonraki fazlar için kullanıma hazır prompt'lar **`docs/PHASE_PROMPTS.md`** dosyasında.

## Mevcut Durum

Bu dosya hızlı başlangıç içindir. Faz bazlı resmi durum takibi için
`docs/ROADMAP.md` tek kaynak kabul edilir.

**Faz 0-8 tamamlandı.** Bu, uygulamanın **uçtan uca demo edilebilir** olduğu anlamına geliyor:

- ✅ **Faz 0-3:** proje iskeleti, tasarım sistemi, telefon auth, profil setup, Supabase migrations
- ✅ **Faz 4:** İlan CRUD — yükveren ilan açar, listeler, detay görür, iptal eder. Nakliyeci açık ilanları listeler, filtreler.
- ✅ **Faz 5:** Teklif & operasyon akışı — nakliyeci teklif verir, yükveren kabul/red eder, çift taraflı pickup onayı → yola çıkış → çift taraflı teslim onayı → tamamlandı.
- ✅ **Faz 6:** Mesajlaşma — teklif kabul edilince thread açılır, realtime mesajlaşma (Supabase Realtime stream).
- ✅ **Faz 7:** Bildirim listesi (in-app) — type'a göre ikon, tap ile route, okundu işaretleme.
- ✅ **Faz 8:** Değerlendirme — 5 yıldız + opsiyonel yorum, profil ekranında özet.

**Kalan fazlar** (ayrı sprintler — her biri native config + 3. parti SDK + canlı test gerektirir):

- ⏳ **Faz 9:** Harita + canlı konum takibi (Google Maps + Geolocator native config). Ekran ve demo fallback mevcut, üretim ayarları eksik.
- ⏳ **Faz 10:** iyzico escrow ödeme akışı. İskelet `lib/features/payments/` altında, supabase tarafında tablo+RLS hazır.
- ⏳ **Faz 11:** Admin paneli (Flutter web). İskelet `lib/features/admin/` altında.
- ⏳ **Faz 12:** Push notification (Firebase Messaging) + store paketleri (signing, ProGuard, screenshot, KVKK, gizlilik metinleri).

Detaylı yol haritası için `docs/ROADMAP.md`.

## Bu Build'i Ilk Çalıştırdığında

1. `flutter pub get`
2. `.env` dosyasını oluştur, Supabase URL ve anon key gir.
3. Supabase tarafında `supabase/migrations/` altındaki migration dosyalarını
   sıra numarasına göre (`001` … `011`) çalıştır.
4. **`dart run build_runner build --delete-conflicting-outputs`** — `.g.dart` dosyalarını üretir. Faz 4-8'de eklenen yeni Riverpod provider'lar için bu şart, atlanırsa derleme başarısız olur.
5. **`flutter gen-l10n`** — `app_tr.arb`'dan Türkçe lokalizasyon sınıfını üretir. Faz 4-8'de eklenen yeni string'ler için bu da şart.
6. `flutter analyze` ile statik kontrol et. Bu repo Anthropic ortamında üretildiği için Flutter SDK ile derlenmedi — minor import/typo düzeltmeleri çıkabilir, normal.
7. `flutter run`.

## Bilinen Notlar

- **Demo modu aktif varsayılan.** `.env.example` içinde `DEMO_MODE=true`; demo kullanıcıları ile offline akış çalışır.
- **Taşıma akışı ekranı eklendi.** Aktif işlerde `/jobs/:id/flow` rotasına yönlenir; timeline + operasyon CTA içerir.
- **Push notification canlı değil.** Faz 12'de tamamlanacak. Demo/prod farkına göre in-app liste çalışır.
- **Harita üretim entegrasyonu eksik.** Demo modda fallback takip görünümü çalışır; canlı Google Maps için key gerekir.
- **Ödeme yok.** "Teslim ettim/aldım" onayı + completed status sonrası şu an direkt review akışına gidiyor. Faz 10'da iyzico escrow araya girecek.
- **fetchThreads N+1.** `lib/features/messages/data/repositories/supabase_messages_repository.dart` her thread için ayrı son-mesaj ve okunmamış sorgu atıyor. MVP'de kabul, sonra Supabase view'a alınmalı.
- **Yasal sayfalar demo içerik.** Profildeki Kullanım Koşulları / Gizlilik / Yardım bağlantıları demo metin gösterir.

