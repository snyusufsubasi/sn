# AGENTS.md

Bu dosya Codex (veya başka bir AI agent) için kalıcı talimat dosyasıdır. Her oturumun başında oku. Kurallara aykırı kod yazma.

## Proje Kimliği

- **Ad**: ARACIYOK
- **Tip**: Türkiye odaklı yük pazarı mobil uygulaması
- **Stack**: Flutter 3.27+, Dart 3.5+, Supabase, Riverpod 2.x, go_router
- **Hedef platformlar**: Android (API 24+), iOS (13+), Flutter Web (sadece admin için)
- **Diller**: Türkçe (varsayılan), i18n altyapısı kurulu, İngilizce sonraki faz
- **Tasarım dili**: Uber-esque (siyah/beyaz dominant, tek turuncu vurgu, Inter tipografi)

## Roller

İki rol var, üçüncüsü yok:
- `shipper` (Yükveren) — yük ilanı oluşturur, teklif kabul eder
- `carrier` (Nakliyeci) — açık ilanlara teklif verir, taşıma yapar

Her iki rolün de iki tipi olabilir: `individual` (bireysel) veya `company` (şirket — vergi no var).

## Alt Sekmeler (her iki rol için sabit sıra)

```
Anasayfa | İlanlar | Bildirimler | Mesajlar | Profil
```

İçerik role göre değişir, **sıra değişmez**.

## İş Akışı Sözleşmesi

### İlan durumları (job_status enum)

```
open → offer_accepted → pickup_approval → loaded → on_road → delivery_approval → completed
                                                                              ↓
                                                                          (cancelled herhangi bir anda)
```

- `pickup_approval` ve `delivery_approval` **çift taraflı onay** ister. İki taraf da onayladığında sonraki duruma geçer.
- Teklif kabulünden ÖNCE: açık adres, telefon, plaka, mesajlaşma GİZLİ.
- Teklif kabulünden SONRA: tüm bunlar açılır.

### Teklif durumları (offer_status enum)

```
pending → accepted | rejected | withdrawn | expired
```

Bir ilanda yalnızca BİR teklif `accepted` olabilir (kısmi unique index ile garanti altında).

### Ödeme akışı (escrow)

```
1. Yükveren teklifi kabul eder → iyzico'ya yükveren ödeme yapar
2. Para platform escrow hesabında tutulur (payments.status='held')
3. Teslim onaylandıktan sonra nakliyeciye aktarılır (payments.status='released')
4. Anlaşmazlık varsa dispute açılır, admin karar verir
```

## Mimari Kuralları

### Klasör yapısı (DEĞİŞMEZ)

```
lib/
  core/        # ortak altyapı, sadece bağımsız şeyler
  features/<feature>/
    data/
      datasources/   # SupabaseClient ile direkt konuşan sınıflar
      models/        # JSON serializable, equatable
      repositories/  # interface + impl
    presentation/
      controllers/   # @riverpod notifier'lar
      screens/       # full-page widget'lar
      widgets/       # feature'a özel parça widget'lar
  shared/widgets/  # feature'lar arası ortak widget
  l10n/
  main.dart
```

### Katman kuralları

1. **`screens/`** sadece UI ve `ref.watch` çağırır. İçinde iş mantığı OLMAZ. Async call OLMAZ.
2. **`controllers/`** Riverpod notifier'lar. State yönetimi ve repository çağrıları burada. UI bilgisi yok.
3. **`repositories/`** interface'i `domain_repository.dart`'da, impl'i `*_repository_impl.dart`'da. Notifier interface'i kullanır, prod kodda impl bind edilir.
4. **`datasources/`** Supabase'le konuşan tek katman. Notifier ASLA `Supabase.instance.client` çağırmaz.
5. **`models/`** plain data class, `Equatable` mixin, `fromJson` / `toJson` metotları. Business logic yok.

### Tek yönlü veri akışı

```
Screen → ref.watch(controller) → Controller (state) → Repository → Datasource → Supabase
```

Tersine asla gidilmez. UI'dan datasource'a doğrudan erişim YASAK.

### Cross-feature import yasakları

- `features/a/` içinden `features/b/` import edilemez. Ortak şey varsa `shared/` veya `core/`'a alınır.
- TEK istisna: `features/shell/` her feature'ın screen'lerini import edebilir (sadece routing için).

## Kodlama Kuralları

### Genel

- **Dart**: `prefer_const_constructors`, `prefer_final_locals`, `require_trailing_commas`, `prefer_single_quotes`.
- **Tüm kullanıcıya görünen metinler**: Türkçe ve `l10n/app_tr.arb`'da. Hard-coded string YASAK (debug log hariç).
- **Mojibake yasak**: `İ`, `ı`, `ğ`, `ü`, `ş`, `ç`, `ö` doğru kullan. Soru işaretine bozulan harf bırakma.
- **Print yok**: `logger` paketi kullan.
- **Magic number yok**: `core/constants/` altında named constant.

### Naming

- Dosyalar: `snake_case.dart`
- Sınıflar: `PascalCase`
- Provider'lar: `<isim>Provider` (riverpod_generator zaten üretiyor)
- Private: `_underscorePrefix`

### Hata yönetimi

- Repository metodları `Future<Result<T>>` döndürür.
- `Result` = `core/errors/result.dart` (success / failure sealed class).
- `AppFailure` = `core/errors/failures.dart` (network, auth, validation, server, unknown).
- Controller `try-catch` yapmaz, repository'den gelen `Result`'ı state'e dönüştürür.

### Riverpod kullanımı

- Annotation kullan: `@riverpod` (gen 2.x).
- Auto-dispose default'tur. Persist gerekiyorsa `keepAlive: true`.
- State sınıfları `@freezed` veya `Equatable` ile immutable.

### Supabase kuralları

- Doğrudan `Supabase.instance.client` ÇAĞIRMA — `SupabaseClientWrapper` üzerinden geç (`core/network/supabase_client.dart`).
- Sorgu kuralları:
  - Profile bilgisi (telefon, plaka, açık adres) için **kesinlikle** RLS'e güven, client-side filter yapma.
  - Realtime subscription'lar dispose'da kapatılmalı.
  - Storage upload'larda path formatı: `{user_id}/{job_post_id}/{uuid}.jpg`.

## i18n

- Tüm metinler `lib/l10n/app_tr.arb` içinde.
- Kod tarafında: `context.l10n.someKey` veya `AppLocalizations.of(context)!.someKey`.
- Yeni metin eklendiğinde `flutter gen-l10n` çalıştırılır (otomatik gen kapalıysa).

## Test Kuralları

- Her feature için en az bir unit test (repository veya notifier).
- Her ekran için en az bir widget test (boş/dolu/hata senaryosu).
- Kritik happy-path'ler için integration test.
- Mock'lama: `mocktail` paketi.
- Test dosya konumu: `test/<unit|widget>/features/<feature>/...` — kaynak yapısını mirror'lar.

## NEYE DOKUNMA

- **`AGENTS.md`** — bu dosyayı kullanıcı izni olmadan değiştirme.
- **`pubspec.yaml`** — yeni paket eklerken kullanıcıdan onay al.
- **`.env`** — git'e gitmez, içeriği yazma.
- **`supabase/migrations/*.sql`** — onay almadan migration silme, sadece yeni dosya ekle.
- **`.github/workflows/`** — CI'ya dokunurken dikkat, lokal build kırıldığında CI'da da kırılır.

## Faz Disiplini

Bir feature'ı genişletirken o feature'ın fazına bak (`docs/ROADMAP.md`). Henüz açılmamış fazın işini yapma. Örnek: Faz 5 (Teklif) açılmadan ödeme akışına dokunma — placeholder bile bırakma.

## Codex'e Görev Verilirken

Kullanıcı bir prompt verdiğinde:

1. Önce `AGENTS.md`'yi (bu dosyayı) ve ilgili faz prompt'unu (`docs/PHASE_PROMPTS.md`) oku.
2. Mevcut kodu incele — hangi dosyalar var, hangi pattern kullanılmış.
3. Yeni dosya oluştururken klasör yapısına uy.
4. Mevcut bir dosyayı değiştirmeden önce kullanıcıya sor, eğer küçük bir refactor değilse.
5. Code generation gerektiren bir şey eklediysen (`@riverpod`, `@freezed`), prompt'un sonunda `dart run build_runner build --delete-conflicting-outputs` çalıştırmasını hatırlat.
6. Her commit'inin sonunda `flutter analyze` ve `flutter test` geçtiğinden emin ol.

## Mevcut Durum (Faz Takibi)

| Faz | Konu | Durum |
|---|---|---|
| 0 | Hazırlık ve temizlik | ✅ |
| 1 | Proje kurulumu + Uber tasarım sistemi | ✅ |
| 2 | Supabase şema ve backend altyapısı | ✅ (migration dosyaları hazır, kullanıcı kendi projesinde uygulayacak) |
| 3 | Auth ve profile | ✅ (temel akış kuruldu) |
| 4 | İlan CRUD | ⏳ Codex yapacak |
| 5 | Teklif ve operasyon akışı | ⏳ |
| 6 | Mesajlaşma ve realtime | ⏳ |
| 7 | Bildirimler (in-app + push) | ⏳ |
| 8 | Değerlendirme ve puanlama | ⏳ |
| 9 | Harita ve konum takibi | ⏳ |
| 10 | Ödeme ve escrow (iyzico) | ⏳ |
| 11 | Admin web paneli | ⏳ |
| 12 | Test, CI/CD, store hazırlığı | ⏳ |
