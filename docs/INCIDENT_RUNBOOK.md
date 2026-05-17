# ARACIYOK Incident Runbook

## Seviyeler
- **Sev-1:** Login/ödeme/taşıma akışı tamamen çalışmıyor.
- **Sev-2:** Kritik olmayan ama kullanıcıyı etkileyen kısmi bozulma.
- **Sev-3:** Görsel/regresyon veya düşük etkili hata.

## İlk 15 dakika
- Incident sahibi atanır (tek kişi).
- Etkilenen alan belirlenir: `mobile`, `admin`, `supabase`, `push`.
- Son deploy ve migration listesi çıkarılır.
- Gerekirse yeni deploy durdurulur (change freeze).

## Tanı adımları
- Mobil: son sürüm crash logları, auth/route hataları.
- Supabase: son migration, RLS/RPC değişiklikleri, function logları.
- Push: `send-push` logları, webhook 401/500 oranı.
- Ödeme: `payments`, `payment_events`, `iyzico_callbacks` kayıtları.

## Geçici aksiyonlar
- Sev-1 için rollback tetikle.
- Sadece push bozuksa webhook disable edilip in-app notification devam ettirilir.
- Ödeme release hatasında manuel release yapılmaz; önce authorization kontrolü doğrulanır.

## Rollback
- Uygulama: bir önceki stabil sürüme geri dön.
- Backend: destructive rollback yok; gerekiyorsa yeni düzeltme migration'ı yaz.
- Edge Function: önceki stabil sürümü redeploy et.

## Kapanış
- Root cause dokümante edilir.
- En geç 48 saat içinde postmortem yayınlanır.
- Aynı hatayı önleyen test/alert aksiyonu backlog'a eklenir.
