# BURASI ÖNCE OKU — ARACIYOK Hızlı Başlangıç

Bu doküman hızlı başlangıç notudur. Faz bazlı resmi durum için
`docs/ROADMAP.md` tek kaynak kabul edilir.

## İlk açılışta sırayla bunları yap

```bash
# 1. Zip'i aç
unzip araciyok_full.zip
cd araciyok

# 2. Bağımlılıkları çek
flutter pub get

# 3. .env'i hazırla (eğer önceki çalışmandan kalmadıysa)
cp .env.example .env
# Sonra .env'i aç ve Supabase URL + anon key gir.

# 4. Code generation — ŞART, atlanırsa derlemez
dart run build_runner build --delete-conflicting-outputs

# 5. l10n generate — ŞART, atlanırsa l10n.X string'leri bulunamaz
flutter gen-l10n

# 6. Supabase migrations'ı çalıştır
# (Supabase Studio → SQL Editor → supabase/migrations/ altındaki dosyaları
# sıra numarasına göre çalıştır)
# 001 → 002 → 003 → 004 → 005 → 006 → 007 → 008

# 7. Analiz et — burada bir-iki minor hata çıkabilir (Anthropic ortamında üretildi,
#    Flutter SDK ile derlenmedi). Önemli olanlar:
flutter analyze

# 8. Çalıştır
flutter run
```

## Neler eklendi (özet)

**Faz 4 — İlan CRUD**
- `lib/features/jobs/` — model + repository + controller + 4 ekran (list, detail, filter, create)
- Yükveren ilan açar/iptal eder, nakliyeci açık ilanları görür, filtreler.

**Faz 5 — Teklif & Operasyon (uçtan uca)**
- `lib/features/offers/` — model + repository + controller + 3 widget (offer card, operation actions, create sheet)
- Nakliyeci teklif verir, yükveren kabul/red, sonra **çift taraflı pickup onayı → yola çıkış → çift taraflı teslim onayı → tamamlandı**.

**Faz 6 — Mesajlaşma (realtime)**
- `lib/features/messages/` — model + repository + controller + thread list + chat ekranı + bubble widget
- Teklif kabul edilince thread otomatik açılır (003_rpc_functions.sql, accept_offer içinde).
- Supabase Realtime stream ile anlık.

**Faz 7 — Bildirim listesi (in-app)**
- `lib/features/notifications/` — model + repository + controller + ekran
- Push henüz yok (Faz 12).

**Faz 8 — Değerlendirme**
- `lib/features/reviews/` — model + repository + controller + 5 yıldız widget + create sheet
- Profil ekranında son 3 değerlendirme özeti.

**Glue katmanı (kritik)**
- `lib/core/routing/app_router.dart` — yeni rotalar eklendi (/jobs/new, /jobs/:id, /jobs/:id/flow, /messages/:threadId)
- `lib/features/shell/presentation/main_shell.dart` — bottom nav'a okunmamış bildirim ve mesaj badge'leri eklendi
- `lib/features/home/presentation/screens/home_screen.dart` — placeholder yerine gerçek rol bazlı dashboard
- `lib/features/profile/presentation/screens/profile_screen.dart` — placeholder yerine gerçek profil + ayarlar + çıkış
- `lib/l10n/app_tr.arb` — Faz 4-8'in tüm yeni string'leri eklendi
- `supabase/migrations/007_cancel_job_rpc.sql` — eksik olan cancel_job RPC
- `lib/core/demo/` + `demo_*_repository` dosyaları — `DEMO_MODE=true` için offline akış
- `lib/features/jobs/presentation/screens/shipment_flow_screen.dart` — aktif taşıma için yeni akış ekranı

## Yapılmayan + neden

| Konu | Neden bu turda yok |
|------|-------------------|
| Push notification | Firebase Messaging native config + APNs sertifikası + canlı test gerektiriyor |
| Harita ekranı | Üretim Google Maps key + Android/iOS native config + canlı GPS testi gerektiriyor (demo fallback var) |
| iyzico ödeme | Merchant başvurusu + canlı test + KVKK/sözleşme metinleri gerektiriyor |
| Admin paneli | Flutter web'in ayrı config'i, ayrı sprint |
| Profil düzenleme ekranı | ✅ Bu sürümde mevcut |
| Store paketleri | İmza key'leri + ProGuard + screenshot + KVKK metinleri |

Bu kalan 6 konuyu da Claude'a sırayla iki ayrı oturumda yaptırabilirsin — yine de **canlı test ve hesap işlemleri sende kalacak**, kod tarafında her şey hazır.

## Demo modu notu

- Varsayılan geliştirme akışı için `.env` içinde `DEMO_MODE=true` kullan.
- Demo telefonları: `5551111111` (yükveren) ve `5552222222` (nakliyeci), OTP: `123456`.
- Aktif işlerde kartlardan `/jobs/:id/flow` ekranına gider; operasyon adımları bu ekrandan ilerler.

## Hata çıkarsa

İlk derlemede minor hata olma ihtimali var çünkü bu kod Anthropic ortamında üretildi, Flutter SDK ile derlenmedi. Genelde:

- Unused import warning'leri: önemsiz, devam.
- Naming convention: `riverpod_generator` kullanıldı, `*.g.dart` dosyaları build_runner'la üretilir. Çalıştırmadıysan `provider not found` görürsün.
- `l10n.X not found`: `flutter gen-l10n` çalıştırmadın demektir.

Eğer farklı bir hata çıkarsa hata mesajının tamamını + ilgili dosya yolunu Claude'a göster, düzeltir.

## Sıradaki turda Claude'a verecek prompt (örnek)

> Şu hatalar çıktı, düzelt: [hataları yapıştır]

Veya:

> Faz 9'a (harita + canlı konum) geç. Önce native config'i benim için adım adım açıkla — Android `AndroidManifest.xml`, iOS `Info.plist`, Google Maps API key nasıl ekleniyor. Sonra `lib/features/tracking/` altına ekranları yaz.

İyi çalışmalar.
