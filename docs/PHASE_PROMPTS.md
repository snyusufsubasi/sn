# Codex İçin Faz Prompt'ları

Her faz için Codex'e verebileceğin hazır prompt'lar. Önce mutlaka `AGENTS.md` okutuyor olduğundan emin ol — bu dosya o kuralları varsayarak yazıldı.

Kullanım: ilgili prompt'u kopyala, Codex'e ver. Faz bitince `flutter analyze` ve `flutter test` çalıştır, yeşil olduğundan emin ol, sonra sonraki faza geç.

---

## Faz 4 — İlan CRUD

```
AGENTS.md ve docs/ROADMAP.md dosyalarını oku. Şimdi Faz 4'ü implement edeceğiz: İlan (job_post) CRUD.

Gerekli dosyalar:

1. lib/features/jobs/data/models/job_post.dart
   - Tablo: job_posts (001_initial_schema.sql'da tanımlı)
   - Tüm alanları kapsayan JobPost modeli (Equatable, fromJson, toJson, copyWith)
   - JobStatus enum'u (open, offer_accepted, pickup_approval, loaded, on_road, delivery_approval, completed, cancelled)
   - Helper getter'lar: isOpen, isInProgress, isCompleted, isCancelled

2. lib/features/jobs/data/repositories/jobs_repository.dart (interface)
   - fetchOpenJobs({String? originCity, String? destinationCity, int limit = 20, int offset = 0})
   - fetchMyJobs() — shipper için kendi ilanları
   - fetchJobById(String id)
   - createJob(JobPost) — sadece shipper
   - updateJob(JobPost) — sadece sahip, sadece status='open' ise
   - cancelJob(String id, String reason) — RPC cancel_job çağırır
   - watchJob(String id) — Supabase realtime stream

3. lib/features/jobs/data/repositories/supabase_jobs_repository.dart (impl)

4. lib/features/jobs/presentation/controllers/jobs_controller.dart
   - openJobsProvider — açık ilanlar (carrier için)
   - myJobsProvider — kendi ilanlarım (shipper için)
   - jobDetailProvider.family<JobPost?, String> — tekil ilan
   - currentProfile'a göre hangi listenin döneceğini ayarla

5. lib/features/jobs/presentation/screens/jobs_list_screen.dart
   - Role'e göre içerik:
     - Shipper: kendi ilanları (status filtreleme: tümü/açık/devam/tamamlanan)
     - Carrier: açık ilanlar (origin/destination filtre)
   - Her ilan AppCard içinde: başlık, güzergah (origin→destination), tarih, fiyat aralığı, ağırlık, status badge
   - Carrier için ek bilgi: yükveren ratingi
   - Pull-to-refresh
   - Sonsuz scroll (pagination)
   - Boş durum: AppEmptyState

6. lib/features/jobs/presentation/screens/job_detail_screen.dart
   - Tüm detaylar (open ise origin_address/destination_address ve detay maskelenir)
   - Teklif kabul edilmişse açılır
   - Status timeline (Faz 5'te genişletilecek, şimdilik basit gösterim)
   - Shipper için: iptal et butonu (status='open' ise)
   - Carrier için: "Teklif ver" butonu (Faz 5'te aktif olacak, şimdilik disabled)

7. lib/features/jobs/presentation/screens/create_job_screen.dart
   - Sadece shipper erişebilir
   - Form: başlık, açıklama, kargo tipi (dropdown), ağırlık, hacim, origin (şehir + ilçe + adres), destination (şehir + ilçe + adres), pickup_date, delivery_date, budget min/max, preferred_trailer_type
   - Validation: tüm zorunlu alanlar dolu, ağırlık > 0, pickup_date >= bugün
   - Submit → AppButton large, sonrasında listeyi invalidate et

8. l10n stringlerini app_tr.arb'a ekle (jobsTitle, jobsCargoType, jobsWeight, jobsOrigin, jobsDestination, jobsPickupDate, jobsBudget, jobsCreate, vb.)

9. Test:
   - test/unit/features/jobs/jobs_repository_test.dart — mocktail ile
   - test/widget/features/jobs/jobs_list_screen_test.dart — boş durum, dolu durum

Tasarım:
- Uber dilinde, AppCard içinde ilanlar
- Status renkleri: open=mavi, in_progress=turuncu, completed=yeşil, cancelled=gri
- Fiyat aralığı vurgulu (FontWeight.w700)
- Origin → Destination'ı ok ikonuyla göster

Build runner'ı çalıştırmayı unutma: dart run build_runner build --delete-conflicting-outputs
```

---

## Faz 5 — Teklif & Operasyon Akışı

```
AGENTS.md ve docs/ROADMAP.md oku. Faz 4 (jobs) tamamlandı. Şimdi Faz 5: teklif (offer) ve operasyon akışı.

Gerekli:

1. lib/features/offers/data/models/offer.dart
   - Equatable, fromJson, toJson, copyWith
   - OfferStatus enum (pending, accepted, rejected, withdrawn, expired)

2. lib/features/offers/data/repositories/offers_repository.dart
   - fetchOffersForJob(String jobId) — yükveren için
   - fetchMyOffers() — nakliyeci için
   - createOffer({jobPostId, price, message}) — sadece carrier, kendi tek teklifi
   - acceptOffer(String offerId) — RPC accept_offer
   - rejectOffer(String offerId) — RPC reject_offer
   - withdrawOffer(String offerId)
   - confirmPickup(String jobId) — RPC confirm_pickup
   - startRoad(String jobId) — RPC start_road
   - confirmDelivery(String jobId) — RPC confirm_delivery

3. UI:
   - JobDetailScreen'e teklif bölümü ekle
     - Shipper görünümü: gelen teklif listesi, her teklifin yanında Kabul/Red butonu
     - Carrier görünümü: kendi teklifi varsa göster, yoksa "Teklif Ver" CTA
   - lib/features/offers/presentation/widgets/offer_card.dart — teklif kartı
   - lib/features/offers/presentation/screens/create_offer_sheet.dart — BottomSheet ile teklif girişi
   - lib/features/offers/presentation/widgets/operation_actions.dart — pickup/delivery onay butonları
     - Status'a göre dinamik buton (Yük Aldım, Yola Çıktım, Teslim Ettim)
     - Çift taraflı onay durumu net gösterilmeli ("Karşı tarafın onayı bekleniyor")

4. l10n: offers* prefix'i ile, yine app_tr.arb

5. Test:
   - Unit: offers_repository_test.dart (mock)
   - Widget: offer_card_test.dart, operation_actions_test.dart

Tasarım:
- Kabul butonu primary (siyah), Red butonu ghost
- Teklif kartı AppCard, fiyat büyük (titleLarge), mesaj bodyMedium
- Operation actions için Uber'in "swipe to confirm" yerine basit AppButton primary
```

---

## Faz 6 — Mesajlaşma & Realtime

```
AGENTS.md oku. Faz 6: mesajlaşma.

Gerekli:

1. lib/features/messages/data/models/message_thread.dart
2. lib/features/messages/data/models/message.dart
3. lib/features/messages/data/repositories/messages_repository.dart
   - fetchThreads() — kullanıcının thread listesi (last_message ile join)
   - fetchMessages(threadId, limit, before)
   - sendMessage(threadId, body)
   - markRead(messageId) — kendi mesajlarını okundu işaretle
   - watchMessages(threadId) — Supabase Realtime channel
   - watchThreads() — thread değişikliklerini dinle

4. lib/features/messages/presentation/screens/threads_list_screen.dart
   - Bottom nav Mesajlar tab'ında render
   - Her thread: avatar, isim, son mesaj snippet, okunmamış badge
   - Boş durum: AppEmptyState ("Henüz mesaj yok")

5. lib/features/messages/presentation/screens/message_thread_screen.dart
   - Uber Eats tarzı: üstte karşı taraf bilgisi (avatar, isim, ilan başlığı), aşağıda mesaj listesi, en altta yazma alanı
   - Realtime: yeni mesaj geldiğinde liste otomatik güncellenir
   - Kendi mesajları sağda turuncu (brandPrimary), karşı taraf solda gri (ink50)
   - Optimistic UI: send'e basınca anında listede gösterip sonra Supabase'e yaz

6. Mesajlaşma kilidi:
   - Eğer kullanıcı, herhangi bir thread'i olmayan birine mesaj atmaya çalışıyorsa (ki UI bunu zaten engelleyecek), AppEmptyState("Teklif kabul edilince mesajlaşma açılır")

7. Realtime subscription'ları MUTLAKA dispose et (ref.onDispose).

8. l10n: msg* prefix

9. Test: messages_repository_test.dart, message_bubble_test.dart
```

---

## Faz 7 — Bildirimler (in-app + push)

```
AGENTS.md oku. Faz 7: bildirimler.

İki katman:

A) In-app bildirim listesi:

1. lib/features/notifications/data/models/app_notification.dart
2. lib/features/notifications/data/repositories/notifications_repository.dart
3. lib/features/notifications/presentation/controllers/notifications_controller.dart
   - unreadCountProvider — alt tab'da badge için
   - notificationsProvider — liste
4. lib/features/notifications/presentation/screens/notifications_screen.dart
   - Bottom nav Bildirimler tab
   - Her bildirim: ikon (type'a göre), title, body, time (relative format), okunmamışsa nokta
   - Tap → ilgili sayfaya yönlendir (data.job_post_id varsa job detail, vs.)
   - Pull-to-refresh, mark all as read

B) Push notification:

1. Firebase setup (Android için google-services.json, iOS için GoogleService-Info.plist — kullanıcı zaten Console'dan indirip yerleştirecek; sen kod tarafını yaz)

2. lib/features/notifications/data/services/push_service.dart
   - initialize() — main()'de çağrılır, permission iste, FCM token al
   - device_tokens tablosuna kaydet (user_id, fcm_token, platform)
   - onMessage (foreground) — flutter_local_notifications ile göster
   - onMessageOpenedApp — tap handling, ilgili sayfaya yönlendir
   - getInitialMessage — cold start handling
   - token refresh handler

3. Edge Function (Supabase Functions):
   - supabase/functions/send-push/index.ts
   - Trigger: notifications tablosuna insert sonrası (database webhook veya cron)
   - FCM API'ye request

4. Permission akışı:
   - iOS'ta UNUserNotificationCenter ile izin iste
   - Android 13+'da POST_NOTIFICATIONS izni iste
   - Reddederse profile sayfasında "Bildirimleri aç" CTA göster

5. main.dart'a push init ekle (Firebase.initializeApp + pushService.initialize)

6. l10n: notif* prefix

7. Test: notifications_repository_test.dart

NOT: Firebase config dosyaları yoksa main()'de Firebase.initializeApp() try-catch içinde, sessizce skip etsin. Demo modda push çalışmaz.
```

---

## Faz 8 — Değerlendirme & Puanlama

```
AGENTS.md oku. Faz 8: review.

1. lib/features/reviews/data/models/review.dart
2. lib/features/reviews/data/repositories/reviews_repository.dart
   - createReview(jobPostId, revieweeId, rating, comment)
   - fetchReviewsForUser(userId, limit, offset)
   - hasReviewedJob(jobPostId, reviewerId)
3. UI:
   - Job tamamlandıktan sonra otomatik bottom sheet aç: "Karşı tarafı değerlendir"
   - 5 yıldızlı seçici (büyük, dokunmatik), opsiyonel yorum text field
   - Profile sayfasında: rating_avg (büyük), completed_jobs_count, son 5 review
   - lib/features/reviews/presentation/widgets/star_rating.dart — atomic widget

4. profiles tablosundaki rating_avg zaten trigger ile güncelleniyor.

5. l10n: review* prefix

6. Test: star_rating_test.dart
```

---

## Faz 9 — Harita & Konum Takibi

```
AGENTS.md oku. Faz 9: harita.

Önce native config:

1. android/app/src/main/AndroidManifest.xml
   - GOOGLE_MAPS_API_KEY meta-data (placeholder, AppConfig.googleMapsApiKeyAndroid değil — manifest'te direkt key gerek)
   - FOREGROUND_SERVICE_LOCATION izni
   - ACCESS_FINE_LOCATION, ACCESS_BACKGROUND_LOCATION

2. ios/Runner/Info.plist
   - NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription
   - GMSApiKey kayıt için AppDelegate.swift'e GMSServices.provideAPIKey

3. lib/features/tracking/data/repositories/tracking_repository.dart
   - sendPing(jobId, lat, lng, accuracy, speed, heading)
   - watchPings(jobId, since) — realtime ping stream
4. lib/features/tracking/data/services/location_service.dart
   - startTracking(jobId) — geolocator ile background location stream başlat, ping at
   - stopTracking()
   - permission akışı

5. lib/features/tracking/presentation/screens/job_tracking_screen.dart
   - GoogleMap widget
   - Carrier'in son konumunu marker olarak göster
   - Route polyline (Google Directions API ile origin-current arası, opsiyonel)
   - Shipper için: passive (sadece izle)
   - Carrier için: "Konumu paylaş" toggle (status=on_road olduğunda)

6. KVKK izin akışı:
   - İlk takip sırasında modal: "Konumun yükveren ile paylaşılacak..."

7. l10n: tracking* prefix

NOT: Google Maps API key alma sürecini kullanıcıya hatırlat. Demo modda map yerine placeholder.
```

---

## Faz 10 — Ödeme & Escrow

```
AGENTS.md ve özellikle supabase/migrations/005_payments_and_disputes.sql'i oku.

İki taraf:

A) Supabase Edge Functions (deno):

1. supabase/functions/create-payment/index.ts
   - Input: { jobPostId, offerId }
   - iyzico Checkout Form initialize çağrısı
   - payments tablosuna 'pending' status ile insert
   - Output: { paymentPageUrl, conversationId }

2. supabase/functions/iyzico-callback/index.ts
   - iyzico callback handler
   - iyzico_callbacks tablosuna raw payload yaz
   - Başarılıysa payments.status='held'
   - İlgili taraflara notification

3. supabase/functions/release-payment/index.ts
   - RPC release_payment çağırır (zaten yazılı)
   - Cron veya manuel tetiklenir

B) Flutter tarafı:

1. lib/features/payments/data/models/payment.dart
2. lib/features/payments/data/repositories/payments_repository.dart
   - createPayment(jobPostId, offerId) — Edge Function çağırır
   - fetchPaymentForJob(jobId)
3. lib/features/payments/presentation/screens/checkout_screen.dart
   - WebView ile iyzico checkout page'i aç
   - Callback URL'ini dinle, başarılıysa Success ekranı
4. lib/features/payments/presentation/screens/payment_status_screen.dart
   - Bekleyen/Held/Released durumlarına göre UI
5. Job detail sayfasına ödeme durumu badge ekle (Faz 5'te placeholder vardı)

NOT: iyzico secret key ve secret API key SUPABASE EDGE FUNCTION ENV'sinde tutulur, asla client'a gönderilmez. Client sadece checkout URL'ini açar.

l10n: payment* prefix
```

---

## Faz 11 — Admin Web Paneli

```
AGENTS.md oku. Faz 11: admin paneli (Flutter Web).

Stratejii: aynı kod tabanı, ama:
- web platform için ayrı entry point (lib/main_admin.dart)
- Admin shell ayrı (lib/features/admin/presentation/admin_shell.dart) — bottom nav yerine side rail
- admin_roles tablosunda kayıtlı olmayan kullanıcıyı engelleyen guard

Gerekli ekranlar:

1. Dashboard — günlük yeni ilan, tamamlanan iş, gelir özet
2. Kullanıcılar — liste, detay, KYC onay, suspend
3. İlanlar — moderation, status değiştirme
4. Anlaşmazlıklar (disputes) — listele, taraflarla konuş, karar ver
5. Komisyon ayarı — payment_settings tablosu (yeni eklenecek)
6. Raporlar — gelir, komisyon, en aktif kullanıcı

build & run:
- flutter run -d chrome --target=lib/main_admin.dart

l10n: admin* prefix (Türkçe ve İngilizce baştan)

NOT: Mobile build'i kırma. Conditional import ile platform ayrımı yap.
```

---

## Faz 12 — Test, CI/CD, Store

```
AGENTS.md oku. Faz 12: bitiş.

A) Test kapsamı:
- integration_test/critical_flows_test.dart
  - Tüm auth akışı
  - İlan oluştur → teklif ver → kabul et → tamamla
- Tüm feature'lar için unit test (repository + controller)
- Tüm screen'ler için widget test (en az boş ve dolu durum)
- coverage hedefi: %60

B) CI/CD:
- .github/workflows/ci.yml zaten var, genişlet
- .github/workflows/deploy_play.yml — Play Store internal track
- .github/workflows/deploy_appstore.yml — TestFlight
- Fastlane veya direkt action: bundletool, signing, upload

C) Store hazırlık:
- Açıklama metinleri (en az TR, EN)
- Ekran görüntüleri (her ekran için 5'er adet, her boyut için)
- Privacy policy URL (Supabase'de host edilebilir)
- App icon 1024x1024
- Splash screen finalize

NOT: Bu faz aslında uzun, küçük PR'lara böl.
```

---

## Genel Codex İpuçları

1. Codex'e her seferinde **`AGENTS.md` ve ilgili faz prompt'unu birlikte oku** dedirt.
2. Bir faz tamamlanmadan bir sonrakine geçme.
3. Her faz sonunda: `flutter analyze`, `flutter test`, `dart format`, commit.
4. Code generation eklediysen: `dart run build_runner build --delete-conflicting-outputs`.
5. l10n string'i eklediysen: `flutter gen-l10n`.
6. Hard-coded string gördüğünde Codex'ten l10n'a taşımasını iste.
7. Bir feature'ı bitirdikten sonra, son adım olarak `docs/ROADMAP.md`'deki ⏳'yi ✅ yap.
