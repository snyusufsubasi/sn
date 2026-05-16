# ARACIYOK

ARACIYOK, yükveren ile kamyon/tır nakliyecisini aracı olmadan buluşturan native mobil gerçek yük pazarı demo MVP projesidir.

## Güncel Yön

- Ana hedef: Android emulator üzerinde gerçek mobil uygulama demosu.
- Android: Kotlin, Jetpack Compose, Material 3.
- iOS: SwiftUI kaynak scaffold.
- Roller: yalnızca `Yükveren` ve `Nakliyeci`.
- Pazar modeli: nakliyeci teklif verir, yükveren kabul eder.
- Demo giriş kodu: `123456`.
- Flutter klasörleri eski prototip ve referans olarak durur; ana geliştirme `native/` altındadır.

## Ürün Odağı

- Konut taşıması odağı yoktur.
- Demo veriler kamyon/tır, paletli yük, sanayi yükü, makine, inşaat malzemesi ve parsiyel/komple yük etrafında döner.
- İlanlarda tonaj, hacim, palet/adet, kasa tipi, araç tipi, forklift/elle yükleme, çıkış-varış bölgesi ve tarih bilgileri bulunur.
- Kabul sonrası operasyon akışı: teklif kabul edildi, yük alındı, yolda, teslim edildi.
- `Yük Alındı` ve `Teslim Edildi` aşamaları çift taraflı onay ister.

## Alt Sekmeler

```text
Anasayfa - İlanlar - Bildirimler - Mesajlar - Profil
```

## Android Çalıştırma

Debug APK üret:

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK çıktısı:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Emulator veya Android cihaz bağlıysa kur:

```powershell
.\android\gradlew.bat -p native\android installDebug
```

## Demo Giriş

```text
Telefon: +90 532 000 00 01
Kod: 123456
```
