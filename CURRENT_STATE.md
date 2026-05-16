# ARACIYOK Current State

Bu dosya yeni sohbet penceresinde devam etmek için kısa ve net son durum kaydıdır.

## Son Ürün Kararı

ARACIYOK artık konut taşıması veya ev eşyası odaklı değildir. Ürün yalnızca ticari yük işi yapan `Yükveren` ve kamyon/tır odaklı `Nakliyeci` kullanıcıları içindir.

İki rol vardır:

- `Yükveren`
- `Nakliyeci`

Alt sekme sırası her iki rol için sabittir:

```text
Anasayfa - İlanlar - Bildirimler - Mesajlar - Profil
```

## Mevcut Uygulama Durumu

- Android native demo ana yüzeydir.
- Android kaynakları `native/android/app/src/main/java/com/araciyok/nativeapp` altındadır.
- Compose yapı modülerdir: `model`, `data`, `ui/theme`, `ui/components`, `ui/screens`.
- iOS SwiftUI kaynakları `native/ios/ARACIYOKDemo` altında aynı ürün yönüne hizalanmıştır.
- Flutter klasörleri eski prototip ve referans olarak durur; ana geliştirme `native/` altındadır.

## Gerçek Yük Pazarı Modeli

Demo modelinde yük ilanları şu alanları taşır:

- Yük tipi
- Komple/parsiyel bilgisi
- Tonaj
- Hacim
- Palet/adet
- Araç tipi
- Kasa tipi
- Yükleme ve boşaltma yöntemi
- Forklift var/yok
- Çıkış-varış şehir, ilçe ve bölge
- Açık adres
- Teklif ve operasyon durumu

Nakliyeci profili şu alanlara odaklanır:

- Kamyon veya tır
- Tonaj kapasitesi
- Kasa tipi
- Uygun bölgeler
- Plaka
- Belge durumu

## Operasyon Akışı

Pazar modeli tekliflidir: nakliyeci teklif verir, yükveren kabul eder.

Teklif kabulünden sonra:

1. `Teklif Kabul Edildi`
2. `Yük Alındı`
3. `Yolda`
4. `Teslim Edildi`

`Yük Alındı` ve `Teslim Edildi` aşamaları çift taraflı onay ister. `Yolda` aşaması nakliyeci bildirimiyle ilerler.

Teklif kabulünden önce açık adres, telefon, plaka ve mesajlaşma gizlidir.

## Son Doğrulama

Android build başarılı:

```powershell
.\android\gradlew.bat -p native\android assembleDebug
```

APK:

```text
native/android/app/build/outputs/apk/debug/app-debug.apk
```

Emulator adı:

```text
ARACIYOK_API35
```

Son görsel kontrolde Nakliyeci anasayfası açıldı ve şu ekran doğrulandı:

- Başlık: `Nakliyeci Paneli`
- Anasayfa kartı: `Aracınıza uygun yükler`
- Alt sekmeler: `Anasayfa`, `İlanlar`, `Bildirimler`, `Mesajlar`, `Profil`
- Önerilen yük kartları gerçek yük verisi gösteriyor.

## Sonraki En Mantıklı Adımlar

1. Yükveren için gerçek `Yeni Yük İlanı Oluştur` formu ekle.
2. Nakliyeci profil düzenleme ekranına araç tipi, tonaj, kasa tipi ve bölge tercihleri ekle.
3. Operasyon akışında itiraz/aksaklık bildirimi demo state'i ekle.
4. İlan detayında teklif kabulü, yük alındı onayı ve teslim onayını emulator üzerinde uçtan uca gez.
5. Android UI polish turu yap: kart yoğunluğu, uzun metin taşması, filtre çipleri ve operasyon durum kartları.
