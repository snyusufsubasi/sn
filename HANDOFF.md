# ARACIYOK Devam Notu

Bu klasörün güncel yönü native mobil demo MVP'dir. Flutter tarafı eski prototip/referans olarak durur; yeni ana geliştirme `native/` altında yapılır.

Bu dosya, Codex oturum limiti biterse OpenCode + DeepSeek veya başka bir ajanla devam edebilmek için ana devam notudur.

## Ana Kaynaklar

- Android demo: `native/android`
- Android ana ekran ve demo akış: `native/android/app/src/main/java/com/araciyok/nativeapp/MainActivity.kt`
- Android Compose ekranları: `native/android/app/src/main/java/com/araciyok/nativeapp/ui/screens`
- Android demo state/store: `native/android/app/src/main/java/com/araciyok/nativeapp/data/DemoViewModel.kt`
- Android domain modelleri: `native/android/app/src/main/java/com/araciyok/nativeapp/model/DemoModels.kt`
- iOS SwiftUI scaffold: `native/ios/ARACIYOKDemo`
- Ürün planı: `MVP_PLAN.md`
- Kısa yapılacaklar: `TODO.md`
- Native çalışma notu: `native/README.md`
- OpenCode/DeepSeek başlangıç notu: `OPENCODE_DEEPSEEK_HANDOFF.md`
- Tek komut ortam kontrolü: `tool/check_mobile_env.ps1`

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

## GitHub ve Araç Durumu

- Git repo kökü artık doğrudur: `C:\Users\snyus\Desktop\ARACIYOK`
- Remote: `https://github.com/snyusufsubasi/sn.git`
- Branch: `main`
- GitHub CLI kurulu ve kalıcı girişlidir: `gh auth status`
- Supabase CLI kurulu: `C:\Users\snyus\tools\supabase\supabase.exe`
- Supabase connector aktif proje: `ndmvpakioumtwefxguqd`
- Emulator profili: `ARACIYOK_API35`

Kontrol komutları:

```powershell
git status --short --branch
gh repo view snyusufsubasi/sn
supabase --version
adb devices
emulator -list-avds
```

Kapsamlı ortam kontrolü:

```powershell
.\tool\check_mobile_env.ps1
```

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

Uygulamayı başlat:

```powershell
adb shell monkey -p com.araciyok.nativeapp -c android.intent.category.LAUNCHER 1
```

## Son Not

Devam eden ajan önce `AGENTS.md`, `CURRENT_STATE.md`, `MVP_PLAN.md`, `TODO.md` ve `OPENCODE_DEEPSEEK_HANDOFF.md` dosyalarını okumalı. Kullanıcı kısa ve öz ilerlemeyi sever; plan uzatılacaksa doğrudan uygulanabilir kabul kriterleriyle yaz.
