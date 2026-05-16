# AGENTS.md

Kısa ve öz ilerle.

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
