# ARACIYOK — Claude Code Handoff

Bu dosya Claude Code'un proje context'ini hızlı kavraması içindir. Geliştirme öncesi mutlaka oku, sonra **AGENTS.md** dosyasındaki mimari kurallara geç.

## Proje Özeti

Yükveren ile kamyon/tır nakliyecisini aracısız buluşturan **Türkiye odaklı yük pazarı**. Flutter (Android + iOS + Web admin), Supabase backend, Uber tasarım dilinde tek kod tabanı.

## Mevcut Durum (Önceki Claude Web oturumunda yazıldı)

Şu fazlar **tamamen yazıldı** ve teslim edildi:

- **Faz 0–3 (iskelet):** proje setup, tasarım sistemi, telefon auth, profile setup, Supabase migrations (001-006)
- **Faz 4 (ilan CRUD):** model + repo + controller + 4 ekran (list, detail, filter, create)
- **Faz 5 (teklif + operasyon):** offer model + RPC entegrasyonu + çift taraflı pickup/delivery onay akışı + operation_actions widget
- **Faz 6 (mesajlaşma):** thread model + realtime stream + chat ekranı + bubble widget
- **Faz 7 (bildirim listesi):** in-app notifications + okundu işaretleme
- **Faz 8 (review):** 5-yıldız + opsiyonel yorum + profil ekranında özet
- **Profil düzenleme:** avatar upload (Supabase Storage) + bilgi güncelleme
- **Push notification (Faz 12'nin push kısmı):** FCM service + Edge Function + device_tokens migration
- **Faz 9 (harita):** Google Maps + canlı konum takibi + TrackingLifecycle (otomatik broadcast başlat/durdur)

**Bu kod henüz Flutter SDK ile derlenmedi** — Anthropic ortamında üretildi, ilk derlemede minor düzeltmeler beklenebilir (unused import warnings, naming convention vs.). Bu büyük bir sorun değil, ama **Claude Code'un ilk yapacağı iş `flutter analyze` çalıştırıp çıkan hataları temizlemek olmalı.**

## Henüz Yapılmayanlar (Claude Code'un yapacakları)

Sırayla:

1. **`flutter analyze` ile başlangıç temizliği** — derleme hatalarını düzelt
2. **Geocoding (Faz 9.5)** — adres alanı doldurulunca otomatik lat/lng çıkarma (`geocoding` paketi pubspec'te var, sadece kullanılmıyor). İlan oluşturma ve profil setup ekranlarında kullanılmalı.
3. **Faz 10 — iyzico ödeme** — büyük iş. **Karar verilmesi gereken iki şey var:**
   - **Akış modeli:** C (sadece yükveren öder, dağıtım uygulama dışı) → en basit. veya A (escrow) veya B (Marketplace/Subpayment).
   - **SDK seçimi:** CheckoutForm WebView (PCI yok, kolay) veya Native SDK (zor, PCI yükümlülüğü var).
   - **Önerilen başlangıç: C + CheckoutForm.** Kullanıcı bunu tercih etti gibi gözüküyor ama bir kez teyit al.
4. **Faz 11 — Admin paneli (Flutter web)** — kullanıcı listesi, dispute yönetimi, ilan moderasyonu. `lib/main_admin.dart` ayrı entry point.
5. **Faz 12 — Store paketleri** — Android signing key, iOS sertifikalar/provisioning, ProGuard, screenshot, KVKK/gizlilik metinleri.

## Kullanıcının Karar Vermesi Gereken Noktalar

iyzico'ya başlamadan önce Claude Code'un kullanıcıya **şu soruyu sorması lazım:**

> "iyzico için 3 akış modeli var. Hangisini istersin?
> A) Klasik escrow — yükveren senin merchant hesabına yatırır, sen havale yaparsın
> B) Marketplace/Subpayment — iyzico her nakliyeciye otomatik dağıtır (her nakliyecinin sub-merchant başvurusu lazım, karmaşık)
> C) Sadece tahsilat — ödeme alırız, nakliyeciye para transferi uygulama dışında (en basit, MVP için önerilen)"

ve **mobile entegrasyon için:**

> "iyzico'da iki seçenek var: i) CheckoutForm WebView (kart bilgisi senin uygulamana hiç dokunmaz, kolay) veya ii) Native SDK ile kendi kart formu (PCI compliance gerekir, çok daha zor). Hangisini istersin?"

**Önerilen başlangıç: C + CheckoutForm.** Bunu kullanıcıya öner.

## Mimari Kurallar (özet, detay AGENTS.md'de)

- **Feature-first + hafif clean.** Her feature'ın kendi `data/` + `presentation/` var. Use case katmanı YOK — Riverpod notifier o işi görür.
- **Cross-feature import yasak** (shell hariç).
- **Repository → `Result<T>` döner**, `AppFailure` sealed tip. Throw kullanma, switch/when ile handle et.
- **Tüm UI string'leri `lib/l10n/app_tr.arb`'da**. Hard-coded string yasak.
- **Riverpod 2.x + `@riverpod` annotation** + build_runner ile codegen. `*.g.dart` dosyaları manuel yazılmaz.
- **Go_router** — tüm path'ler `lib/core/routing/route_paths.dart`'da sabit.
- **Magic string yasak.** Status enum'ları için `dbValue` getter kullan.

## Önemli Sözleşmeler

### Job Status (job_posts.status)

`open → offer_accepted → pickup_approval → loaded → on_road → delivery_approval → completed`

Veya `cancelled` (open'dan iptal).

Çift taraflı onay aşamaları (`pickup_approval`, `delivery_approval`): her iki tarafın da onayı gerekir, RPC içinde flag güncellenir, ikinci onayda otomatik sonraki status'a geçer.

### Offer Status (offers.status)

`pending → accepted | rejected | withdrawn | expired`

### Veri görünürlüğü kuralları

- **Telefon numaraları:** `profile_private_info` tablosunda, RLS ile sadece accepted offer ilişkisi varsa görünür
- **Adres detayları:** UI tarafında `JobStatus.detailsRevealed` getter ile maskelenir (RLS değil, sadece UX)
- **Mesajlaşma:** sadece `accepted` offer olan `(shipper, carrier)` çifti için açık (RLS)

## Dosya Sistemi Layout'u

```
lib/
├── core/                  # ortak altyapı (theme, routing, network, errors, utils, widgets)
├── features/              # feature-first organizasyon
│   ├── auth/
│   ├── profile/
│   ├── jobs/
│   ├── offers/
│   ├── messages/
│   ├── notifications/
│   ├── reviews/
│   ├── payments/          # ŞU AN BOŞ KLASÖR — Faz 10'da doldurulacak
│   ├── tracking/          # Faz 9 — harita + ping broadcaster
│   ├── home/
│   ├── admin/             # ŞU AN BOŞ — Faz 11
│   └── shell/             # bottom nav + tab badge'ler
└── l10n/                  # app_tr.arb (Türkçe) + app_en.arb (placeholder)

supabase/
├── migrations/            # 001-008, sıralı SQL'ler
└── functions/
    └── send-push/         # FCM push gönderici Edge Function

docs/
├── PHASE_PROMPTS.md       # Eski Codex prompt'ları (artık güncel değil ama context için tut)
├── ROADMAP.md             # Tüm faz tanımları
├── UBER_DESIGN_NOTES.md   # Tasarım dili notları
├── PUSH_SETUP.md          # Push kurulum talimatları (kullanıcıya verilen)
└── MAP_SETUP.md           # Google Maps kurulum talimatları
```

## İlk Açılışta Yapılacak Komutlar (kullanıcı atlamış olabilir)

```bash
cd araciyok
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # @riverpod codegen — ŞART
flutter gen-l10n                                            # l10n class üretimi — ŞART
flutter analyze                                             # hata var mı kontrol
```

`build_runner` ve `gen-l10n` atlanırsa "Undefined name `xProvider`" ve "Undefined name `AppLocalizations`" hataları çıkar. Bu Claude Code'un hata değil, sadece komut atlama.

## Bilinen TODO'lar

- [ ] `lib/features/messages/data/repositories/supabase_messages_repository.dart` — `fetchThreads` N+1 query problemi var (her thread için ayrı son-mesaj + unread query). MVP'de kabul ama Supabase view'a alınmalı.
- [ ] İlan oluştururken `origin_lat/lng` ve `destination_lat/lng` boş giriliyor — Faz 9.5 geocoding eklemeli (geocoding paketi pubspec'te zaten var).
- [ ] Background location yok — `Geolocator.getCurrentPosition` periyodik çağrılıyor, sadece foreground çalışır. Tam background için workmanager + foreground notification gerekir, ayrı sprint.
- [ ] Edge Function `send-push` test edilmedi — kullanıcı kurulum yaparken hata çıkarsa logları kontrol et.
- [ ] iOS push için APNs sertifikası yüklenmeli (kullanıcının yapması gerekiyor).
- [ ] `lib/features/admin/` boş — Faz 11.
- [ ] `lib/features/payments/` boş — Faz 10.

## Kullanıcı Tercihleri (önceki konuşmadan)

- Kullanıcı, Codex/opencode'a güvenmediği için Claude'a tamamını yazdırmayı tercih ediyor. Claude Code'a aynı güveni göstermesi muhtemel ama parça parça onay alarak ilerle.
- Kullanıcı Türkçe konuşuyor ve Türkçe yanıt bekliyor.
- Faz 0-9 tamamen Türkçe arayüz ile yazıldı, devam fazlar da Türkçe olmalı.
- Çok detaylı planlama prompt'larına gerek yok — kullanıcı "her şeyi sen yap" tarzında.
- Genelde önerilen seçeneği kabul ediyor (Hangi yoldan gidelim sorularına "önerilen" cevabı veriyor).

## İletişim Şekli

- Açıklayıcı ol ama uzatma. Karar verilmesi gereken yerde **net 2-3 seçenek sun**.
- Her büyük adım sonunda **kullanıcıya bir özetle "şunu yaptım, şu senin tarafında" notu ver**.
- Senin tarafında olan işleri (hesap aç, API key al, native config) **ayrı dokümana yaz** (`docs/X_SETUP.md` pattern'i), kullanıcı orada adım adım takip eder.

## Mevcut Build Notu

Bu zip, Claude Web tarafında üretilen son halidir. İçinde **`.g.dart` dosyaları YOK** (build_runner çıktısı çalıştırılmadı). Claude Code'un ilk yapacağı build_runner çalıştırmak ve ardından `flutter analyze`. Hatalar muhtemelen şunlar olur:

- Riverpod 2.x naming: `@riverpod` üzerinde `Ref` parametre adı `ref`, generator bunu otomatik çevirir — sorun çıkmaz
- Import order warnings: `very_good_analysis` kullanılıyor, bazı dosyaları kendisi `dart fix` ile düzeltebilir
- Yeni dosyalarda muhtemel typo'lar veya export eksiklikleri — `flutter analyze` çıktısından gör, tek tek düzelt

İyi çalışmalar Claude Code 🤝
