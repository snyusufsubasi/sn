# 🎨 ARACIYOK — Komple UI Redesign Planı

> **Versiyon:** 1.0  
> **Hedef:** Sıfırdan yeniden tasarlanmış, 40+ yaş kullanıcıya hitap eden, sıcak ve profesyonel bir görsel kimlik
> **Tarih:** 2026-05-17

---

## 📋 İçindekiler

1. [Tasarım Felsefesi](#1-tasarım-felsefesi)
2. [Renk Sistemi](#2-renk-sistemi)
3. [Tipografi Sistemi](#3-tipografi-sistemi)
4. [Spacing, Radius ve Gölge Sistemi](#4-spacing-radius-ve-gölge-sistemi)
5. [Motion ve Animasyon](#5-motion-ve-animasyon)
6. [Bileşen Kütüphanesi](#6-bileşen-kütüphanesi)
7. [Sayfa Tasarımları](#7-sayfa-tasarımları)
8. [Uygulama Planı (Adım Adım)](#8-uygulama-planı)

---

## 1. Tasarım Felsefesi

### 1.1. Hedef Kullanıcı

ARACIYOK kullanıcıları:
- **40-65 yaş arası**, geleneksel lojistik/nakliye sektöründe çalışan
- Telefonu aktif kullanan ama teknoloji meraklısı olmayan
- **Güven, ciddiyet ve sadelik** arayan
- Göz yorgunluğuna karşı **yüksek kontrast, büyük font, net hiyerarşi** isteyen
- İşini hızlı halletmek isteyen, süslü arayüzlerden hoşlanmayan

### 1.2. Tasarım Prensipleri

| # | Prensip | Anlamı |
|---|---|---|
| 1 | **Güven Ver** | Renkler sıcak ve dengeli. Geçişler yumuşak. Hiçbir şey ani değil. |
| 2 | **Net Ol** | Her ekranda tek bir birincil aksiyon. Metinler büyük, butonlar geniş. |
| 3 | **Yavaş ve Kararlı** | Hızlı swipe'lar yerine dokunma bazlı etkileşimler. Animasyonlar acele etmez. |
| 4 | **Türkiye'ye Özgü Ol** | Renkler Akdeniz sıcaklığı, tipografi okunaklı, mesajlar samimi. |
| 5 | **Saygı Göster** | Kullanıcı işini yapmaya geliyor. Arayüz ona yardım eder, ona gösteriş yapmaz. |

### 1.3. Mevcut Tasarımın Sorunları

1. **Renkler çok soğuk:** Sadece siyah, beyaz, gri — Uber klonu hissi
2. **Fontlar çok agresif:** Inter Tight w800 her yerde, 40+ için yorucu
3. **Kartlar düz ve derinliksiz:** Gölge yok, elevation yok, hiyerarşi kayboluyor
4. **Animasyonlar mekanik:** Çok hızlı, curve'lar doğal değil
5. **Bottom nav sade ve ilhamsız:** Seçili durum sadece kalın font
6. **Buton varyantları yetersiz:** Sadece 4 tip, renk kodu yok
7. **Mobil öncelik yanlış:** 40+ kullanıcı için fontlar çok küçük, touch target'lar dar

---

## 2. Renk Sistemi

### 2.1. Yeni Palet

#### Primary — Lacivert Serisi (Güven)

| Token | Renk | Hex | RGB | Kullanım |
|---|---|---|---|---|
| `navy900` | Çok Koyu Lacivert | `#0F1A30` | 15, 26, 48 | Navbar, en koyu alanlar |
| `navy800` | Lacivert | `#1B2A4A` | 27, 42, 74 | **Primary buton, CTA** |
| `navy700` | Orta Lacivert | `#2A3D63` | 42, 61, 99 | Aktif state, hover |
| `navy600` | Açık Lacivert | `#405A82` | 64, 90, 130 | Vurgulu border, focus |
| `navy500` | Soluk Lacivert | `#6A82A8` | 106, 130, 168 | Disabled buton |
| `navy200` | Çok Soluk | `#C4D0E0` | 196, 208, 224 | İkincil border |
| `navy100` | Neredeyse Beyaz | `#E8EDF5` | 232, 237, 245 | Arka plan tonu |
| `navy50` | Buz Mavisi | `#F4F7FC` | 244, 247, 252 | En hafif arka plan |

#### Accent — Kehribar Serisi (Sıcaklık)

| Token | Renk | Hex | RGB | Kullanım |
|---|---|---|---|---|
| `amber600` | Koyu Kehribar | `#B86520` | 184, 101, 32 | Basılı durum |
| `amber500` | Kehribar | `#D4782E` | 212, 120, 46 | **Ana accent, fırsat** |
| `amber400` | Açık Kehribar | `#E8873A` | 232, 135, 58 | Vurgulu badge |
| `amber200` | Soluk Kehribar | `#F5D7B8` | 245, 215, 184 | Accent arka plan |
| `amber50` | Krem | `#FDF5ED` | 253, 245, 237 | Sıcak arka plan |

#### Neutral — Sıcak Gri Serisi

| Token | Renk | Hex | Kullanım |
|---|---|---|---|
| `ink900` | Siyahımsı | `#1A1A1A` | Ana metin |
| `ink800` | Çok Koyu Gri | `#2E2E2E` | İkincil metin |
| `ink700` | Koyu Gri | `#4A4A4A` | Label metni |
| `ink600` | Orta Gri | `#6B6B6B` | Muted metin |
| `ink500` | Açık Orta Gri | `#8E8E8E` | Placeholder |
| `ink400` | Açık Gri | `#B0B0B0` | Disabled border |
| `ink300` | Daha Açık Gri | `#D1D1D1` | Border, ayraç |
| `ink200` | Çok Açık Gri | `#E8E8E8` | Divider |
| `ink100` | Neredeyse Beyaz | `#F5F5F0` | Card arka planı |
| `ink50` | Sıcak Beyaz | `#FAFAF7` | **Sayfa arka planı** |

#### Semantic — Durum Renkleri

| Token | Renk | Hex | Kullanım |
|---|---|---|---|
| `green600` | Zümrüt Yeşili | `#2D7D46` | Başarı, tamamlandı |
| `green100` | Açık Yeşil | `#E8F5EC` | Başarı arka plan |
| `gold600` | Hardal | `#D4A02B` | Uyarı, beklemede |
| `gold100` | Açık Hardal | `#FDF4E0` | Uyarı arka plan |
| `red600` | Mercan Kırmızısı | `#C94A3C` | Hata, iptal |
| `red100` | Açık Mercan | `#FCEAE7` | Hata arka plan |
| `blue600` | Gök Mavisi | `#3A7BBF` | Bilgi, açık ilan |
| `blue100` | Açık Gök Mavisi | `#EBF2FA` | Bilgi arka plan |

### 2.2. Light Tema

```dart
// Dark tema için: navy900 arka plan, amber500 accent, beyaz metin
AppSemanticColors(
  background: AppPalette.ink50,      // Sıcak beyaz
  surface: AppPalette.ink100,        // Card bg
  surfaceElevated: Color(0xFFFFFFFF), // Modal, sheet
  border: AppPalette.ink300,
  divider: AppPalette.ink200,
  textPrimary: AppPalette.ink900,
  textSecondary: AppPalette.ink700,
  textMuted: AppPalette.ink500,
  cta: AppPalette.navy800,
  ctaText: Color(0xFFFFFFFF),
  accent: AppPalette.amber500,
  accentBg: AppPalette.amber50,
  success: AppPalette.green600,
  successBg: AppPalette.green100,
  warning: AppPalette.gold600,
  warningBg: AppPalette.gold100,
  error: AppPalette.red600,
  errorBg: AppPalette.red100,
  info: AppPalette.blue600,
  infoBg: AppPalette.blue100,
)
```

---

## 3. Tipografi Sistemi

### 3.1. Font Ailesi

| Kullanım | Font | Style |
|---|---|---|
| Başlıklar | **Plus Jakarta Sans** | Yuvarlak, sıcak, premium |
| Gövde metni | Inter | En okunaklı, nötr |
| Rakamlar | Inter | w700 ile net finansal veri |

### 3.2. Font Boyutları (40+ Optimize)

| Token | Eski (px) | Yeni (px) | +/– | Kullanım |
|---|---|---|---|---|
| `displayLarge` | 48 | 40 | -8 | Çok büyüktü, telefonda ezici |
| `displayMedium` | 36 | 32 | -4 | Nadir, splash için |
| `displaySmall` | 28 | 26 | -2 | Büyük sayfa başlığı |
| `headlineLarge` | 24 | 24 | 0 | Sayfa başlığı |
| `headlineMedium` | 20 | 22 | +2 | Ekran başlığı |
| `headlineSmall` | 18 | 20 | +2 | Kart başlığı |
| `titleLarge` | 17 | 18 | +1 | Section başlığı |
| `titleMedium` | 15 | 16 | +1 | Alt başlık |
| `titleSmall` | 13 | 14 | +1 | Küçük başlık |
| `bodyLarge` | 16 | 17 | +1 | Ana okuma metni |
| `bodyMedium` | 14 | 15 | +1 | Standart metin |
| `bodySmall` | 12 | 13 | +1 | Alt not |
| `labelLarge` | 15 | 16 | +1 | Buton metni |
| `labelMedium` | 13 | 14 | +1 | Chip, badge |
| `labelSmall` | 11 | 12 | +1 | Küçük label |

### 3.3. Font Weight

| Kullanım | Eski | Yeni | Gerekçe |
|---|---|---|---|
| Display başlıkları | w800 | w700 | Agresifliği azalt |
| Headline | w800-w700 | w700 | Tutarlılık |
| Title | w700-w600 | w600 | Okunabilirlik |
| Body | w400 | w400 | Korunur |
| Label | w600 | w600 | Korunur |
| Buton | w600 | w600 | Korunur |

### 3.4. Satır Yükseklikleri

| Boyut | Eski | Yeni | Gerekçe |
|---|---|---|---|
| display | 1.1 | 1.2 | Nefes alma alanı |
| headline | 1.15-1.3 | 1.3 | Okunabilirlik |
| title | 1.35-1.4 | 1.4 | Korunur |
| body | 1.45-1.5 | 1.6 | **Kritik:** 40+ için satırlar karışmamalı |
| label | 1.2 | 1.3 | Dokunma hedefi netliği |

---

## 4. Spacing, Radius ve Gölge Sistemi

### 4.1. Spacing (4px Grid)

```dart
class AppSpacing {
  static const double quarks = 2;      // İkon-text arası
  static const double xs = 4;          // Minimal
  static const double sm = 8;          // Element içi
  static const double md = 12;         // Element arası
  static const double lg = 16;         // Bölüm içi
  static const double xl = 20;         // Bölüm arası
  static const double xxl = 24;        // Section arası
  static const double xxxl = 32;       // Büyük bölüm arası
  static const double huge = 48;       // Sayfa içi büyük
  static const double massive = 64;    // Sayfa başı/sonu

  // Özel
  static const double pageHorizontal = 24;  // 20 → 24 (daha ferah)
  static const double cardPadding = 20;     // 16 → 20 (daha rahat)
  static const double cardPaddingSmall = 14;// Küçük kartlar
  static const double touchTarget = 48;     // Minimum dokunma alanı
}
```

### 4.2. Radius

```dart
class AppRadius {
  static const double none = 0;
  static const double xs = 4;     // Avatar, küçük ikon
  static const double sm = 8;     // Input içi element
  static const double md = 12;    // Buton, input (korunur)
  static const double lg = 16;    // Kart (mevcut xl)
  static const double xl = 20;    // Bottom sheet üst (mevcut xxl)
  static const double xxl = 28;   // Dialog, modal
  static const double pill = 999; // Tam yuvarlak
}
```

### 4.3. Gölge Sistemi (YENİ)

```dart
class AppElevation {
  // Kullanım: elevation: 1, 4, 8, 16
  // high, low vb. sayı bazlı

  static BoxDecoration cardDecoration({
    int elevation = 1,
    Color? color,
    double radius = AppRadius.lg,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? AppPalette.ink100,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: _shadows(elevation),
      border: borderColor != null
          ? Border.all(color: borderColor)
          : null,
    );
  }

  static List<BoxShadow> _shadows(int elevation) {
    final c = AppPalette.ink900.withOpacity(0.08);
    switch (elevation) {
      case 1:
        return [BoxShadow(blurRadius: 2, offset: Offset(0, 1), color: c)];
      case 4:
        return [
          BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: c),
          BoxShadow(blurRadius: 12, offset: Offset(0, 4), color: c.withOpacity(0.04)),
        ];
      case 8:
        return [
          BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: c),
          BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: c.withOpacity(0.08)),
        ];
      case 16:
        return [
          BoxShadow(blurRadius: 16, offset: Offset(0, 8), color: c),
          BoxShadow(blurRadius: 48, offset: Offset(0, 16), color: c.withOpacity(0.12)),
        ];
      default:
        return [];
    }
  }
}
```

---

## 5. Motion ve Animasyon

### 5.1. Süreler (Daha Yavaş)

| Token | Eski | Yeni | Kullanım |
|---|---|---|---|
| `instant` | — | 50ms | Basılı his, tap feedback |
| `fast` | 160ms | 200ms | Hover, mikro animasyon |
| `normal` | 220ms | 350ms | Kart açılma, liste öğesi |
| `slow` | 320ms | 500ms | Sayfa geçişi |
| `deliberate` | 480ms | 800ms | Modal, bottom sheet |

### 5.2. Curve'lar (Daha Doğal)

| Token | Değer | Kullanım |
|---|---|---|
| `standard` | `Cubic(0.25, 0.1, 0.25, 1.0)` | Genel geçiş (CSS ease) |
| `decelerate` | `Cubic(0.0, 0.0, 0.2, 1.0)` | Öğe girerken (yavaşlayarak dur) |
| `accelerate` | `Cubic(0.4, 0.0, 1.0, 1.0)` | Öğe çıkarken (hızlanarak kaybol) |
| `emphasize` | `Cubic(0.2, 0.0, 0.0, 1.0)` | Özel vurgu girişi |
| `spring` | `Curves.easeOutBack` | Buton, kart bounce |

### 5.3. Animasyon Kategorileri

#### A. Sayfa Geçişleri

```dart
// İleri giderken: slide sağdan + fade (500ms, decelerate)
// Geri dönerken: slide soldan + fade (350ms, standard)
// Tüm GoRouter route'larında kullanılacak
```

#### B. Listeye Giriş Animasyonu

Her kart sırayla:
1. scaleY: 0.97 → 1.0 (350ms)
2. fadeIn: 0 → 1 (350ms)
3. slideY: 4px → 0 (350ms)
4. Gecikme: `index * 50ms`

#### C. Buton Mikro-Animasyonu

```dart
// Tap down: scale 1.0 → 0.97 (100ms)
// Tap up: scale 0.97 → 1.0 spring (200ms)
// Primary butonda: elevation 1 → 4 (dokununca yükselir)
```

#### D. Bottom Sheet

1. Arka plan kararır: opacity 0 → 0.4 (300ms)
2. Sheet açılır: translate 100% → 0% + scale 0.95 → 1.0 (400ms, decelerate)
3. Drag handle: sabit, gri, ortalanmış

#### E. Staggered Sayfa Girişi

```
0ms:    AppBar (fade + slide)
100ms:  Hero bölümü (fade + scale)
200ms:  Hızlı aksiyonlar (fade + slide)
300ms:  İlk kart (fade + slide)
360ms:  İkinci kart
420ms:  Üçüncü kart
...devam
```

#### F. Yükleme (Skeleton)

- Shimmer hızı: 1500ms → **2000ms** (daha yavaş, daha sakin)
- Skeleton'lar sayfaya girerken: fadeIn (300ms)

---

## 6. Bileşen Kütüphanesi

### 6.1. AppButton

| Variant | Arka Plan | Metin | Border | Gölge |
|---|---|---|---|---|
| `primary` | navy800 | Beyaz | Yok | Evet (low) |
| `secondary` | Beyaz | navy800 | ink300 | Yok |
| `accent` | amber500 | Beyaz | Yok | Evet (low) |
| `ghost` | Transparent | navy800 | Yok | Yok |
| `danger` | red600 | Beyaz | Yok | Evet (low) |
| `success` | green600 | Beyaz | Yok | Evet (low) |

**Boyutlar:** small=44px, medium=52px, large=60px (40+ için büyük)

### 6.2. AppCard

- **Varsayılan:** elevation=1 (hafif gölgeli)
- **Padding:** 20px
- **Radius:** 16px (lg)
- **Tap edilebilir:** elevation 1 → 3 (animasyonlu)
- **Border:** sadece elevation=0 ise görünür

### 6.3. AppTextField

- Floating label (Material 3)
- Arka plan: ink100, focus: ink50
- Border: ink300 (normal), navy600 (focus), red600 (error)
- Font size: 17px (bodyLarge)
- MaxLength gösterimi
- Leading/trailing ikon desteği

### 6.4. AppBottomSheet

- Drag handle: 32×4px, ink300, ortalanmış
- Üst radius: xl (20px)
- Açılış: translate + fade (400ms, decelerate)
- Arka plan: navy900 opacity 0.4
- Padding: 24px horizontal

### 6.5. Yeni Bileşenler

#### AppAvatar

- İlk harf gösterimi (hash bazlı renk)
- Profil fotoğrafı desteği
- Boyutlar: xs=32, sm=40, md=48, lg=56, xl=72

#### AppStepper (Navlun akışı)

- Daire + çizgi + label
- Tamamlanan: yeşil onay
- Aktif: navy800 dolu
- Bekleyen: gri çember
- Çizgi animasyonlu

#### AppStatusBadge

- open: mavi (blue600)
- inProgress: kehribar (amber500)
- completed: yeşil (green600)
- cancelled: gri (ink500)

---

## 7. Sayfa Tasarımları

### 7.1. Splash Ekranı

```
navy800 arka plan
    ↓
    ARACIYOK (logo, beyaz, büyük)
    "Yükveren ile Nakliyeci Buluşuyor"
    ↓ (600ms fade)
    ↓ (200ms delay)
    [yükleniyor...] (ince çizgi, altta)
```

### 7.2. Login Ekranı

```
[Telefon ikonu - büyük]
"Telefon Numaran" (24px, navy800)
"+90 5XX XXX XX XX" (input)
[Kodu Gönder] ← amber500 buton
"ARACIYOK'a hoş geldiniz"
```

### 7.3. OTP Ekranı

```
"Doğrulama Kodu" (22px)
"5XX XXX XX XX numarasına kod gönderildi"
[ _ ][ _ ][ _ ][ _ ][ _ ][ _ ] (52×64px kutular)
"30 sn sonra tekrar gönder"
Yanlış kod → shake animasyonu
```

### 7.4. Rol Seçim

```
"Hangisi sensin?" (24px)
┌────────────────┐  ┌────────────────┐
│   📦            │  │   🚛            │
│   Yükveren      │  │   Nakliyeci    │
│   Yüküm var     │  │   Aracım var   │
└────────────────┘  └────────────────┘
        navy800            amber500
[Devam Et] ← altta sabit
```

### 7.5. Ana Sayfa Layout

```
┌──────────────────────────────┐
│  👋 Merhaba, Ahmet Bey       │ (18px, w600, navy800)
│  Hoş geldiniz                │ (14px, ink600)
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ 3  aktif taşıma          │ │ ← navy800 gradient bg
│ │ 12 toplam ilan           │ │    beyaz metin, lg radius
│ │ 📦 Yeni teklif var!      │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│  Hızlı İşlemler              │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐         │
│ │📝│ │📋│ │💬│ │⚙️│         │ ← 2×2 grid, büyük ikonlar
│ └──┘ └──┘ └──┘ └──┘         │
├──────────────────────────────┤
│  Aktif Taşımalar       Tümü→ │
│ ┌──────────────────────────┐ │
│ │ İstanbul → Konya         │ │ ← gölgeli kart
│ │ TIR • 22 ton             │ │
│ │ 🔵 Yolda                 │ │ ← status badge
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

## 8. Uygulama Planı

### Aşama 1: Token Altyapısı

- [ ] `lib/core/theme/colors/app_palette.dart` — **YENİ**
- [ ] `lib/core/theme/colors/app_semantic_colors.dart` — **YENİ**
- [ ] `lib/core/theme/colors/app_colors.dart` — **GÜNCELLE** (uyumluluk katmanı)
- [ ] `lib/core/theme/typography/app_typography.dart` — **GÜNCELLE**
- [ ] `lib/core/theme/dimensions/app_spacing.dart` — **YENİ**
- [ ] `lib/core/theme/dimensions/app_dimens.dart` — **GÜNCELLE**
- [ ] `lib/core/theme/motion/app_duration.dart` — **YENİ**
- [ ] `lib/core/theme/motion/app_curves.dart` — **YENİ**
- [ ] `lib/core/theme/motion/app_page_transition.dart` — **YENİ**
- [ ] `lib/core/theme/app_theme.dart` — **GÜNCELLE** (yeni renk + font + gölge)

### Aşama 2: Bileşenler

- [ ] `app_button.dart` — yeni variant'lar, gölge, spring animasyonu
- [ ] `app_card.dart` — elevation parametresi, gölgeli varsayılan
- [ ] `app_text_field.dart` — floating label, 17px font
- [ ] `app_scaffold.dart` — scroll-aware appbar
- [ ] `app_bottom_sheet.dart` — animasyonlu açılış
- [ ] `app_skeleton.dart` — yavaş shimmer
- [ ] **YENİ:** `app_avatar.dart`
- [ ] **YENİ:** `app_stepper.dart`
- [ ] **YENİ:** `app_status_badge.dart`

### Aşama 3: Ana Ekranlar

- [ ] SplashScreen — navy800, logo animasyonu
- [ ] PhoneLoginScreen — yeni layout
- [ ] OtpScreen — shake animasyonu, büyük kutular
- [ ] RoleSelectionScreen — kart bazlı seçim
- [ ] HomeScreen — grid quick actions, hero band

### Aşama 4: Shell / Navigation

- [ ] Bottom navigation — yeni seçili göstergesi
- [ ] Sekme geçiş animasyonu
- [ ] Badge animasyonları

### Aşama 5: İş Ekranları

- [ ] JobsListScreen — tüm tab'lar yeni kart tasarımı
- [ ] JobDetailScreen — hero rotası, sabit bottom CTA
- [ ] CreateJobScreen — form güncellemesi
- [ ] ProfileScreen — avatar, ayarlar

### Aşama 6: Test

- [ ] Light/dark tema testi
- [ ] Demo modda tüm ekranlar
- [ ] 40+ font boyutları kontrolü
- [ ] Animasyon akıcılığı testi
- [ ] `flutter analyze` — hata yok
