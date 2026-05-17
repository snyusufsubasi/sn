import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';

/// Push notification servisi.
///
/// Sorumlulukları:
/// - FCM init
/// - Permission iste
/// - Device token al → device_tokens tablosuna kaydet
/// - Foreground'da gelen mesajları local notification olarak göster
/// - Background/terminated mesajlarda navigation (callback ile)
class PushNotificationService {
  PushNotificationService(this._client);

  final SupabaseClientWrapper _client;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Bildirime tıklandığında çağırılır (data payload geçer).
  /// AppRouter init olduktan sonra set edilir.
  void Function(Map<String, dynamic> data)? onNotificationTap;

  bool _initialized = false;

  /// Tüm push setup'ı. main.dart'tan auth login sonrası çağırılır.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. İzin iste (iOS ve Android 13+)
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.i('Push izin durumu: ${settings.authorizationStatus}');

      // 2. Local notifications init (foreground bildirim göstermek için)
      await _initLocalNotifications();

      // 3. Token al ve sakla
      await _registerCurrentToken();

      // 4. Token yenilenince güncelle
      _fcm.onTokenRefresh.listen((newToken) async {
        AppLogger.i('FCM token yenilendi');
        await _saveToken(newToken);
      });

      // 5. Foreground mesajları
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Bildirime tıklayarak açılan mesaj (uygulama açıkken)
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        AppLogger.i('Bildirime tıklandı (background→foreground): ${msg.data}');
        onNotificationTap?.call(msg.data);
      });

      // 7. Uygulama terminated iken bildirim açtıysa
      final initialMsg = await _fcm.getInitialMessage();
      if (initialMsg != null) {
        AppLogger.i('Terminated state bildirim: ${initialMsg.data}');
        // initRoute hazır olmayabilir, küçük gecikme ile dene
        Future.delayed(const Duration(milliseconds: 800), () {
          onNotificationTap?.call(initialMsg.data);
        });
      }
    } catch (e, st) {
      AppLogger.e('Push init hatası', e, st);
    }
  }

  /// Kullanıcı çıkış yapınca token'ı deaktive et.
  Future<void> deactivateCurrentToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _client
          .from('device_tokens')
          .update({'is_active': false}).eq('token', token);
    } catch (e, st) {
      AppLogger.e('Token deactivate hatası', e, st);
    }
  }

  Future<void> _registerCurrentToken() async {
    String? token;
    try {
      if (Platform.isIOS) {
        // APNs token önce gelmeli
        final apns = await _fcm.getAPNSToken();
        if (apns == null) {
          AppLogger.w('APNs token null — APNs sertifikası eksik olabilir');
          return;
        }
      }
      token = await _fcm.getToken();
    } catch (e, st) {
      AppLogger.e('FCM token alınamadı', e, st);
      return;
    }
    if (token == null) {
      AppLogger.w('FCM token null geldi');
      return;
    }
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final uid = _client.currentUserId;
    if (uid == null) {
      AppLogger.w('Token kaydedilemedi: kullanıcı yok');
      return;
    }
    try {
      await _client.from('device_tokens').upsert(
        {
          'user_id': uid,
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'is_active': true,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      AppLogger.i('Device token kaydedildi');
    } catch (e, st) {
      AppLogger.e('Token DB kaydı hatası', e, st);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // izin FCM tarafında alındı
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        // payload'u parse edip route et
        // Çok karmaşık değil: notification_id, type, job_post_id vs.
        final data = _parsePayload(response.payload!);
        onNotificationTap?.call(data);
      },
    );

    // Android için kanal oluştur (Edge Function 'araciyok_default' kullanıyor)
    final androidImpl =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'araciyok_default',
        'Genel Bildirimler',
        description: 'Teklif, mesaj ve operasyon bildirimleri',
        importance: Importance.high,
      ),
    );
  }

  void _handleForegroundMessage(RemoteMessage msg) {
    AppLogger.i('Foreground mesaj: ${msg.notification?.title}');
    final notif = msg.notification;
    if (notif == null) return;

    // Payload'u key=value biçiminde stringle (sade tutuyoruz)
    final payload = msg.data.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    _local.show(
      msg.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'araciyok_default',
          'Genel Bildirimler',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      payload: payload,
    );
  }

  Map<String, dynamic> _parsePayload(String payload) {
    final map = <String, dynamic>{};
    for (final kv in payload.split('&')) {
      final parts = kv.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}

/// Background mesaj handler — top-level fonksiyon olmalı.
/// Sadece data-only mesajlarda gerekir; sistem zaten notification mesajını
/// kendisi gösterir. Burada karmaşık iş yapmıyoruz.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    // ignore: avoid_print
    print('Background mesaj: ${message.messageId}');
  }
}
