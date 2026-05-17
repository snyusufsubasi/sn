# ARACIYOK Roadmap

Bu doküman fazların ne içerdiğini, hangi dosyaların ekleneceğini ve "tamamlandı" sayılması için neyin gerektiğini tanımlar.

## Faz 0 — Hazırlık ✅

- Mevcut kod tabanı analizi
- Stack ve tasarım kararları
- Bu iskelet projesinin oluşturulması

## Faz 1 — Proje Kurulumu + Uber Tasarım Sistemi ✅

İçerik (bu zip'te mevcut):
- `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `.env.example`
- `core/config/app_config.dart` — env okuma
- `core/errors/` — Result, AppFailure
- `core/network/` — SupabaseClientWrapper, exception_handler
- `core/utils/` — logger, validators, formatters
- `core/extensions/build_context_x.dart`
- `core/theme/` — colors, dimens, typography, theme
- `core/widgets/` — AppButton, AppTextField, AppScaffold, AppCard, AppBottomSheet, AppEmpty, AppError, AppLoading

**Tamamlandı kriteri**: `flutter analyze` temiz, tema light olarak Material 3 olarak çalışıyor.

## Faz 2 — Supabase Şeması & Backend ✅

İçerik (bu zip'te mevcut):
- `supabase/migrations/001_initial_schema.sql` — tablo & enum
- `supabase/migrations/002_rls_policies.sql` — RLS
- `supabase/migrations/003_rpc_functions.sql` — accept_offer, confirm_pickup, confirm_delivery, vs.
- `supabase/migrations/004_storage_buckets.sql` — bucket politikaları
- `supabase/migrations/005_payments_and_disputes.sql` — Faz 10 için
- `supabase/migrations/006_location_tracking.sql` — Faz 9 için

**Tamamlandı kriteri**: `supabase db push` ile tüm migration'lar uygulanır, Studio'da tablolar görünür.

## Faz 3 — Auth & Profile ✅

İçerik (bu zip'te mevcut):
- `features/auth/data/repositories/` — interface + Supabase impl
- `features/auth/presentation/controllers/` — AuthController, AuthState
- `features/auth/presentation/screens/` — PhoneLogin, OTP
- `features/profile/data/models/` — UserProfile, CarrierProfile
- `features/profile/data/repositories/` — Profile + Carrier
- `features/profile/presentation/controllers/profile_controller.dart`
- `features/profile/presentation/screens/` — RoleSelection, ProfileSetup, CarrierProfileSetup
- `features/shell/presentation/main_shell.dart` — 5 sekmeli bottom nav
- `core/routing/` — go_router config + route paths
- `main.dart` — app entry

**Tamamlandı kriteri**: Telefonla giriş → OTP → role seç → profil doldur → home akışı uçtan uca çalışır (demo modda da çalışır).

## Faz 4 — İlan CRUD ⏳

- `features/jobs/data/models/job_post.dart`
- `features/jobs/data/repositories/jobs_repository.dart`
- `features/jobs/presentation/screens/jobs_list_screen.dart` (rol bazlı: shipper kendi ilanları, carrier açık ilanlar)
- `features/jobs/presentation/screens/job_detail_screen.dart`
- `features/jobs/presentation/screens/create_job_screen.dart` (sadece shipper)
- Filtreleme, arama, sayfalama (pagination)

**Tamamlandı kriteri**: Shipper yeni ilan oluşturur ve görür. Carrier açık ilanları görür ve filtreleyebilir.

## Faz 5 — Teklif & Operasyon Akışı ⏳

- `features/offers/` — teklif verme, kabul, red, geri çekme
- Çift taraflı onay akışı UI'sı (pickup, delivery)
- "Yola çık" butonu
- Job detay sayfasında status timeline

**Tamamlandı kriteri**: Carrier teklif verir → Shipper kabul/red eder → pickup onayı (her iki taraf) → yola çık → delivery onayı (her iki taraf) → tamamlandı.

## Faz 6 — Mesajlaşma & Realtime ⏳

- `features/messages/` — thread listesi, mesajlaşma ekranı
- Supabase Realtime subscription
- "Mesajlaşma kilidi" — teklif kabul edilene kadar disabled
- Okundu bilgisi

**Tamamlandı kriteri**: Teklif kabul edilince thread açılır, iki taraf mesajlaşır, mesajlar realtime gelir.

## Faz 7 — Bildirimler (in-app + push) ⏳

- `features/notifications/` — bildirim listesi, okundu işaretleme
- FCM kurulumu (Firebase Core + Messaging)
- `device_tokens` register
- Push notification handling (foreground + background + tap)
- Local notification fallback

**Tamamlandı kriteri**: Test bildirimi cihaza gelir, in-app listede görünür, tap ile ilgili sayfa açılır.

## Faz 8 — Değerlendirme & Puanlama ⏳

- `features/reviews/` — review oluşturma (job tamamlandıktan sonra), review listesi
- Profil sayfasında ortalama puan, review sayısı
- 1-5 yıldız + opsiyonel yorum

**Tamamlandı kriteri**: Tamamlanan iş sonrası iki taraf birbirini değerlendirebilir, profilde gözükür.

## Faz 9 — Harita & Konum Takibi ⏳

- Google Maps entegrasyonu (Android + iOS native keys)
- `features/tracking/` — carrier'in konumunu yayınlama, shipper'in haritada görme
- Background location (sadece aktif taşıma sırasında)
- KVKK izin akışı

**Tamamlandı kriteri**: Carrier yola çıktıktan sonra konum yayınlamaya başlar, shipper haritada noktayı görür.

## Faz 10 — Ödeme (havale + opsiyonel escrow) ⏳

- **v1.0:** IBAN + havale, sıfır komisyon, nakliyeci onayı → `completed`
- **v1.1 (opsiyonel):** iyzico CheckoutForm + escrow (`held` → `release_payment`)
- `features/payments/` — ödeme ekranı, IBAN kopyala, nakliyeci onay
- Kurulum: `docs/PAYMENT_SETUP.md`

**Tamamlandı kriteri**: Demo/staging'de teslim → ödeme ekranı → nakliyeci onayı → tamamlandı.

## Faz 11 — Admin Web Paneli ⏳

- Flutter Web olarak aynı kod tabanı, sadece `lib/features/admin/`
- Kullanıcı listesi, KYC onay, ilan moderasyonu
- Dispute yönetimi
- Komisyon ve gelir raporu

**Tamamlandı kriteri**: `flutter run -d chrome` ile çalışan ve `admin.araciyok.com`'a deploy edilebilen panel.

## Faz 12 — Test, CI/CD, Store Hazırlığı ⏳

- Integration test'leri (kritik akışlar uçtan uca)
- Coverage hedefi: %60+ unit, kritik akışlar widget
- Fastlane veya GitHub Actions ile store deploy pipeline
- App Store & Play Store metadata (description, screenshots, privacy policy)
- KVKK & gizlilik politikası dokümanları

**Tamamlandı kriteri**: TestFlight'a beta gönderilebilir, Play Console'da internal track'e yüklenebilir.
