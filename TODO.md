# TODO

## Öncelik 1

- OpenCode/DeepSeek ile devam edilecekse önce `OPENCODE_DEEPSEEK_HANDOFF.md`, `AGENTS.md`, `CURRENT_STATE.md`, `MVP_PLAN.md` ve `HANDOFF.md` oku.
- `.\android\gradlew.bat -p native\android assembleDebug` komutunu her UI turundan sonra çalıştır.
- Emulator veya gerçek cihaz varsa `installDebug` ile görsel kontrol yap.
- Alt sekme metinlerini cihazda doğrula:
  - `Anasayfa`
  - `İlanlar`
  - `Bildirimler`
  - `Mesajlar`
  - `Profil`
- Nakliyeci anasayfasında araç+rota+yük uyumlu önerileri kontrol et.
- İlanlar sekmesinde bölge, komple/parsiyel, forklift ve elle yükleme filtrelerini kontrol et.
- Teklif kabulü, özel bilgi açılması, mesajlaşma ve çift taraflı onay akışını test et.
- Mojibake aramasını temiz tut.

## Öncelik 2

- Yeni yük ilanı oluşturma formunu gerçek alanlarla aç: tonaj, palet, hacim, kasa tipi, yükleme/boşaltma yöntemi, forklift bilgisi.
- Nakliyeci profil düzenleme ekranına araç tipi, tonaj, kasa ve bölge tercihleri ekle.
- Operasyon akışına itiraz/aksaklık bildirimi için demo state ekle.
- GitHub Actions ekle: native Android `assembleDebug` otomatik çalışsın ve APK artifact üretsin.
- Supabase migration/RLS denetimi yap; `anon`/`authenticated` politikalarını yük pazarı modeline göre güvenli hale getir.
- Google Maps, OTP ve push bildirim entegrasyonlarını ayrı feature branch'lerde bağla.

## OpenCode / DeepSeek Devam Sırası

1. Repo durumunu kontrol et: `git status --short --branch`.
2. Android build al: `.\android\gradlew.bat -p native\android assembleDebug`.
3. Emulator açıksa kur: `.\android\gradlew.bat -p native\android installDebug`.
4. Uygulamayı aç: `adb shell monkey -p com.araciyok.nativeapp -c android.intent.category.LAUNCHER 1`.
5. Yapılan değişikliği küçük commit olarak gönder: `git add .`, `git commit -m "..."`, `git push`.

## Bilinen Notlar

- Ana hedef Android native demo.
- Windows ortamında iOS build doğrulanamaz.
- Flutter proje eski prototip ve referans olarak duruyor.
- Demo mod Supabase'e yazmamalı.
- Açık adres, telefon ve plaka teklif kabulünden önce gizli kalmalı.
