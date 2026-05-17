# Push Notification Kurulum Adımları

Bu doküman, push bildirimlerini canlıya alabilmek için yapılması gerekenleri sırayla anlatır. Kod tarafı zaten hazır; eksik olan **hesap işlemleri ve config dosyaları**.

## 1. Firebase Console

1. https://console.firebase.google.com → **"Add project"**
2. Proje adı: `araciyok` (veya istediğin)
3. Google Analytics: opsiyonel, kapatabilirsin
4. Proje oluştu.

## 2. Android için Firebase ekle

1. Sol menü → **Project Overview** → Android ikonu (📱)
2. **Android package name**: `android/app/build.gradle` dosyasındaki `applicationId`. Bilmiyorsan terminalde:
   ```bash
   grep applicationId android/app/build.gradle
   ```
   Çıkanı yapıştır.
3. **App nickname**: ARACIYOK Android
4. **SHA-1**: boş bırak (Auth değil, push için gerekmiyor)
5. **Register app**
6. **`google-services.json` dosyasını indir** → `android/app/` klasörüne koy (kök değil, `app/` alt klasörü)
7. "Add Firebase SDK" adımı → **atla**, FlutterFire CLI değil, manuel yapacağız
8. "Continue to console"

### Android build.gradle düzenleme

`android/build.gradle` (proje-seviye) — `buildscript.dependencies` bölümüne:

```gradle
buildscript {
    dependencies {
        // ... mevcut satırlar ...
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

`android/app/build.gradle` (modül-seviye) en üste apply ekle:

```gradle
plugins {
    // ... mevcut plugin'ler ...
    id "com.google.gms.google-services"
}
```

`android/app/build.gradle` içinde `minSdkVersion` minimum **21** olmalı (FCM şartı).

### AndroidManifest izinler

`android/app/src/main/AndroidManifest.xml` → `<application>` tag'inin **dışına**:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

Android 13+ runtime izin için bu şart.

## 3. iOS için Firebase ekle (Mac varsa)

1. Aynı projede "Add app" → iOS ikonu
2. **Bundle ID**: `ios/Runner.xcodeproj/project.pbxproj` içinde `PRODUCT_BUNDLE_IDENTIFIER` ne yazıyorsa
3. **`GoogleService-Info.plist`** indir → Xcode'da `Runner/` klasörüne sürükle (Add to target: Runner ✓)
4. Xcode'da Runner target → Signing & Capabilities → **"+ Capability"** → **"Push Notifications"** ekle
5. Aynı yerden **"Background Modes"** ekle → "Remote notifications" işaretle

### Info.plist'e (varsa zaten var, ama emin ol)

`ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### APNs Auth Key (canlı push için ŞART)

Apple Developer hesabı şart (yıllık $99). Olmadan iOS push çalışmaz.

1. https://developer.apple.com → Account → Certificates, Identifiers & Profiles
2. **Keys** → "+" → **Apple Push Notifications service (APNs)** seç → Continue
3. Key name: "ARACIYOK Push" → Continue → Register
4. **`.p8` dosyasını indir** (sadece bir kere indirebilirsin, kaybetme)
5. Key ID ve Team ID'yi not al
6. Firebase Console → Project Settings → **Cloud Messaging** sekmesi → iOS app → "APNs Authentication Key" altında **Upload**
7. `.p8` dosyasını yükle, Key ID ve Team ID gir

**Mac'in yoksa**: iOS push'u atla, sadece Android ile devam edebilirsin. Uygulama yine derlenir, iOS'ta push gelmez.

## 4. Supabase migration

```bash
# Supabase Studio → SQL Editor
# supabase/migrations/008_device_tokens.sql içeriğini yapıştır → Run
```

Veya CLI ile:
```bash
supabase db push
```

## 5. Edge Function deploy

```bash
# Supabase CLI gerekli (https://supabase.com/docs/guides/cli)
supabase login
supabase link --project-ref <senin-project-ref>

# Service account JSON al — Firebase Console → Project Settings →
# Service accounts → "Generate new private key" → JSON indir
# Adı firebase-adminsdk.json olsun.

# Secret olarak ekle (base64'lü):
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(base64 -i firebase-adminsdk.json)"
# (Linux: base64 firebase-adminsdk.json -w 0)

# Webhook imza doğrulaması için ek secret (önerilen)
supabase secrets set SEND_PUSH_WEBHOOK_SECRET="<uzun-rastgele-secret>"

# Function'ı deploy et
supabase functions deploy send-push --no-verify-jwt
```

## 6. Database Webhook bağla

`notifications` tablosuna INSERT → `send-push` fonksiyonunu çağıracak webhook.

1. Supabase Studio → **Database** → **Webhooks** → **"Create a new hook"**
2. Name: `notifications_push`
3. Table: `notifications`
4. Events: ☑ Insert (sadece insert)
5. Type: **Supabase Edge Function**
6. Edge Function: `send-push`
7. HTTP Headers:
   - `x-webhook-secret: <SEND_PUSH_WEBHOOK_SECRET>`
8. Create

## 7. Test et

```bash
# Uygulamayı çalıştır
flutter run

# Login ol → app fcm token alır, device_tokens tablosuna kaydeder.
# Logla doğrula:
#   logcat (Android) veya Xcode console'da: "Device token kaydedildi"

# Supabase'de manuel bir notification ekle:
# SQL Editor:
INSERT INTO notifications (user_id, type, title, body, data)
VALUES (
  'SENIN-USER-ID-BURAYA',
  'system',
  'Test bildirim',
  'Bu bir test mesajıdır',
  '{}'::jsonb
);

# Cihaza push gelmeli (uygulama foreground'daysa banner, background'daysa
# notification merkezi).
```

## 8. Common Issues

**"Default FirebaseApp is not initialized"**: `google-services.json` yanlış yerde veya Android build.gradle plugin eklenmemiş.

**iOS'ta APNs token null**: APNs sertifikası yok, fiziksel cihazda test etmiyorsun (simülatörde APNs yok), veya provisioning profile'da push capability yok.

**Edge function 401**: webhook header'larında `Authorization: Bearer <anon-key>` yoksa veya `--no-verify-jwt` ile deploy etmedin.

**Edge function token alamıyor**: `FCM_SERVICE_ACCOUNT_JSON` secret'i set değil, veya base64 yanlış formatta (newline'ları temizle).

**Push geliyor ama tıklamada doğru ekran açılmıyor**: webhook'ta data payload boş, veya notifications.data alanında `job_post_id` / `thread_id` yok. RPC'lerin bu alanları doldurduğundan emin ol.

## 9. Faz sonrası

Tüm bunlar çalıştıktan sonra:
- Yeni bir teklif geldiğinde nakliyeci push alır → ilanın detay sayfası açılır
- Mesaj geldiğinde push gelir → thread açılır
- Operasyon status değişimi → push, ilan detay sayfası açılır

Şu an `notifications` tablosuna INSERT atan tüm RPC'ler (accept_offer, vs. — `003_rpc_functions.sql` içinde) zaten data payload'ı dolduruyor, ek bir iş yok.
