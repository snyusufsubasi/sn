# ARACIYOK — Uygulamaya Erişim Rehberi

Bu dosya tek kaynak: projeyi her zaman nasıl açacağını buradan takip et.

---

## 1. İlk kez (veya bilgisayarı değiştirdin)

1. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) kurulu olsun (`flutter doctor`).
2. Proje klasörü: `C:\Users\snyus\Desktop\claude\araciyok`
3. **Çift tıkla:** `HAZIRLA.bat`  
   (veya terminal: `powershell -File scripts\setup.ps1`)

Bu adım `.env`, paketler ve codegen dosyalarını hazırlar.

---

## 2. Her gün — uygulamayı aç

### A) Web önizleme (en kolay, Chrome)

**Çift tıkla:** `AC.bat`

- Adres: **http://127.0.0.1:8080**
- Demo giriş:
  - Yükveren: `555 111 11 11` → OTP `123456`
  - Nakliyeci: `555 222 22 22` → OTP `123456`

> Bu mobil uygulamanın tarayıcıda açılmış halidir; geniş ekranda site gibi görünür. Gerçek mobil his için B seçeneğini kullan.

### B) Gerçek mobil (Android)

1. Android Studio emulator aç **veya** telefonu USB ile bağla (geliştirici modu).
2. **Çift tıkla:** `MOBIL.bat` (veya `scripts\open_mobile.bat`)

### C) Cursor / VS Code

1. `F5` → **ARACIYOK Web (Chrome)** veya **ARACIYOK Mobil**
2. Veya Terminal → Görevler → **ARACIYOK: Chrome'da Aç**

---

## 3. Kapatma

- Chrome/terminal penceresinde `q` (flutter run aktifse)
- Veya: `powershell -File scripts\stop.ps1`

---

## 4. Klasör haritası (nerede ne var)

```
araciyok/
├── AC.bat              ← UYGULAMAYI AÇ (web / Chrome)
├── MOBIL.bat           ← Android emulator veya telefon
├── HAZIRLA.bat         ← İlk kurulum
├── .env                ← Gizli ayarlar (git’e gitmez); DEMO_MODE=true
├── .env.example        ← Şablon
├── lib/                ← Uygulama kodu
│   ├── main.dart       ← Mobil giriş
│   ├── main_admin.dart ← Admin web (ayrı)
│   ├── core/           ← Tema, routing, hatalar
│   └── features/     ← auth, jobs, offers, messages...
├── supabase/
│   └── migrations/   ← 001 … 011 SQL (Supabase’e sırayla uygula)
├── scripts/          ← Tüm otomasyon komutları
├── docs/             ← ROADMAP, ERISIM, kurulum notları
└── test/             ← Otomatik testler
```

---

## 5. Modlar

| Mod | `.env` | Ne olur |
|-----|--------|---------|
| **Demo** | `DEMO_MODE=true` | Supabase gerekmez; bellekte sahte veri |
| **Canlı** | `DEMO_MODE=false` + Supabase anahtarları | Gerçek backend |

Şu an önizleme için demo yeterli.

---

## 6. Sorun giderme

| Belirti | Çözüm |
|---------|--------|
| Beyaz ekran | `HAZIRLA.bat` tekrar çalıştır; `AC.bat` ile aç |
| Port meşgul | `scripts\stop.ps1` sonra `AC.bat` |
| `Undefined *Provider` | `HAZIRLA.bat` (build_runner eksik) |
| Link açılmıyor | Cursor Simple Browser değil, **Chrome** kullan |
| Site gibi görünüyor | Normal (web önizleme); mobil için `open_mobile.bat` |

---

## 7. Canlı Supabase (ileride)

1. [Supabase](https://supabase.com) projesi oluştur.
2. SQL Editor’da `supabase/migrations/001` … `011` dosyalarını **sırayla** çalıştır.
3. `.env` içinde `DEMO_MODE=false` ve URL/anon key gir.
4. `HAZIRLA.bat` → `AC.bat` veya mobil.

Detay: `docs/PAYMENT_SETUP.md`, `docs/PUSH_SETUP.md`, `docs/MAP_SETUP.md`.
