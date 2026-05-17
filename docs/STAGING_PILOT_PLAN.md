# ARACIYOK Staging Pilot Planı

## Pilot hedefi
Gerçek kullanıcılara açmadan önce operasyon, ödeme ve destek akışlarını
kontrollü bir kullanıcı grubu ile doğrulamak.

## Kapsam
- 10-20 yükveren
- 10-20 nakliyeci
- 1 admin + 1 destek rolü
- Staging Supabase + staging push + staging ödeme anahtarları

## Ölçümler
- Tekliften teslime tamamlama oranı
- Ortalama ilk yanıt süresi (mesajlaşma)
- Push teslim oranı
- Ödeme başarı oranı
- Sev-1/Sev-2 incident sayısı

## Test senaryoları
1. Yükveren ilan oluşturur, nakliyeci teklif verir, teklif kabul edilir.
2. Çift taraflı pickup onayı ve yola çıkış ilerler.
3. Teslim onayı sonrası ödeme durumu güncellenir.
4. Anlaşmazlık açılır ve admin panelinden görüntülenir.
5. Push bildirimi tıklaması doğru ekrana yönlendirir.

## Exit kriterleri
- Sev-1 hata yok.
- Kritik akışlarda başarı oranı >= %95.
- Ödeme ve admin ekranları stabil.
- Release checklist maddeleri tamamlandı.
