# ARACIYOK Native Demo

Bu klasör, gerçek yük pazarı odaklı native mobil demo MVP yüzeyini içerir.

## Android

Android demo Kotlin, Jetpack Compose ve Material 3 ile `native/android` altında çalışır. Ana hedef Android emulator veya bağlı Android cihazdır.

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Android emulator açıksa:

```powershell
.\android\gradlew.bat -p native\android installDebug
```

Demo giriş:

```text
Telefon: +90 532 000 00 01
Kod: 123456
```

## Ürün Sözleşmesi

- Roller: `Yükveren`, `Nakliyeci`.
- Kullanım alanı: kamyon/tır odaklı ticari yük pazarı.
- Alt sekmeler: `Anasayfa`, `İlanlar`, `Bildirimler`, `Mesajlar`, `Profil`.
- Mesajlaşma: teklif kabulünden sonra açılır.
- Gizlilik: adres, telefon ve plaka kabul öncesi gizli kalır.
- Operasyon: yük alındı ve teslim edildi aşamaları çift taraflı onay ister.
- Demo veri local çalışır ve Supabase'e yazmaz.

## iOS

SwiftUI demo kaynakları `native/ios/ARACIYOKDemo` altındadır. Windows ortamında Xcode build doğrulanamaz.
