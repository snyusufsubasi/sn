# Ödeme Kurulumu

## v1.0 (MVP) — Havale / IBAN

- Nakliyeci kayıtta IBAN girer.
- Teslim çift onayından sonra iş `awaiting_payment` olur.
- Yükveren ödeme ekranından IBAN kopyalar, banka uygulamasından havale yapar.
- Nakliyeci **Ödeme alındı** der → iş `completed`.

Komisyon: **sıfır** (`commission_rate = 0`).

## v1.1 — Escrow (iyzico, opsiyonel)

1. iyzico merchant hesabı aç.
2. Supabase Edge Functions: `create-payment`, `iyzico-callback`.
3. Flutter: CheckoutForm WebView (`webview_flutter` — pubspec onayı gerekir).
4. `release_payment` RPC escrow serbest bırakma için kullanılır.

Sandbox test kartları iyzico dokümantasyonunda.
