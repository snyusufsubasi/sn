# Claude Code'a İlk Prompt

Bu dosyayı zip'i açtıktan sonra Claude Code'a göstermek için kullan. **Aşağıdaki blok'u** Claude Code'a kopyala-yapıştır:

---

## 📋 Kopyalanacak Prompt

```
Merhaba. Bu ARACIYOK projesi — Türkiye odaklı yük pazarı (yükveren ile nakliyeci buluşturma platformu). Önceki Claude Web oturumunda Faz 0-9 tamamlandı ve sen bunun üzerine inşa edeceksin.

İlk olarak şunları sırayla yap:

1. `CLAUDE.md` dosyasını oku — proje context'i orada
2. `AGENTS.md` dosyasını oku — mimari kurallar orada
3. `flutter pub get` çalıştır
4. `dart run build_runner build --delete-conflicting-outputs` — Riverpod codegen, ŞART
5. `flutter gen-l10n` — Türkçe lokalizasyon class üretimi, ŞART
6. `flutter analyze` — çıkan hataları bana göster, hangi dosyalarda ne var?

Hatalar muhtemelen minor (unused import, import order) ama eğer ciddi bir derleme hatası varsa adım adım düzelt.

Bunlar tamamlandığında, sıradaki iş **iyzico ödeme entegrasyonu (Faz 10)**. Önce bana 2 karar sorusu sorman lazım:

1. iyzico akış modeli: A) escrow, B) Marketplace/Subpayment, C) sadece tahsilat. CLAUDE.md'de açıklaması var. Önerin C.
2. SDK seçimi: i) CheckoutForm WebView veya ii) Native SDK. Önerin CheckoutForm.

Ben Türkçe konuşuyorum, Türkçe yanıt ver. Detaylı planlama yerine "yap" tarzı bir yaklaşım istiyorum, ama büyük kararlarda onay al.

Mimari kurallar (özet):
- Feature-first + Result<T> + sealed AppFailure (throw kullanma)
- Cross-feature import yasak (shell hariç)
- Tüm UI string'leri app_tr.arb'da, hard-coded yasak
- @riverpod annotation + build_runner
- Status enum'ları için dbValue getter, magic string yasak

Başlayalım?
```

---

## 🔧 Eğer Claude Code'da Workspace Henüz Boşsa

Önce şu komutla zip'i aç:

```bash
unzip araciyok_full.zip
cd araciyok
```

Sonra Claude Code'u o klasörde başlat ve yukarıdaki prompt'u yapıştır.

## ⚠️ Önemli Hatırlatmalar

1. **`.env` dosyasını manuel oluşturman lazım.** Zip'te `.env.example` var, kopyala adını `.env` yap ve içine Supabase URL + anon key yaz.

2. **Supabase migrations'ı sırayla çalıştır** (001 → 008). Supabase Studio → SQL Editor.

3. **Push notification için ek setup var** — `docs/PUSH_SETUP.md` oku. Bu setup yapılana kadar push bildirim çalışmaz ama uygulama derlenir.

4. **Harita için Google Maps API key gerekli** — `docs/MAP_SETUP.md`. API key olmadan harita ekranı açılır ama sadece gri arka plan görünür.

5. **iOS için Mac şart.** Sadece Android ile başlayacaksan iOS adımlarını atla.

## 🎯 Yapılacak Sıra

1. ⬜ Hataları temizle (flutter analyze)
2. ⬜ Faz 9.5: Geocoding (kısa, isteğe bağlı)
3. ⬜ Faz 10: iyzico ödeme
4. ⬜ Faz 11: Admin paneli (Flutter web)
5. ⬜ Faz 12: Store paketleri (signing, ProGuard, screenshot, KVKK)

Her fazın detayı `CLAUDE.md` ve `docs/ROADMAP.md`'de.
