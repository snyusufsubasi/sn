# scripts/ — ARACIYOK komutlari

| Dosya | Ne yapar |
|--------|-----------|
| `setup.ps1` | Ilk kurulum: pub get, l10n, build_runner (~2 dk) |
| `bootstrap.ps1` | Tam kurulum + analyze + test (CI ile ayni) |
| `open_preview.bat` | Chrome'da web onizleme (port 8080) |
| `open_mobile.bat` | Gercek mobil: emulator veya USB telefon |
| `stop.ps1` | 8080/7357 portlarindaki sunuculari kapat |
| `preview.ps1` | PowerShell ile Chrome ac (gelismis) |

**Proje kokunde:** `AC.bat` = onizleme, `HAZIRLA.bat` = setup.

Detayli rehber: `docs/ERISIM.md`
