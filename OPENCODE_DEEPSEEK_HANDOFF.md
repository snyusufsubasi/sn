# OpenCode / DeepSeek Devam Dosyası

Bu dosya, Codex limiti biterse ARACIYOK projesine OpenCode + DeepSeek ile devam etmek için hazırlanmıştır.

## Kısa Talimat

Kısa ve öz ilerle. Gereksiz plan uzatma. Kod değişikliği gerekiyorsa uygula, doğrula, commit/push yap.

## Proje

- Ad: ARACIYOK
- Repo: `https://github.com/snyusufsubasi/sn`
- Yerel klasör: `C:\Users\snyus\Desktop\ARACIYOK`
- Branch: `main`
- Ana hedef: Android emulator üzerinde çalışan native mobil gerçek yük pazarı demo MVP
- Android: Kotlin, Jetpack Compose, Material 3
- iOS: SwiftUI scaffold, Windows'ta build doğrulanamaz
- Flutter: eski prototip/referans, yeni ana geliştirme değil

## Ürün Sözleşmesi

- Konut taşıması yok.
- Uygulama yalnızca ticari yük işi içindir.
- Roller sadece `Yükveren` ve `Nakliyeci`.
- Alt sekme sırası sabit: `Anasayfa`, `İlanlar`, `Bildirimler`, `Mesajlar`, `Profil`.
- Yük ilanları palet, tonaj, hacim, araç tipi, kasa tipi, forklift/elle yükleme ve rota bilgisi içermeli.
- Teklif kabul edilmeden açık adres, telefon, plaka ve mesajlaşma gizli kalmalı.
- Mesajlaşma teklif kabulünden sonra açılmalı.
- `Yük Alındı` ve `Teslim Edildi` çift taraflı onayla kesinleşmeli.
- Demo mod local deterministic seed/store kullanmalı ve Supabase'e yazmamalı.
- Production Supabase akışı bozulmamalı.
- Kullanıcıya görünen Türkçe metinlerde mojibake kalmamalı.

## Önemli Dosyalar

- Ajan kuralları: `AGENTS.md`
- Son durum: `CURRENT_STATE.md`
- Ürün planı: `MVP_PLAN.md`
- Yapılacaklar: `TODO.md`
- Devam notu: `HANDOFF.md`
- Native not: `native/README.md`
- Android proje: `native/android`
- Android Compose kaynakları: `native/android/app/src/main/java/com/araciyok/nativeapp`
- Demo state: `native/android/app/src/main/java/com/araciyok/nativeapp/data/DemoViewModel.kt`
- Modeller: `native/android/app/src/main/java/com/araciyok/nativeapp/model/DemoModels.kt`
- Ekranlar: `native/android/app/src/main/java/com/araciyok/nativeapp/ui/screens`
- Tema: `native/android/app/src/main/java/com/araciyok/nativeapp/ui/theme/AraciyokTheme.kt`
- Supabase migration: `supabase/migrations`
- Ortam kontrol script'i: `tool/check_mobile_env.ps1`

## Kurulu Araçlar

- GitHub CLI kalıcı girişli: `gh auth status`
- Supabase CLI: `C:\Users\snyus\tools\supabase\supabase.exe`
- Supabase proje ref: `ndmvpakioumtwefxguqd`
- Android SDK: `C:\Users\snyus\AppData\Local\Android\Sdk`
- Java: Android Studio JBR
- Emulator: `ARACIYOK_API35`
- Flutter/Dart kurulu ama ana geliştirme native altında.

Yeni terminalde şu komutlar çalışmalı:

```powershell
git status --short --branch
gh auth status
supabase --version
java -version
adb version
emulator -list-avds
sdkmanager --version
```

Tek komutluk kapsamlı kontrol:

```powershell
.\tool\check_mobile_env.ps1
```

## Doğrulama Komutları

Build:

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Emulator aç:

```powershell
emulator -avd ARACIYOK_API35
```

Kur:

```powershell
.\android\gradlew.bat -p native\android installDebug
```

Başlat:

```powershell
adb shell monkey -p com.araciyok.nativeapp -c android.intent.category.LAUNCHER 1
```

Crash kontrolü:

```powershell
adb logcat -d -t 300 | Select-String -Pattern "FATAL EXCEPTION|AndroidRuntime|com.araciyok.nativeapp"
```

## Son Doğrulanmış Durum

- `assembleDebug` başarılı.
- `installDebug` başarılı.
- `ARACIYOK_API35` emulator açıldı.
- `com.araciyok.nativeapp` kuruldu ve başlatıldı.
- Son log kontrolünde crash görünmedi.
- GitHub repo push edildi.
- Supabase connector proje listesini gördü.

## Sıradaki İşler

1. Yükveren için gerçek `Yeni Yük İlanı Oluştur` formu.
2. Nakliyeci profil düzenleme: araç tipi, tonaj, kasa tipi, bölge tercihleri.
3. İlan detayında teklif kabulü, özel bilgi açılması, mesajlaşma ve çift taraflı onay uçtan uca test.
4. Operasyon aksaklık/itiraz demo state'i.
5. Android UI polish: uzun metin taşması, kart yoğunluğu, filtre çipleri, 40+ kullanıcı için okunurluk.
6. GitHub Actions: native Android build ve APK artifact.
7. Supabase RLS/policy güvenlik denetimi.
8. Sonra Maps, OTP, push bildirim entegrasyonları.

## Çalışma Akışı

Her küçük değişiklikten sonra:

```powershell
.\android\gradlew.bat -p native\android assembleDebug
git status --short
git add .
git commit -m "Kısa açıklama"
git push
```

Generated dosyaları commit etme:

- `.env`
- `android/local.properties`
- `native/android/.gradle/`
- `native/android/.kotlin/`
- `native/android/app/build/`
- `supabase/.temp/`
- Flutter/IDE cache klasörleri

## DeepSeek İçin Başlangıç Promptu

```text
Bu klasör C:\Users\snyus\Desktop\ARACIYOK. Önce AGENTS.md, OPENCODE_DEEPSEEK_HANDOFF.md, CURRENT_STATE.md, MVP_PLAN.md, TODO.md ve HANDOFF.md dosyalarını oku. Proje ARACIYOK native Android gerçek yük pazarı demo MVP. Flutter eski referans; ana geliştirme native/android altında. Kısa ve öz ilerle. Her değişiklikten sonra .\android\gradlew.bat -p native\android assembleDebug çalıştır. Demo mod Supabase'e yazmasın. Kullanıcıya görünen Türkçe metinlerde bozuk karakter bırakma. Sıradaki işi TODO.md önceliklerine göre uygula, doğrula, commit/push yap.
```
