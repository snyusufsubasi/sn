# ARACIYOK Devam Notu

Bu klasörün güncel yönü native mobil demo MVP'dir. Flutter tarafı eski prototip/referans olarak durur; yeni ana geliştirme `native/` altında yapılır.

## Ana Kaynaklar

- Android demo: `native/android`
- Android ana ekran ve demo akış: `native/android/app/src/main/java/com/araciyok/nativeapp/MainActivity.kt`
- iOS SwiftUI scaffold: `native/ios/ARACIYOKDemo`
- Ürün planı: `MVP_PLAN.md`
- Kısa yapılacaklar: `TODO.md`
- Native çalışma notu: `native/README.md`

## Ürün Kararı

- Uygulama adı: ARACIYOK
- Roller: `Yük Veren` ve `Nakliyeci`
- Alt sekmeler:
  - Yük Veren: `Ana Sayfa`, `İlanlarım`, `Mesajlar`, `Bildirimler`, `Profil`
  - Nakliyeci: `İşler`, `Tekliflerim`, `Mesajlar`, `Bildirimler`, `Profil`
- Demo OTP: `123456`
- Demo veri local çalışır; Supabase'e yazmaz.
- Production Supabase yapısı korunur.

## Temizlenenler

Şu an klasörden generated/cache/log dosyaları temizlendi:

- `.dart_tool`
- `build`
- `.idea`
- Flutter web server logları
- `.flutter-plugins-dependencies`
- `android/.gradle`
- `android/.kotlin`
- `native/android/.gradle`
- `native/android/.kotlin`
- `native/android/app/build`

Build çıktıları kaynak değildir. APK gerekiyorsa tekrar üret.

## Android Derleme

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Emulator veya cihaz varsa:

```powershell
.\android\gradlew.bat -p native\android installDebug
```

## Son Not

Git kökü bu makinede yanlışlıkla `C:\` olarak görünüyor. Bu yüzden bu klasörde commit/stage yapılmadı. Devam etmeden önce istenirse `C:\Users\snyus\Desktop\ARACIYOK` içinde ayrı ve temiz bir git deposu başlatılmalı.
