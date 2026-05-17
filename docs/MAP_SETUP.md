# Harita Kurulum Adımları (Faz 9)

Bu doküman canlı taşıma takibini aktive etmek için yapılması gerekenleri anlatır. Kod tarafı hazır; eksik olan API key ve native config.

## 1. Google Cloud Console

1. https://console.cloud.google.com → "Select a project" → **NEW PROJECT**
2. Proje adı: `araciyok`
3. **Billing aç** (kredi kartı şart, $200/ay ücretsiz kota verilir)
4. **APIs & Services** → **Library** → şu API'leri **Enable** et:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Directions API (opsiyonel — rota çizimi)
5. **APIs & Services** → **Credentials** → **+ CREATE CREDENTIALS** → **API key**
6. API key'i kopyala
7. (Opsiyonel ama önerilen) Key'e tıkla → **API restrictions** → "Restrict key" → yukarıdaki API'leri seç → Save
8. Prod için: **Application restrictions** → Android paketi + SHA-1, iOS bundle ID ekle. Dev'de şimdilik "None" bırakabilirsin.

## 2. Android

### `android/app/src/main/AndroidManifest.xml`

`<application>` tag'inin **içine** (en alta):

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

`<manifest>` tag'inin altına (en üst seviye):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### `android/app/build.gradle`

`minSdkVersion` minimum **21**.

## 3. iOS (Mac varsa)

### `ios/Runner/AppDelegate.swift`

Üste import:
```swift
import GoogleMaps
```

`didFinishLaunchingWithOptions` fonksiyonunun **en üstüne** (super çağrısından önce):
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

### `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Taşıma rotasını göstermek ve konumunu paylaşmak için konumuna ihtiyacımız var.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aktif taşıma sırasında konumunu yükverenle paylaşıyoruz.</string>
```

### `ios/Podfile`

Platform en az 12.0:
```ruby
platform :ios, '12.0'
```

`pod install`'dan sonra:
```bash
cd ios && pod install && cd ..
```

## 4. Test akışı

1. `flutter run` — Android cihaza/emülatöre
2. İki hesapla giriş yap (biri yükveren, biri nakliyeci)
3. Yükveren ilan açar → adres alanını **dolduracak ki koordinatlar olsun** (Faz 9.5: geocoding entegrasyonu eklenecek, şu an `origin_lat/lng` ve `destination_lat/lng` manuel girilebilir veya boş)
4. Nakliyeci teklif verir → yükveren kabul eder
5. Çift taraflı yük alma onayı → status `loaded` olur
6. **Bu noktada nakliyecinin telefonu her 30 saniyede bir konumunu DB'ye yazmaya başlar** (TrackingLifecycle otomatik)
7. Yükveren ilan detayına gider → **"Canlı Takip"** butonu görünür → harita ekranı açılır
8. Nakliyecinin konumu turuncu pin olarak görünür, hareket ettikçe polyline çizilir

## 5. Bilinen sınırlamalar (sonraki sprint'te düzelt)

- **Background location yok.** Uygulama background'a düşerse ping atmaz (Android Doze, iOS App Suspend). Tam çalışan background tracking için:
  - Android: `workmanager` veya `flutter_background_service` paketi + foreground notification
  - iOS: `Significant Location Changes` API + Background Modes "Location updates"
  - Bunlar ayrı bir sprint, store onayı sırasında özellikle dikkat edilmeli (privacy nutrition label vs.)

- **origin/destination koordinatları otomatik yok.** İlan oluşturulurken adresten enlem/boylam çıkarılması (geocoding) Faz 9.5 olarak ayrı eklenecek. Şu an `geocoding` paketi pubspec'te var ama kullanılmıyor.

- **Pinglerin geocoder etiketi yok.** Ping üzerine tıkladığında "Konya yakınlarında" gibi insan-okuyabilir adres göstermek için Geocoding API çağrısı eklenebilir (UX nice-to-have).

- **Maliyet kontrolü.** Google Maps Static API yerine SDK kullanıyoruz, her açılış ücretsiz quota'ya gider. Production'da kullanıcı başı günlük açılış sayısını sınırla veya cache mekanizması kur.

## 6. Common Issues

**"Google Maps Android API: Authorization failure"**: API key yanlış, key restriction'larında Android paketi/SHA-1 eşleşmiyor, veya billing kapalı.

**"PlatformException(channel-error)"**: `cd ios && pod install` çalıştırılmadı veya iOS minimum sürümü 12'den düşük.

**Harita siyah/gri**: API key var ama Maps SDK enable değil, veya key restrictions hatalı.

**Konum boş geliyor**: Cihaz GPS kapalı, izin verilmedi, veya emülatörde fake location ayarlı değil. Emülatörde "Extended Controls → Location" üzerinden manuel konum verebilirsin.

**Pin yok ama polyline çizili**: Ping var ama job.originLat/originLng null. İlan oluştururken bu alanlar girilmiş olmalı; ya da geocoding eklenmeli (TODO).

## 7. Sonraki adım (Faz 9.5 — sonradan)

İlan oluşturma ekranında `originAddress` girilince otomatik geocoding:

```dart
// pubspec'te geocoding zaten var
import 'package:geocoding/geocoding.dart';

final placemarks = await locationFromAddress(
  '${city}, ${district}, ${address}',
);
if (placemarks.isNotEmpty) {
  final lat = placemarks.first.latitude;
  final lng = placemarks.first.longitude;
  // input'a ekle
}
```
