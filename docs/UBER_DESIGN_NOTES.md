# Uber Tasarım Dili — Somut Karşılıklar

Bu doküman Codex'in tutarlı tasarım üretmesi için referans. Renkler, boyutlar, davranışlar.

## Temel Karakter

- **Sade ve agresif**: Pastel yok. Siyah/beyaz dominant. Tek vurgu renk.
- **Bol whitespace**: Yatay 20dp kenar, dikey 16dp gap minimum.
- **Büyük dokunma alanı**: Buton 56dp, list item 64dp+, icon button 44dp+.
- **Yuvarlatma**: Çok yuvarlak değil. Kart 16dp, buton 12dp, chip pill.
- **Hızlı motion**: 180-240ms ana geçişler. Bounce yok. Decisive.
- **Tipografi ağır**: Başlıklarda 700-800. Inter font.

## Renk Kullanımı

```
Background:        white
Surface:           white (üzerine ink100 border)
Primary CTA:       ink900 (kırmızıya yakın siyah)
Primary text:      ink900
Secondary text:    ink500-ink600
Disabled text:     ink400
Disabled bg:       ink200
Vurgu (accent):    brandPrimary (turuncu) — SAYAÇLI kullan, "bu önemli" demek için
Success:           success (yeşil) — yalnızca durum, başarı bildirimleri
Danger:            error — destructive aksiyonlar (silme, iptal)
```

**Önemli kural**: Turuncu (brandPrimary) interface'in arka planında veya geniş alanlarında ASLA kullanılma. Yalnızca küçük bir vurgu olarak: ARACIYOK logosu, "yeni" badge, seçili tab altı çizgisi, splash logo.

## Light + Dark Sözleşmesi

- Tema modu: `ThemeMode.system` (light/dark otomatik).
- Renk kaynağı: sadece `lib/core/theme/app_colors.dart`.
- Theme mapping: sadece `lib/core/theme/app_theme.dart`.
- Feature/UI katmanında `Color(0x...)` ve `Colors.*` kullanımı yasak.
- Durum renkleri (`status*`, `success`, `warning`, `error`, `info`) semantik amaç dışında dekoratif kullanılmaz.

## Komponent Davranışları

### Button

- **Primary**: Beyaz metin, siyah arka plan (ink900). En önemli aksiyonda kullan.
- **Secondary**: Siyah metin, ink50 arka plan, ink200 border. İkincil aksiyonda.
- **Ghost**: Siyah metin, transparan. Bağlantı kıvamında.
- **Danger**: Beyaz metin, kırmızı arka plan. Geri alınamaz aksiyonlar.

Tap: küçük ripple (Material splash), no scale. Loading: spinner içeride.

### TextField

- Dolu (filled) input, ink50 arka plan.
- Floating label yok — placeholder kullan ya da label üstte ayrı yer.
- Focus'ta border ink900, 1.5dp.
- Error border error rengi, error text labelSmall.

### Card

- Beyaz arka plan, ink100 border, 16dp radius, padding 16dp.
- Elevation 0. Gölge yok. Border ile derinlik.
- onTap varsa ripple görünür.

### BottomSheet

- Üstte drag handle (ink200, 4dp kalın, 32dp geniş).
- Köşeler üstten 28dp radius.
- Backdrop: black, 45% opacity.
- Padding: yatay 20dp, üst 16dp (handle altında), alt safearea.

### Bottom Navigation

- 5 sekme: Anasayfa, İlanlar, Bildirimler, Mesajlar, Profil.
- Seçili: ikon dolu + ink900, label ink900.
- Seçilmeyen: ikon outlined + ink400, label ink500.
- Üst border ink100.
- Background pure white.

## Boyut Standartları

| Eleman | Boyut |
|---|---|
| Sayfa kenar boşluğu | 20dp yatay |
| Section gap | 32dp |
| List item padding | 16dp yatay × 14dp dikey |
| Buton yüksekliği | 56dp (large), 48dp (medium), 40dp (small) |
| Icon button | 44dp minimum tıklama |
| Avatar list | 40dp |
| Avatar profile | 96dp |
| AppBar yüksekliği | 56dp (default) |
| Bottom nav yüksekliği | 68dp |

## Tipografi Hiyerarşi

```
displayLarge   48 / 800   — splash logo
displayMedium  36 / 800   — landing başlık
displaySmall   28 / 800   — büyük başlık
headlineLarge  24 / 800   — sayfa başlığı
headlineMedium 20 / 700   — section başlığı
headlineSmall  18 / 700   — kart başlığı
titleLarge     17 / 700   — kart içi ana metin (fiyat, isim)
titleMedium    15 / 600   — secondary heading
bodyLarge      16 / 400   — okuma metni
bodyMedium     14 / 400   — açıklama, secondary metin
bodySmall      12 / 400   — meta, timestamp
labelLarge     15 / 600   — buton
labelMedium    13 / 600   — chip, badge
labelSmall     11 / 600   — small label, uppercase tracking
```

## Status Renkleri (job_status)

| Status | Renk | Kullanım |
|---|---|---|
| open | statusOpen (mavi) | Açık ilanlar |
| offer_accepted | statusAccepted (mor) | Teklif kabul edilmiş |
| pickup_approval, loaded, on_road, delivery_approval | statusInProgress (turuncu yumuşak) | Devam eden |
| completed | statusCompleted (yeşil) | Tamamlandı |
| cancelled | statusCancelled (gri) | İptal |

Badge formatı: ufak chip içinde icon + label, AppBadge widget'ı.

## Animasyon

- Sayfa geçişi: 240ms ease-out
- Modal: 180ms slide up
- Tap feedback: 100ms scale (no scale, sadece ripple)
- List item insert/remove: AnimatedList ile fade+slide 180ms

## İkonlar

- Material outlined ve filled kullan.
- Seçili durumda filled, default outlined.
- Standart boyut 22dp icon button içinde, 18dp inline (chip/badge), 28dp büyük CTA.
- ASLA renkli ikon (özel custom hariç). Hep ink900 veya ink400 (state'e göre).

## Boş Durum (Empty State)

- Ortalanmış, ekranın merkezi.
- 72dp çember ink50 içinde 32dp ikon (ink500).
- Üst başlık: titleLarge.
- Açıklama: bodyMedium, ink500.
- Opsiyonel CTA: AppButton medium, fullWidth=false.

## Yapılmayacaklar

- ❌ Gradient (logo hariç)
- ❌ Box shadow (Material elevation 0)
- ❌ Renkli emoji
- ❌ Pastel arka plan
- ❌ Renkli ikon (mavi info, kırmızı warning, vs. — sadece state semantic)
- ❌ Italic font (Inter italic yok zaten)
- ❌ Birden fazla vurgu rengi
- ❌ 3D efektleri
- ❌ Glassmorphism / blur

## Yapılacaklar

- ✅ Bol whitespace
- ✅ Büyük dokunma alanları (min 44dp)
- ✅ Tek hierarşi: sayfa → section → kart → eleman
- ✅ Tek bir CTA ön planda, diğerleri ghost/secondary
- ✅ Net mikro-copy: "Devam Et", "Teklif Ver" — belirsiz "Tamam" yok
