# TODO

## Öncelik 1

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

## Bilinen Notlar

- Ana hedef Android native demo.
- Windows ortamında iOS build doğrulanamaz.
- Flutter proje eski prototip ve referans olarak duruyor.
