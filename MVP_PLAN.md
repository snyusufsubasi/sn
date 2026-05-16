# ARACIYOK Gerçek Yük Pazarı Native Demo MVP Planı

## Özet

ARACIYOK artık yalnızca ticari yük işi yapan kamyon/tır nakliyecileri ve yükverenler için tasarlanır. İki rol vardır: `Yükveren` ve `Nakliyeci`.

## Ürün Sözleşmesi

- Alt sekme sırası sabittir: `Anasayfa`, `İlanlar`, `Bildirimler`, `Mesajlar`, `Profil`.
- Nakliyeci anasayfası araç tipi, tonaj, kasa tipi, bölge ve yükleme şartlarına göre uygun yükleri önerir.
- İlanlar sekmesi bölge, komple/parsiyel, forklift, elle yükleme ve teklif durumu filtreleriyle çalışır.
- Yük ilanları palet, tonaj, hacim, araç tipi, kasa tipi, yükleme/boşaltma yöntemi ve tarih bilgisi içerir.
- Teklif kabul edilmeden açık adres, telefon, plaka ve mesajlaşma gizli kalır.
- Teklif kabulünden sonra operasyon akışı açılır.

## Operasyon Akışı

1. `Teklif Kabul Edildi`
2. `Yük Alındı`
3. `Yolda`
4. `Teslim Edildi`

`Yük Alındı` ve `Teslim Edildi` aşamaları iki tarafın onayıyla kesinleşir. `Yolda` aşaması nakliyeci bildirimiyle ilerler.

## Demo Veri

- Yük tipleri: paletli ürün, sanayi yükü, makine, inşaat malzemesi, tekstil kolisi, ambalaj malzemesi, gıda dışı ürün.
- Araç kapsamı: kamyon ve tır.
- Kasa tipleri: tenteli, açık kasa, kapalı kasa, frigorifik değil.
- Yükleme/boşaltma: forklift, transpalet, rampa, vinç sahada hazır, elle yükleme.
- Demo mod local seed/store kullanır ve Supabase'e yazmaz.

## Kabul Kriterleri

- Android build başarılı olur.
- Alt sekme sırası yeni sözleşmeye uyar.
- Konut taşıması çağrışımı kalmaz.
- Nakliyeci önerilen yükleri araç+rota+yük uyumuna göre görür.
- Nakliyeci filtreli ilan listesinde yük arayabilir.
- Yükveren teklif kabul edebilir.
- Kabul sonrası özel bilgiler ve mesajlaşma açılır.
- Yük alındı ve teslim edildi aşamaları çift taraflı onay durumlarını gösterir.
- Mojibake kalmaz.
