# 🚛 ARACIYOK — İlanlar & Teklif Akışı Tasarım Planı

> **Versiyon:** 1.0  
> **Kapsam:** Jobs tab (ikinci sekme) + Job Detail + Offer akışının baştan sona yeniden tasarımı  
> **Hedef:** Basit, kullanışlı, 81 il desteğiyle Türkiye'nin her yerinden ilan gösterme  

---

## 📋 İçindekiler

1. [Tasarım Felsefesi](#1-tasarım-felsefesi)
2. [İlanlar Sekmesi — Genel Yapı](#2-ilanlar-sekmesi)
3. [Filtreleme Sistemi](#3-filtreleme-sistemi)
4. [İlan Kartı Tasarımı (JobCard)](#4-ilan-kartı)
5. [İlan Detay Ekranı](#5-ilan-detay)
6. [Teklif Akışı (Carrier)](#6-teklif-akışı-carrier)
7. [Teklif Yönetimi (Shipper)](#7-teklif-yönetimi-shipper)
8. [Demo Veri Güncellemeleri](#8-demo-veri)
9. [Animasyon ve Geçişler](#9-animasyonlar)
10. [Uygulama Adımları](#10-uygulama-adımları)

---

## 1. Tasarım Felsefesi

### 1.1. Kullanıcı Senaryoları

**Nakliyeci (Carrier):**
> "Malatya'dan İzmir'e yük arıyorum. 20 tonluk bir yük var mı, kimin ilanı var, hemen teklif vereyim."

**Yükveren (Shipper):**
> "İstanbul'dan Ankara'ya tekstil göndereceğim. İlanı açtım, gelen teklifleri karşılaştırıp en uygununu seçeyim."

### 1.2. Tasarım Prensipleri

| Prensip | Açıklama |
|---|---|
| **Hızlı Filtrele** | Kullanıcı 81 il arasından 2 dokunuşla filtrelesin |
| **Rota Gör** | Nereden nereye gittiğini kartın üstünde harita gibi görsün |
| **Tek Hareketle Teklif** | İlanı gör → Fiyat gir → Gönder — üç adımda bitsin |
| **Karşılaştır** | Gelen teklifleri yan yana görüp karar versin |

### 1.3. Mevcut Durumun Eleştirisi

**Sorun 1: Filtreler gizli bir sheet'te**
Kullanıcı filtrelemek için önce ikona tıklamalı, sonra sheet açılmalı, dört dropdown seçmeli, sonra "Uygula" demeli. Bu çok uzun.

**Sorun 2: 81 il arasında gezinme zor**
Dropdown'ta 81 il var — alfabetik sıralı olsa bile kaydırmak zahmetli. Arama kutusu yok.

**Sorun 3: Kartta rota görsel değil**
Metin olarak "İstanbul, Kadıköy" yazıyor. Oysa nakliyeci rotayı görsel olarak (çizgi + nokta) görmek ister.

**Sorun 4: Teklif verme dört adımda**
Sheet aç → Job özeti gör → Fiyat yaz → Mesaj yaz → Gönder. Çok uzun.

**Sorun 5: Shipper için teklif karşılaştırma yok**
Gelen teklifler alt alta listeleniyor. Fiyat, puan, tamamlanan iş sayısı yan yana görünmüyor.

---

## 2. İlanlar Sekmesi

### 2.1. Genel Sayfa Yapısı

```
┌──────────────────────────────────────┐
│  📋 İlanlar                   [+ Filtre] │  ← AppBar
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  Nereden       →    Nereye     │  │  ← Yatay chip bar (HER ZAMAN görünür)
│  │  [İl seç]  →  [İl seç]        │  │
│  │  Yük tipi: [Dropdown]  Filtrele│  │
│  └────────────────────────────────┘  │
├──────────────────────────────────────┤
│  [Mevcut] [Aktif] [Tamamlanan]      │  ← Tab bar
├──────────────────────────────────────┤
│                                       │
│  ┌────────────────────────────┐      │
│  │ İstanbul → Ankara          │      │  ← Yeni kart tasarımı
│  │ 📦 Tekstil • 22 ton • TIR  │      │
│  │ ⬤ 2 teklif    ₺15.000-18.000│     │
│  └────────────────────────────┘      │
│                                       │
│  ┌────────────────────────────┐      │
│  │ İzmir → Konya              │      │
│  │ 🥶 Soğuk Zincir • 8 ton    │      │
│  │ ⬤ 5 teklif    ₺8.000-12.000│      │
│  └────────────────────────────┘      │
│                              ↓      │
└──────────────────────────────────────┘
```

### 2.2. Her Zaman Görünür Filtre Barı

**Konum:** AppBar'ın hemen altında, scroll'dan bağımsız sabit
**Yükseklik:** 120px (3 satır)
**İçerik:**

```
Satır 1: "📍 Nereden" + "→" + "📍 Nereye" (yatay, yanyana)
Satır 2: "📦 Yük tipi" dropdown + "🚛 Araç tipi" dropdown
Satır 3: [Filtrele] butonu (accent variant, tam genişlik değil, 50% genişlik)
```

**Davranış:**
- Scroll ederken kaybolmaz, sabit kalır (sticky header)
- "Nereden" ve "Nereye" alanları dokununca şehir seçici açılır
- Seçili şehirler chip olarak görünür

### 2.3. Şehir Seçici (City Picker) — YENİ BİLEŞEN

**Mevcut:** 81 öğeli dropdown — kullanıcı dostu değil.
**Yeni:** Özel bir şehir seçici sheet/bottom sheet.

```
┌──────────────────────────────┐
│  Çıkış şehri seç            │  ← Başlık
├──────────────────────────────┤
│  🔍 İl ara...               │  ← TextField (büyük, 17px)
├──────────────────────────────┤
│  📍 Son kullanılanlar        │  ← İsteğe bağlı
│  [İstanbul] [Ankara] [İzmir] │
├──────────────────────────────┤
│  📍 Bölgeye göre             │
│  Marmara ›                   │  ← Bölge başlığı (genişletilebilir)
│  İstanbul ✓                  │
│  Bursa                       │
│  Kocaeli                     │
│  ...                         │
│  Ege ›                       │  ← Başka bölge (scroll ile ulaş)
│  Akdeniz ›                   │
│  İç Anadolu ›                │
│  Karadeniz ›                 │
│  Doğu Anadolu ›              │
│  Güneydoğu ›                 │
├──────────────────────────────┤
│  [Temizle]          [Seç]    │
└──────────────────────────────┘
```

**Bölge Gruplaması (Türkiye 7 Bölge):**

| Bölge | İller |
|---|---|
| Marmara | İstanbul, Bursa, Kocaeli, Balıkesir, Tekirdağ, Çanakkale, Edirne, Kırklareli, Yalova, Sakarya, Bilecik |
| Ege | İzmir, Manisa, Aydın, Denizli, Muğla, Afyonkarahisar, Kütahya, Uşak |
| Akdeniz | Antalya, Mersin, Adana, Hatay, Isparta, Burdur, Kahramanmaraş, Osmaniye |
| İç Anadolu | Ankara, Konya, Kayseri, Eskişehir, Sivas, Kırşehir, Nevşehir, Niğde, Aksaray, Karaman, Kırıkkale, Yozgat, Çankırı |
| Karadeniz | Samsun, Trabzon, Ordu, Giresun, Rize, Artvin, Sinop, Kastamonu, Bartın, Karabük, Zonguldak, Düzce, Bolu, Çorum, Amasya, Tokat, Gümüşhane, Bayburt |
| Doğu Anadolu | Erzurum, Van, Malatya, Elazığ, Erzincan, Ağrı, Kars, Muş, Bitlis, Bingöl, Hakkari, Ardahan, Iğdır, Tunceli |
| Güneydoğu | Gaziantep, Diyarbakır, Şanlıurfa, Mardin, Adıyaman, Batman, Siirt, Şırnak, Kilis |

**Animasyon:**
- Açılırken: slide up + fade (400ms)
- Bölge genişlerken: AnimatedCrossFade (300ms)
- Şehir seçince: hafif scale (1.0 → 1.05 → 1.0)

### 2.4. Aktif Filtre Chip'leri

Filtre seçiliyken, sonuçların üstünde chip olarak göster:

```
[İstanbul ×] [Ankara ×] [Tekstil ×] [Temizle]
```

- Her chip'te × işareti var — tıklayınca o filtre kalkar
- "Temizle" chip'i tüm filtreleri sıfırlar
- Chip'ler yatay scroll edilebilir (Horizontal scroll)
- Chip animasyonu: girerken fade + slide, çıkarken fade + scale

---

## 3. Filtreleme Sistemi

### 3.1. JobFilter Model Güncellemesi

Mevcut `JobFilter` alanları:
```
originCity, destinationCity, minWeight, maxWeight, cargoType, trailerType
```

Yeni eklenmesi gerekenler:
```
bölgeFiltreleme: String? (bölge adı)  // Bölgeye göre filtre
sortBy: JobSortBy (tarih/fiyat/weight)
sortOrder: SortOrder (artan/azalan)
```

```dart
class JobFilter {
  const JobFilter({
    this.originCity,
    this.destinationCity,
    this.originRegion,    // YENİ
    this.destinationRegion, // YENİ
    this.minWeight,
    this.maxWeight,
    this.cargoType,
    this.trailerType,
    this.sortBy = JobSortBy.date,  // YENİ
    this.sortOrder = SortOrder.descending, // YENİ
  });

  // ... mevcut alanlar
  final String? originRegion;
  final String? destinationRegion;
  final JobSortBy sortBy;
  final SortOrder sortOrder;
}

enum JobSortBy { date, price, weight }
enum SortOrder { ascending, descending }
```

### 3.2. Filter State Management

```dart
@riverpod
class JobFilterNotifier extends _$JobFilterNotifier {
  @override
  JobFilter build() => const JobFilter();

  void setOriginCity(String? city) { ... }
  void setDestinationCity(String? city) { ... }
  void setCargoType(String? type) { ... }
  void setTrailerType(String? type) { ... }
  void setOriginRegion(String? region) { ... }  // YENİ
  void setDestinationRegion(String? region) { ... } // YENİ
  void setSortBy(JobSortBy sortBy) { ... }  // YENİ
  void setSortOrder(SortOrder order) { ... }  // YENİ
  void clear() => state = const JobFilter();
}
```

### 3.3. Filtre Query Parametreleri

URL'de filtreleri taşı:
```
/jobs?origin=İstanbul&destination=Ankara&cargo=tekstil&sort=price
```

Böylece:
- Paylaşılabilir link
- Geri gelince filtre korunur
- Deep linking desteklenir

### 3.4. Shipper için Filtre Farkı

Shipper kendi ilanlarını görür — filtreye ihtiyacı daha az.
Ama yine de küçük bir toggle eklenebilir:
```
[Tümü] [Aktif] [Tamamlanan] [İptal]
```

Bu dört chip yatay sıralanır. Seçili olan navy800 dolu, diğerleri boş.

---

## 4. İlan Kartı Tasarımı (JobCard)

### 4.1. Mevcut Kartın Sorunları

- Rota dikey sıralı (başlangıç → çizgi → bitiş) — fazla yer kaplıyor
- Bütçe bilgisi sağ üstte küçük — fark edilmiyor
- Kart yüksekliği 200px+ — ekranda sadece 2-3 kart görünüyor
- Öncelikli işler için ayrı bir görsel işaret yok

### 4.2. Yeni Kart Tasarımı

```dart
class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.onTap,
    this.offerCount,       // YENİ — teklif sayısı
    this.compact = false,  // YENİ — dar mod
  });
```

**Layout (compact=false — varsayılan):**

```
┌────────────────────────────────────┐
│ 🔵 Açık              ⏰ 2 saat önce │  ← Status badge + zaman
├────────────────────────────────────┤
│ 📦 Tekstil Yükü — İstanbul → Ankara│  ← Title + rota (tek satır)
├────────────────────────────────────┤
│ ┌───────────────────────────────┐  │
│ │ İstanbul, Pendik              │  │  ← Rota görseli (compact)
│ │ ║                            │  │
│ │ ║                            │  │
│ ▼ Ankara, Çankaya              │  │
│ └───────────────────────────────┘  │
├────────────────────────────────────┤
│ ⚖️ 22 ton  📅 15 Haz  💰 15-18K ₺│  ← Meta satırı (3 sütun)
│                             2 teklif│
└────────────────────────────────────┘
```

**Yükseklik:** ~160px (mevcut 200+px'den daha kompakt)

**Layout (compact=true — liste görünümü):**

```
┌────────────────────────────────────┐
│ İstanbul → Ankara   Tekstil  22t  │
│ 15-18K ₺    🔵 Açık   2 teklif   │
└────────────────────────────────────┘
```

**Yükseklik:** ~72px — ekrana 5+ kart sığar

### 4.3. Rota Görseli (Mini Route)

`MiniRouteWidget` — yeni bileşen:

```dart
class MiniRouteWidget extends StatelessWidget {
  // İki nokta + düz çizgi
  // Başlangıç: dolu daire (navy800)
  // Bitiş: hedef işareti (amber500)
  // Çizgi: navy800, 2px, kesik değil
  // Arka plan: ink50
  // Radius: lg
}
```

```
●──────────────────────📍
İstanbul, Pendik        Ankara, Çankaya
```

Alternatif olarak kısa yol:
```
● İstanbul ══════════════ 📍 Ankara
```

### 4.4. Kart Animasyonları

Kart listeye girerken:
- Sıralı giriş: her kart arası 50ms gecikme
- Animasyon: fade (350ms) + slideY (begin: 0.03) + scaleY (0.97 → 1.0)
- Curve: decelerate

Karta dokununca:
- scale: 1.0 → 0.98 (100ms)
- Hafif elevation artışı

### 4.5. Demo Veri (Job Constants)

`JobConstants.turkishCities` zaten 81 ili içeriyor. Demo veride her ilden en az 1 ilan olmalı:

```dart
// demo_jobs_repository.dart içinde
static const _seedLocations = [
  ('İstanbul', 'Pendik', 'Ankara', 'Çankaya'),
  ('İzmir', 'Konak', 'Konya', 'Meram'),
  ('Ankara', 'Yenimahalle', 'İstanbul', 'Esenler'),
  ('Bursa', 'Osmangazi', 'Antalya', 'Muratpaşa'),
  ('Adana', 'Seyhan', 'Mersin', 'Akdeniz'),
  ('Trabzon', 'Ortahisar', 'Samsun', 'İlkadım'),
  ('Gaziantep', 'Şahinbey', 'Diyarbakır', 'Kayapınar'),
  ('Kayseri', 'Melikgazi', 'Konya', 'Selçuklu'),
  // ... toplam 15-20 seed ilan, farklı şehirlerden
];
```

---

## 5. İlan Detay Ekranı

### 5.1. Genel Yapı

Mevcut `JobDetailScreen` çok uzun (689 satır) ve karmaşık. Yeni yapı:

```
┌──────────────────────────────────────┐
│  ← Geri               ⋮ Menü        │  ← AppBar
├──────────────────────────────────────┤
│  🔵 Açık · 15 Haz 2026              │  ← Status badge + tarih
├──────────────────────────────────────┤
│  📦 Tekstil Yükü                     │  ← Title (headlineSmall, 20px)
│  İstanbul → Ankara                   │  ← Rota (büyük)
├──────────────────────────────────────┤
│  ┌──────────────────────────────┐    │
│  │  ● İstanbul, Pendik          │    │  ← Route card (daha büyük)
│  │  ║  ~450 km                  │    │     Mesafe bilgisi (yaklaşık)
│  │  ║                           │    │
│  │  📍 Ankara, Çankaya          │    │
│  └──────────────────────────────┘    │
├──────────────────────────────────────┤
│  📋 Yük Bilgileri                    │  ← Section header
│  ┌──────────────────────────────┐   │
│  │ Ağırlık   : 22 ton           │   │  ← Key-value pair
│  │ Hacim     : 45 m³            │   │
│  │ Kasa      : Tenteli          │   │
│  │ Açıklama  : Paletli, koli    │   │
│  └──────────────────────────────┘   │
├──────────────────────────────────────┤
│  💰 Bütçe Bilgisi                    │
│  ┌──────────────────────────────┐   │
│  │ Min : ₺15.000                │   │  ← Büyük rakamlar, bold
│  │ Maks: ₺18.000                │   │
│  │                          ↗   │   │
│  └──────────────────────────────┘   │
├──────────────────────────────────────┤
│  💬 Teklifler (Carrier için)         │  ← Varsa göster
│  ┌──────────────────────────────┐   │
│  │ Ali Nakliyat                 │   │  ← OfferCard (küçük)
│  │ ★★★★☆ ₺16.500               │   │
│  └──────────────────────────────┘   │
├──────────────────────────────────────┤
│  📞 Yükveren (teklif kabul edilince) │  ← Gizli/göster
└──────────────────────────────────────┘
```

### 5.2. Sabit Bottom Bar

Her zaman görünür, scroll'dan bağımsız:

```
┌──────────────────────────────────────┐
│  [💬 Mesaj Gönder] [💰 Teklif Ver]  │  ← Carrier için
│         veya                         │
│  [📋 Teklifleri Gör]               │  ← Shipper için
└──────────────────────────────────────┘
```

**Carrier:** İlan açıksa "Teklif Ver" butonu amber500 accent variant
**Shipper:** "Teklifleri Gör" butonu navy800 primary

---

## 6. Teklif Akışı (Carrier)

### 6.1. Mevcut Akışın Sorunları

1. Teklif vermek için sheet açılıyor — sheet'te ayrıca job özeti var (tekrar)
2. Fiyat + mesaj iki ayrı alan — bazen mesaj gereksiz
3. Hiçbir öneri/ipucu yok — "Ne kadar teklif vermeliyim?"
4. Sheet kapanınca "Teklifin gönderildi" snackbar'ı — kolay kaçırılır

### 6.2. Yeni Teklif Akışı

#### Adım 1: İlanı Gör (JobDetail)
Kullanıcı ilanı detaylı inceler. Rota, yük bilgisi, bütçe aralığı.

#### Adım 2: Teklif Ver (Bottom Sheet)
Aşağıdan açılan sheet. Mevcut olandan farkları:

```
┌──────────────────────────────┐
│  💰 Teklif Ver               │
├──────────────────────────────┤
│  İstanbul → Ankara           │  ← Minimal özet (kart yok, sadece rota)
│  📦 Tekstil • 22 ton         │
│  💰 Bütçe: ₺15K – ₺18K      │
├──────────────────────────────┤
│  Teklif Fiyatın              │
│  ┌──────────────────────┐    │
│  │ ₺ 16.500             │    │  ← Büyük input, otomatik focus, klavye açık
│  └──────────────────────┘    │
│                              │
│  Önerilen: ₺15.000 - ₺18.000│  ← Gri ipucu (bütçe aralığı)
│                              │
│  ┌──────────────────────┐    │
│  │ Mesaj (opsiyonel)    │    │  ← İsteğe bağlı
│  └──────────────────────┘    │
├──────────────────────────────┤
│  [🚛 Teklif Ver]            │  ← amber500 accent
│  Komisyon: ₺0 (sıfır!)      │
└──────────────────────────────┘
```

#### Adım 3: Başarı Animasyonu
Sheet kapanır, ekranda bir başarı animasyonu gösterilir:

```
┌──────────────────────────────┐
│                              │
│         🎉                   │  ← Checkmark animasyonu
│                              │
│    Teklifin Gönderildi!      │
│                              │
│  ₺16.500 — İstanbul → Ankara│
│                              │
│  [Tamam]                     │
└──────────────────────────────┘
```

**Animasyon:**
1. Sheet aşağı kayar (300ms)
2. Ekranın ortasında checkmark döner (scale 0 → 1, 500ms, spring)
3. Metin belirir (fade, 300ms)
4. Auto-close: 2 saniye sonra kendiliğinden kaybolur

### 6.3. Teklif Geçmişi (My Offers)

Nakliyecinin verdiği tüm teklifler:

```
┌──────────────────────────────────────┐
│  ← Tekliflerim                       │
├──────────────────────────────────────┤
│  [Bekleyen] [Kabul] [Red] [İptal]   │  ← Tab/filtre chip
├──────────────────────────────────────┤
│                                       │
│  ┌──────────────────────────────┐   │
│  │ İstanbul → Ankara            │   │  ← OfferCard
│  │ ₺16.500 · 🟡 Bekliyor       │   │
│  │ 2 saat önce                  │   │
│  └──────────────────────────────┘   │
│                                       │
│  ┌──────────────────────────────┐   │
│  │ İzmir → Konya                │   │
│  │ ₺9.000 · 🟢 Kabul Edildi     │   │
│  │ 1 gün önce                   │   │
│  └──────────────────────────────┘   │
└──────────────────────────────────────┘
```

**OfferCard güncellemesi:**
```dart
class OfferCard extends ConsumerWidget {
  // jobTitle, originCity → destinationCity, price, status, createdAt
  // Status badge: pending=amber500, accepted=green600, rejected=red600
  // Card: tıklanabilir → job detail'e gider
}
```

---

## 7. Teklif Yönetimi (Shipper)

### 7.1. Gelen Teklifler Ekranı

Shipper, ilan detayında "Teklifleri Gör" dediğinde:

```
┌──────────────────────────────────────┐
│  ← İstanbul → Ankara   💰 3 teklif  │
├──────────────────────────────────────┤
│  Sırala: [Fiyat ↑] [Puan ↓] [Tarih] │  ← Chip group
├──────────────────────────────────────┤
│                                       │
│  ┌──────────────────────────────┐   │
│  │ 🚛 Ali Nakliyat              │   │  ← OfferCard (geniş)
│  │ ★★★★☆  ★ 4.8                │   │
│  │ 142 tamamlanan iş           │   │
│  │ 📄 "20 yıllık firma, 1 günde│   │
│  │    teslim garantisi"        │   │
│  │ ════════════════════════    │   │
│  │ 💰 ₺16.500                  │   │  ← Büyük fiyat
│  │ 💵 ₺0 komisyon              │   │
│  │ [Reddet]     [Kabul Et 🟢]  │   │  ← İki buton
│  └──────────────────────────────┘   │
│                                       │
│  ┌──────────────────────────────┐   │
│  │ 🚛 Mehmet Kardeşler Lojistik │   │
│  │ ★★★☆☆  ★ 3.2                │   │
│  │ 28 tamamlanan iş            │   │
│  │ 📄 "Uygun fiyat, hızlı yük" │   │
│  │ ════════════════════════    │   │
│  │ 💰 ₺15.200                  │   │
│  │ [Reddet]     [Kabul Et 🟢]  │   │
│  └──────────────────────────────┘   │
└──────────────────────────────────────┘
```

### 7.2. Kabul Onay Dialog'u

"Kabul Et" tıklanınca:

```
┌──────────────────────────────┐
│  ✅ Teklifi Kabul Et         │
├──────────────────────────────┤
│  Ali Nakliyat firmasının     │
│  ₺16.500 teklifini onaylıyor│
│  musun?                      │
│                              │
│  Bu işlem geri alınamaz.    │
│                              │
│  [İptal]    [Evet, Kabul Et] │
└──────────────────────────────┘
```

### 7.3. Kabul Sonrası

- Shipper: "Operasyon başladı!" sayfasına yönlendirilir
- Carrier: Bildirim alır ("Teklifin kabul edildi!")
- İlan durumu: `open` → `offer_accepted`
- Mesajlaşma kilidi açılır

---

## 8. Demo Veri Güncellemeleri

### 8.1. Yeni Seed İlanlar

DemoJobsRepository'a eklenecek:

```dart
final _cities = JobConstants.turkishCities;
final _cargoTypes = JobConstants.cargoTypes;

// 15 farklı şehir çiftinden ilan
final _seedJobs = [
  ('İstanbul', 'Pendik', 'Ankara', 'Çankaya', 'Tekstil', 22),
  ('İzmir', 'Konak', 'Konya', 'Meram', 'Gıda', 8),
  ('Ankara', 'Yenimahalle', 'İstanbul', 'Esenler', 'Genel Yük', 18),
  ('Bursa', 'Osmangazi', 'Antalya', 'Muratpaşa', 'Otomotiv', 12),
  ('Adana', 'Seyhan', 'Mersin', 'Akdeniz', 'Tarım Ürünü', 25),
  ('Trabzon', 'Ortahisar', 'Samsun', 'İlkadım', 'Soğuk Zincir', 6),
  ('Gaziantep', 'Şahinbey', 'Diyarbakır', 'Kayapınar', 'Tekstil', 20),
  ('Kayseri', 'Melikgazi', 'Konya', 'Selçuklu', 'İnşaat Malzemesi', 28),
  ('Antalya', 'Kepez', 'İstanbul', 'Kartal', 'Gıda', 10),
  ('Samsun', 'Atakum', 'Ankara', 'Altındağ', 'Genel Yük', 15),
  ('Diyarbakır', 'Bağlar', 'İzmir', 'Bornova', 'Tarım Ürünü', 20),
  ('Kocaeli', 'Gebze', 'Bursa', 'Nilüfer', 'Otomotiv', 14),
  ('Mersin', 'Yenişehir', 'Gaziantep', 'Şehitkamil', 'Kimyasal', 16),
  ('Eskişehir', 'Tepebaşı', 'Antalya', 'Konyaaltı', 'Mobilya', 9),
  ('İstanbul', 'Tuzla', 'İzmir', 'Çiğli', 'Beyaz Eşya', 24),
];
```

---

## 9. Animasyonlar ve Geçişler

### 9.1. Sayfa Açılış Animasyonu (Staggered)

İlanlar sayfası açılırken:

```
0ms:    AppBar fade
100ms:  Filtre barı (slide down + fade, 350ms)
200ms:  Tab bar (fade)
300ms:  İlk kart (fade + slideY + scaleY, 400ms)
360ms:  İkinci kart
420ms:  Üçüncü kart
...
```

### 9.2. Filtre Uygulama Animasyonu

Filtre seçilip "Filtrele" tıklanınca:
1. Eski kartlar: fadeOut (200ms) + scale (0.8)
2. Yeni kartlar: fadeIn + slideY (300ms, staggered)
3. Chip bar: slide down (200ms)

### 9.3. Şehir Seçici Animasyonu

Bottom sheet açılırken:
1. Arka plan kararır: 0 → 0.4 (300ms)
2. Sheet yukarı kayar: 400ms, decelerate curve
3. Arama kutusu otomatik fokus: 500ms sonra
4. Şehir listesi staggered: her öğe arası 20ms

### 9.4. Teklif Verme Akışı

1. Sheet açılır (400ms, decelerate)
2. Fiyat input'u otomatik fokus (300ms)
3. "Teklif Ver" tıklanınca: buton loading'e döner (200ms)
4. Başarı: sheet kaybolur (300ms), checkmark animasyonu (500ms spring)
5. Auto-close: 2 saniye

### 9.5. Kabul Animasyonu

1. Dialog açılır: scale 0.9 → 1.0 (300ms spring)
2. "Kabul Et" tıklanınca: dialog scale -> 0.8 + fadeOut (200ms)
3. İlan otomatik ship akışına yönlenir

---

## 10. Uygulama Adımları

### Adım 1: JobFilter Model Güncellemesi

**Dosyalar:**
- `lib/features/jobs/data/models/job_post.dart`
- `lib/features/jobs/presentation/controllers/jobs_controller.dart`

**Yapılacaklar:**
- [ ] `JobFilter`'a `originRegion`, `destinationRegion`, `sortBy`, `sortOrder` ekle
- [ ] `JobSortBy` ve `SortOrder` enum'larını oluştur
- [ ] `JobFilterNotifier`'a yeni metotlar ekle
- [ ] `copyWith`'i güncelle
- [ ] `flutter analyze` kontrol

### Adım 2: City Picker Bileşeni

**Yeni dosya:** `lib/core/widgets/app_city_picker.dart`
**Referans dosyaları:** `job_constants.dart`, `app_bottom_sheet.dart`

**Yapılacaklar:**
- [ ] `AppCityPicker.show(context)` statiği
- [ ] Bölge gruplaması (`_regionCities` map)
- [ ] Arama kutusu + "Son kullanılanlar"
- [ ] Bölge genişletme animasyonu
- [ ] Şehir seçim geri bildirimi
- [ ] `flutter analyze` kontrol

### Adım 3: Mini Route Görseli

**Yeni dosya:** `lib/core/widgets/mini_route_widget.dart`

**Yapılacaklar:**
- [ ] `MiniRouteWidget` bileşeni
- [ ] İki nokta + çizgi + başlangıç/bitiş ikonları
- [ ] Compact ve normal mod
- [ ] `flutter analyze` kontrol

### Adım 4: Filtre Barı

**Dosya:** `lib/core/widgets/app_filter_bar.dart` — **YENİ**

**Yapılacaklar:**
- [ ] Sticky header widget
- [ ] Şehir seçim alanları (City Picker çağrısı)
- [ ] Dropdown'lar (kargo tipi, araç tipi)
- [ ] Filtrele butonu
- [ ] Aktif filtre chip'leri
- [ ] `flutter analyze` kontrol

### Adım 5: Yeni JobCard

**Dosya:** `lib/features/jobs/presentation/widgets/job_card.dart`

**Yapılacaklar:**
- [ ] Kart layout değişikliği (mini route, compact mod)
- [ ] Meta satırı (3 sütun: ağırlık, tarih, fiyat)
- [ ] Teklif sayısı göstergesi
- [ ] Compact mod
- [ ] `flutter analyze` kontrol

### Adım 6: JobsListScreen Güncellemesi

**Dosya:** `lib/features/jobs/presentation/screens/jobs_list_screen.dart`

**Yapılacaklar:**
- [ ] Filtre barını AppBar altına ekle (sticky)
- [ ] Carrier için "Mevcut" tab'ında city picker entegrasyonu
- [ ] Staggered giriş animasyonları
- [ ] Filtre uygulama animasyonu
- [ ] `flutter analyze` kontrol

### Adım 7: JobDetailScreen Güncellemesi

**Dosya:** `lib/features/jobs/presentation/screens/job_detail_screen.dart`

**Yapılacaklar:**
- [ ] Route card'ı büyüt (MiniRouteWidget)
- [ ] Yük bilgileri section'ı
- [ ] Bütçe bilgisi (büyük rakamlar)
- [ ] Sabit bottom bar (Mesaj + Teklif Ver)
- [ ] Staggered section girişleri
- [ ] `flutter analyze` kontrol

### Adım 8: CreateOfferSheet Güncellemesi

**Dosya:** `lib/features/offers/presentation/screens/create_offer_sheet.dart`

**Yapılacaklar:**
- [ ] Minimal job özeti
- [ ] Büyük fiyat input'u (otomatik fokus)
- [ ] Önerilen fiyat aralığı ipucu
- [ ] Başarı dialog'u (onay animasyonu)
- [ ] `flutter analyze` kontrol

### Adım 9: OfferCard Güncellemesi

**Dosya:** `lib/features/offers/presentation/widgets/offer_card.dart`

**Yapılacaklar:**
- [ ] Carrier adı + puan + tamamlanan iş sayısı
- [ ] Fiyat büyük gösterimi
- [ ] Kabul/Red butonları (Shipper için)
- [ ] Status badge (pending/accepted/rejected)
- [ ] `flutter analyze` kontrol

### Adım 10: Demo Veri Güncellemesi

**Dosya:** `lib/features/jobs/data/repositories/demo_jobs_repository.dart`
**Dosya:** `lib/core/demo/demo_store.dart`

**Yapılacaklar:**
- [ ] 15 farklı şehir çifti ekle
- [ ] Her ilana teklif sayısı bilgisi ekle
- [ ] Demo veride farklı kargo tipleri kullan
- [ ] `flutter analyze` kontrol

### Adım 11: Filtre Query Parametreleri

**Dosya:** `lib/core/routing/app_router.dart` (JobsListScreen route)

**Yapılacaklar:**
- [ ] URL'den filtre parametrelerini oku
- [ ] JobFilter'ı query'den başlat
- [ ] Filtre değişince URL güncelle
- [ ] `flutter analyze` kontrol

### Adım 12: Son Test

- [ ] `flutter analyze` — 0 error, 0 warning
- [ ] Demo modda tüm ekranları gez
- [ ] Filtreleme çalışıyor mu test et
- [ ] Teklif verme akışı çalışıyor mu test et
- [ ] City picker çalışıyor mu test et

---

## 📐 Toplam Dosya Değişiklik Özeti

| İşlem | Dosya Sayısı |
|---|---|
| Yeni dosya (city picker, filter bar, mini route) | 3 |
| Güncellenecek dosya (job model, controller, card, screen) | 8 |
| Güncellenecek demo veri | 2 |
| **Toplam** | **13** |

---

## ⏱️ Tahmini Süre

| Aşama | Süre |
|---|---|
| Adım 1: Model + Controller | 15 dk |
| Adım 2: City Picker | 25 dk |
| Adım 3: Mini Route Widget | 15 dk |
| Adım 4: Filtre Barı | 20 dk |
| Adım 5: Yeni JobCard | 20 dk |
| Adım 6: JobsListScreen | 25 dk |
| Adım 7: JobDetailScreen | 30 dk |
| Adım 8: CreateOfferSheet | 20 dk |
| Adım 9: OfferCard | 15 dk |
| Adım 10: Demo Veri | 15 dk |
| Adım 11: Query Parametreleri | 10 dk |
| Adım 12: Test | 15 dk |
| **Toplam** | **~3.5 saat** |

---

Bu plan tamamlandığında ARACIYOK'un ilanlar sekmesi şunlara sahip olacak:
- 81 il arasından **bölge bazlı hızlı seçim**
- **Her zaman görünür** sticky filtre barı
- **Mini route görseli** ile sezgisel kart tasarımı
- **Tek dokunuşla** teklif verme
- **Karşılaştırmalı** teklif yönetimi
- **Akıcı animasyonlar** ile premium his
