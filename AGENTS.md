# AGENTS.md

Kısa ve öz ilerle.

OpenCode, DeepSeek veya başka bir ajan bu klasörde devam ediyorsa önce şunları oku:

1. `OPENCODE_DEEPSEEK_HANDOFF.md`
2. `CURRENT_STATE.md`
3. `MVP_PLAN.md`
4. `TODO.md`
5. `HANDOFF.md`

## Proje Yönü

ARACIYOK için güncel karar: **native mobil gerçek yük pazarı demo MVP**.

- Ana fikir: yükveren ile kamyon/tır nakliyecisini aracı olmadan buluşturmak.
- Kullanım alanı: konut taşıması değil, yalnızca ticari yük işi.
- Ana hedef platform: Android emulator.
- Android teknoloji: Kotlin, Jetpack Compose, Material 3.
- iOS teknoloji: SwiftUI.
- Roller: sadece `Yükveren` ve `Nakliyeci`.
- Alt sekmeler sabit sıra: `Anasayfa`, `İlanlar`, `Bildirimler`, `Mesajlar`, `Profil`.
- Flutter klasörleri eski prototip/referans olarak durur; yeni ana geliştirme `native/` altında yapılır.

## Çalışma Kuralları

- Kullanıcıya görünen tüm metinler düzgün Türkçe olmalı.
- Mojibake, bozuk karakter ve soru işaretine dönmüş Türkçe harf bırakma.
- Demo veri konut taşıması odağı taşımamalı.
- Yük ilanları palet, tonaj, kasa tipi, araç tipi, forklift/elle yükleme ve rota bilgisi içermeli.
- Mesajlaşma teklif kabulünden sonra açılmalı.
- Açık adres, telefon ve plaka teklif kabulünden önce gizli kalmalı.
- `Yük Alındı` ve `Teslim Edildi` aşamaları çift taraflı onayla kesinleşmeli.
- Demo mod Supabase'e yazmamalı; local deterministic seed/store kullanmalı.
- Production Supabase akışı bozulmamalı.

## Doğrulama

Android native demo için:

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Emulator yoksa bunu açıkça belirt.

GitHub/Supabase ortam kontrolü:

```powershell
git status --short --branch
gh auth status
supabase --version
adb devices
```

## Cursor Cloud specific instructions

### Environment

- **JAVA_HOME**: `/usr/lib/jvm/java-21-openjdk-amd64` (JDK 21, compatible with the project's JDK 17 target).
- **ANDROID_HOME**: `/opt/android-sdk` — contains cmdline-tools, platform 36, build-tools 36, platform-tools.
- These are set in `~/.bashrc`; the update script also exports them.

### Building (Linux)

The native Android project has no Gradle wrapper of its own. Use the Flutter-era wrapper:

```bash
./android/gradlew -p native/android assembleDebug
```

APK output: `native/android/app/build/outputs/apk/debug/app-debug.apk`

### Lint & Tests

```bash
./android/gradlew -p native/android lintDebug
./android/gradlew -p native/android testDebugUnitTest
```

Pre-existing lint errors exist (2 `NewApi` errors from `java.time.LocalDate` usage on minSdk 24). No unit test sources exist yet — `testDebugUnitTest` succeeds with `NO-SOURCE`.

### Running on Emulator

Cloud VMs have no Android emulator or display. APK can only be built, not installed/run. State this explicitly when asked to demonstrate the running app.

### Supabase

Demo mode is fully local (no Supabase writes). Supabase CLI is not installed and not required for the native demo build. The `supabase/` directory contains SQL migrations for the production backend only.

### Flutter (Legacy)

The root `pubspec.yaml` and `android/` directory belong to the legacy Flutter prototype. Do not attempt to build them — they require Flutter SDK and a `local.properties` file, neither of which is present.
