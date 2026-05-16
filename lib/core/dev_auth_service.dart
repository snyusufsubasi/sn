import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasima_app/core/app_config.dart';

class DevAuthService {
  static const _keyLoggedIn = 'dev_logged_in';
  static const _keyRole = 'dev_user_role';
  static const _keyFullName = 'dev_full_name';
  static const _keyPhone = 'dev_phone';
  static const _keyCity = 'dev_city';
  static const _keyDistrict = 'dev_district';
  static const _keyUserType = 'dev_shipper_user_type';
  static const _keyVehicleType = 'dev_carrier_vehicle_type';
  static const _keyCapacity = 'dev_carrier_capacity_text';
  static const _keyPlate = 'dev_carrier_plate_number';
  static const _keyServiceAreas = 'dev_carrier_service_areas';
  static const _keyJobTypePrefs = 'dev_carrier_job_type_preferences';
  static const _keyProfileSetupComplete = 'dev_profile_setup_complete';
  static const _keyJobs = 'dev_jobs';
  static const _keyJobPrivateInfo = 'dev_job_private_info';
  static const _keyOffers = 'dev_offers';
  static const _keyReviews = 'dev_reviews';
  static const _keyNotifications = 'dev_notifications';
  static const _keyDemoProfiles = 'dev_demo_profiles';
  static const _keyMessages = 'dev_messages';

  static bool get isActive => !kReleaseMode && AppConfig.isDevAuthEnabled;
  static const String devUserId = 'dev-user-001';
  static const String demoShipperId = 'demo-shipper-001';
  static const String demoCarrierId = 'demo-carrier-001';

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  static Future<bool> isLoggedIn() async =>
      (await _prefs).getBool(_keyLoggedIn) ?? false;

  static Future<void> setLoggedIn(bool value) async {
    await (await _prefs).setBool(_keyLoggedIn, value);
  }

  static Future<String?> getRole() async => (await _prefs).getString(_keyRole);

  static Future<void> saveRole(String role) async {
    await (await _prefs).setString(_keyRole, role);
    debugPrint('DEV ROLE SAVED: $role');
  }

  static Future<Map<String, dynamic>> getBaseProfile() async {
    final p = await _prefs;
    return {
      'id': devUserId,
      'role': p.getString(_keyRole),
      'full_name': p.getString(_keyFullName) ?? '',
      'city': p.getString(_keyCity) ?? '',
      'district': p.getString(_keyDistrict) ?? '',
      'is_active': true,
    };
  }

  static Future<Map<String, dynamic>?> getProfileForUser(String userId) async {
    if (userId == devUserId) return getBaseProfile();
    final seededProfile = await _getDemoProfile(userId);
    if (seededProfile != null) return seededProfile;
    if (userId == demoCarrierId) {
      return {
        'id': demoCarrierId,
        'role': 'carrier',
        'full_name': 'Demo Nakliyeci',
        'city': 'İstanbul',
        'district': 'Ümraniye',
        'is_active': true,
      };
    }
    if (userId == demoShipperId) {
      return {
        'id': demoShipperId,
        'role': 'shipper',
        'full_name': 'Demo Yük Veren',
        'city': 'İstanbul',
        'district': 'Kadıköy',
        'is_active': true,
      };
    }
    return null;
  }

  static Future<void> saveBaseProfile({
    required String fullName,
    required String city,
    required String district,
  }) async {
    final p = await _prefs;
    await p.setString(_keyFullName, fullName);
    await p.setString(_keyCity, city);
    await p.setString(_keyDistrict, district);
    await p.setBool(_keyProfileSetupComplete, true);
    debugPrint('DEV PROFILE SAVED: $fullName, $city/$district');
  }

  static Future<bool> isProfileSetupComplete() async {
    final p = await _prefs;
    final role = p.getString(_keyRole);
    final name = p.getString(_keyFullName);
    final city = p.getString(_keyCity);
    final district = p.getString(_keyDistrict);
    if (role == null || name == null || city == null || district == null) {
      return false;
    }
    if (name.isEmpty || city.isEmpty || district.isEmpty) return false;
    return p.getBool(_keyProfileSetupComplete) ?? false;
  }

  static Future<Map<String, dynamic>?> getPhoneData() async {
    final phone = (await _prefs).getString(_keyPhone);
    if (phone == null) return null;
    return {'phone': phone};
  }

  static Future<void> savePhone(String phone) async {
    await (await _prefs).setString(_keyPhone, phone);
  }

  static Future<Map<String, dynamic>> getShipperProfile() async {
    final p = await _prefs;
    final seeded = await _getDemoProfile(devUserId);
    return {
      'id': devUserId,
      'company_name': p.getString(_keyFullName),
      'user_type': p.getString(_keyUserType) ?? 'individual',
      'rating_avg': seeded?['rating_avg'] ?? 4.7,
      'completed_jobs_count': seeded?['completed_jobs_count'] ?? 18,
    };
  }

  static Future<void> saveShipperProfile({required String userType}) async {
    await (await _prefs).setString(_keyUserType, userType);
  }

  static Future<Map<String, dynamic>> getCarrierProfile() async {
    final p = await _prefs;
    final seeded = await _getDemoProfile(devUserId);
    return {
      'id': devUserId,
      'company_name': p.getString(_keyFullName),
      'vehicle_type': p.getString(_keyVehicleType) ?? '',
      'capacity_text': p.getString(_keyCapacity) ?? '',
      'service_areas': p.getStringList(_keyServiceAreas) ?? [],
      'job_type_preferences': p.getStringList(_keyJobTypePrefs) ?? [],
      'rating_avg': seeded?['rating_avg'] ?? 4.8,
      'completed_jobs_count': seeded?['completed_jobs_count'] ?? 24,
    };
  }

  static Map<String, dynamic> demoCarrierPublicProfile([
    String carrierId = demoCarrierId,
  ]) {
    return {
      'id': carrierId,
      'company_name': carrierId == devUserId
          ? 'Benim Nakliye Profilim'
          : 'Demo Nakliyeci',
      'vehicle_type': 'Kamyonet',
      'capacity_text': '3.5 ton',
      'service_areas': ['İstanbul', 'Kocaeli', 'Bursa', 'Ankara'],
      'job_type_preferences': ['Ev eşyası', 'Parça eşya'],
      'rating_avg': 4.8,
      'completed_jobs_count': 24,
    };
  }

  static Future<void> saveCarrierProfile({
    required String vehicleType,
    required String capacityText,
    required List<String> serviceAreas,
    required List<String> jobTypePreferences,
  }) async {
    final p = await _prefs;
    await p.setString(_keyVehicleType, vehicleType);
    await p.setString(_keyCapacity, capacityText);
    await p.setStringList(_keyServiceAreas, serviceAreas);
    await p.setStringList(_keyJobTypePrefs, jobTypePreferences);
  }

  static Future<Map<String, dynamic>> getCarrierPlate() async {
    final plate = (await _prefs).getString(_keyPlate);
    return {'plate_number': plate ?? ''};
  }

  static Future<void> savePlate(String plate) async {
    await (await _prefs).setString(_keyPlate, plate);
  }

  static Future<void> switchToDemoShipper() async {
    await setLoggedIn(true);
    await saveRole('shipper');
    await saveBaseProfile(
      fullName: 'Demo Yük Veren',
      city: 'İstanbul',
      district: 'Kadıköy',
    );
    await savePhone('+905359398313');
    await saveShipperProfile(userType: 'individual');
    await ensureDemoData();
  }

  static Future<void> switchToDemoCarrier() async {
    await setLoggedIn(true);
    await saveRole('carrier');
    await saveBaseProfile(
      fullName: 'Demo Nakliyeci',
      city: 'İstanbul',
      district: 'Ümraniye',
    );
    await savePhone('+905359398313');
    await saveCarrierProfile(
      vehicleType: 'Kamyonet',
      capacityText: '3.5 ton',
      serviceAreas: ['İstanbul', 'Kocaeli', 'Bursa'],
      jobTypePreferences: ['Ev eşyası', 'Parça eşya'],
    );
    await savePlate('34 DEV 001');
    await ensureDemoData();
  }

  static Future<void> ensureDemoData() async {
    if (!AppConfig.isDemoDataEnabled) return;

    final jobs = await _readList(_keyJobs);
    final offers = await _readList(_keyOffers);
    final reviews = await _readList(_keyReviews);
    final notifications = await _readList(_keyNotifications);
    final profiles = await _readList(_keyDemoProfiles);
    if (jobs.length >= 80 &&
        offers.length >= 200 &&
        reviews.length >= 100 &&
        notifications.length >= 50 &&
        profiles.length >= 150) {
      return;
    }

    final now = DateTime.now();
    final cities = [
      ('İstanbul', 'Kadıköy'),
      ('Ankara', 'Çankaya'),
      ('İzmir', 'Bornova'),
      ('Bursa', 'Nil?fer'),
      ('Kocaeli', 'Gebze'),
      ('Sakarya', 'Adapazarı'),
      ('Konya', 'Sel?uklu'),
      ('Antalya', 'Muratpaşa'),
      ('Adana', 'Seyhan'),
      ('Gaziantep', 'Şahinbey'),
    ];
    final cargoTypes = [
      'ev_eşyasi',
      'parca_eşya',
      'paletli_urun',
      'insaat_malzemesi',
      'makine',
      'mobilya',
      'gida_disi',
      'Diğer',
    ];
    final firstNames = [
      'Ahmet',
      'Mehmet',
      'Mustafa',
      'Ayşe',
      'Fatma',
      'Emine',
      'Yusuf',
      'Hasan',
      'Zeynep',
      'Elif',
    ];
    final lastNames = [
      'Yılmaz',
      'Demir',
      'Kaya',
      'Şahin',
      'Çelik',
      'Yıldız',
      'Aydın',
      'Öztürk',
      'Arslan',
      'Koç',
    ];

    profiles
      ..clear()
      ..add({
        'id': demoShipperId,
        'role': 'shipper',
        'full_name': 'Demo Yük Veren',
        'city': 'İstanbul',
        'district': 'Kadıköy',
        'phone': '+905320000001',
        'rating_avg': 4.7,
        'completed_jobs_count': 18,
        'is_active': true,
      })
      ..add({
        'id': demoCarrierId,
        'role': 'carrier',
        'full_name': 'Demo Nakliyeci',
        'city': 'İstanbul',
        'district': 'Ümraniye',
        'phone': '+905320000002',
        'vehicle_type': 'Kamyonet',
        'capacity_text': '3.5 ton',
        'plate_number': '34 DEMO 34',
        'rating_avg': 4.8,
        'completed_jobs_count': 24,
        'is_active': true,
      });

    for (var i = 0; i < 150; i++) {
      final isShipper = i < 60;
      final city = cities[i % cities.length];
      profiles.add({
        'id':
            '${isShipper ? 'shipper' : 'carrier'}-${i.toString().padLeft(3, '0')}',
        'role': isShipper ? 'shipper' : 'carrier',
        'full_name':
            '${firstNames[i % firstNames.length]} ${lastNames[(i * 3) % lastNames.length]}',
        'city': city.$1,
        'district': city.$2,
        'phone': '+90532${(1000000 + i).toString().padLeft(7, '0')}',
        'user_type': i.isEven ? 'individual' : 'company',
        'vehicle_type': ['Kamyonet', 'Kamyon', 'T?r', 'Panelvan'][i % 4],
        'capacity_text': ['1.5 ton', '3.5 ton', '10 ton', '24 ton'][i % 4],
        'plate_number': '${(34 + i) % 81} ARK ${100 + i}',
        'service_areas': [city.$1, cities[(i + 1) % cities.length].$1],
        'job_type_preferences': ['Ev eşyası', 'Par?a e?ya', 'Paletli ?r?n'],
        'rating_avg': 3.8 + ((i % 12) / 10),
        'completed_jobs_count': 4 + (i % 65),
        'is_active': true,
      });
    }
    await _writeList(_keyDemoProfiles, profiles);

    jobs.clear();
    final privateInfo = <Map<String, dynamic>>[];
    for (var i = 0; i < 80; i++) {
      final pickup = cities[i % cities.length];
      final delivery = cities[(i + 3) % cities.length];
      final status = [
        'open',
        'open',
        'open',
        'offer_accepted',
        'in_progress',
        'completed',
        'cancelled',
      ][i % 7];
      final jobId = i == 0
          ? 'demo-job-own-001'
          : 'demo-job-${i.toString().padLeft(3, '0')}';
      final shipperId = i < 14
          ? devUserId
          : (i == 15
                ? demoShipperId
                : 'shipper-${(i % 60).toString().padLeft(3, '0')}');
      final acceptedOfferId = status == 'open' || status == 'cancelled'
          ? null
          : 'demo-offer-accepted-${i.toString().padLeft(3, '0')}';
      jobs.add({
        'id': jobId,
        'shipper_id': shipperId,
        'cargo_type': cargoTypes[i % cargoTypes.length],
        'cargo_description':
            '${_cargoLabel(cargoTypes[i % cargoTypes.length])} taşınacak. Kat, paketleme ve zaman bilgileri ilanda belirtilmi?tir.',
        'pickup_city': pickup.$1,
        'pickup_district': pickup.$2,
        'delivery_city': delivery.$1,
        'delivery_district': delivery.$2,
        'pickup_date': now
            .add(Duration(days: 1 + (i % 18)))
            .toIso8601String()
            .substring(0, 10),
        'pickup_time_window': i.isEven ? '09:00 - 13:00' : '13:00 - 18:00',
        'is_date_flexible': i % 3 == 0,
        'urgency_level': ['normal', 'urgent', 'very_urgent'][i % 3],
        'extra_notes':
            'Açık adres ve telefon bilgisi sadece eşleşme sonrasİş paylaşılır.',
        'status': status,
        'accepted_offer_id': acceptedOfferId,
        'cancelled_reason': status == 'cancelled'
            ? 'Yük veren taşıma tarihini erteledi.'
            : null,
        'created_at': now.subtract(Duration(hours: i + 2)).toIso8601String(),
        'updated_at': now.subtract(Duration(minutes: i * 7)).toIso8601String(),
      });
      privateInfo.add({
        'job_post_id': jobId,
        'pickup_address':
            '${pickup.$2} Mahallesi, ${10 + i}. Sokak No:${1 + i}',
        'delivery_address':
            '${delivery.$2} Mahallesi, ${20 + i}. Cadde No:${5 + i}',
      });
    }
    await _writeList(_keyJobs, jobs);
    await _writeList(_keyJobPrivateInfo, privateInfo);

    offers.clear();
    var offerIndex = 0;
    for (var jobIndex = 0; jobIndex < jobs.length; jobIndex++) {
      final job = jobs[jobIndex];
      final offerCount = jobIndex % 9;
      for (var k = 0; k < offerCount; k++) {
        final acceptedId = job['accepted_offer_id'] as String?;
        final isAccepted = acceptedId != null && k == 0;
        final carrierId = jobIndex < 12 || offerIndex < 24
            ? devUserId
            : 'carrier-${((jobIndex + k) % 90 + 60).toString().padLeft(3, '0')}';
        offers.add({
          'id': isAccepted
              ? acceptedId
              : 'demo-offer-${offerIndex.toString().padLeft(3, '0')}',
          'job_post_id': job['id'],
          'carrier_id': carrierId,
          'amount': (1500 + ((jobIndex * 733 + k * 1750) % 43500)).toDouble(),
          'currency': 'TRY',
          'note':
              'Uygun tarihte sigortalı taşıma yapabilirim. Ekip ve araİş hazır.',
          'available_at': job['pickup_date'],
          'status': isAccepted
              ? 'accepted'
              : ['pending', 'pending', 'rejected', 'withdrawn'][offerIndex % 4],
          'created_at': now
              .subtract(Duration(hours: offerIndex + 1))
              .toIso8601String(),
          'updated_at': now
              .subtract(Duration(minutes: offerIndex + 4))
              .toIso8601String(),
        });
        offerIndex++;
      }
    }
    while (offers.length < 200) {
      final i = offers.length;
      final job = jobs[i % jobs.length];
      offers.add({
        'id': 'demo-offer-extra-${i.toString().padLeft(3, '0')}',
        'job_post_id': job['id'],
        'carrier_id': i.isEven
            ? devUserId
            : 'carrier-${((i % 90) + 60).toString().padLeft(3, '0')}',
        'amount': (2500 + ((i * 947) % 42000)).toDouble(),
        'currency': 'TRY',
        'note': 'Demo teklif: hızlı, temiz ve güvenli taşıma.',
        'available_at': job['pickup_date'],
        'status': ['pending', 'accepted', 'rejected', 'withdrawn'][i % 4],
        'created_at': now.subtract(Duration(hours: i)).toIso8601String(),
        'updated_at': now.subtract(Duration(minutes: i)).toIso8601String(),
      });
    }
    await _writeList(_keyOffers, offers);

    reviews.clear();
    for (var i = 0; i < 100; i++) {
      reviews.add({
        'id': 'demo-review-${i.toString().padLeft(3, '0')}',
        'job_post_id': jobs[i % jobs.length]['id'],
        'reviewer_id': i.isEven
            ? 'shipper-${(i % 60).toString().padLeft(3, '0')}'
            : 'carrier-${((i % 90) + 60).toString().padLeft(3, '0')}',
        'reviewee_id': i.isEven
            ? 'carrier-${((i % 90) + 60).toString().padLeft(3, '0')}'
            : 'shipper-${(i % 60).toString().padLeft(3, '0')}',
        'rating': 1 + (i % 5),
        'comment': [
          'Zamanında geldi.',
          'İletişim çok iyiydi.',
          'Taşıma temiz yapıldı.',
          'Fiyat ve hizmet dengeli.',
          'Tekrar çalışırım.',
        ][i % 5],
        'created_at': now.subtract(Duration(days: i % 30)).toIso8601String(),
      });
    }
    await _writeList(_keyReviews, reviews);

    notifications.clear();
    for (var i = 0; i < 50; i++) {
      notifications.add({
        'id': 'demo-notification-${i.toString().padLeft(3, '0')}',
        'user_id': devUserId,
        'title': [
          'Yeni teklif geldi',
          'Teklif kabul edildi',
          'Taşıma başladı',
          'İş tamamlandı',
        ][i % 4],
        'body': 'Demo bildirimi: ilgili ilana dokunarak detaya gidebilirsiniz.',
        'type': ['offer', 'offer_accepted', 'status_change', 'review'][i % 4],
        'related_job_id': jobs[i % jobs.length]['id'],
        'related_offer_id': offers[i % offers.length]['id'],
        'is_read': i % 3 == 0,
        'created_at': now.subtract(Duration(minutes: 15 * i)).toIso8601String(),
      });
    }
    await _writeList(_keyNotifications, notifications);

    final messages = await _readList(_keyMessages);
    if (messages.length < 20) {
      final baseTime = DateTime.now();
      const sampleMessages = [
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Merhaba, ilaninizla ilgili gorusmek isterim.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Merhaba, tabii ki. Hangi ilan icin?'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Istanbul-Kocaeli arasi ev eşyasi tasimasi icin.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Anladim, arac kapasiteniz nedir?'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': '3.5 ton kapasiteli kamyonetim var. Sigortali tasima yapiyorum.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Harika, teklifinizi bekliyorum o zaman.'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Teklifi gonderdim bile. Uygun olursa hemen baslayabilirim.'},
        {'from': 'demo-shipper-001', 'to': 'dev-user-001', 'text': 'Merhaba, Ankara\'ya tasima yapiyor musunuz?'},
        {'from': 'dev-user-001', 'to': 'demo-shipper-001', 'text': 'Merhaba, evet Ankara guzergahimda var.'},
        {'from': 'demo-shipper-001', 'to': 'dev-user-001', 'text': 'Insallah bu hafta ici yukleme yapabilir miyiz?'},
        {'from': 'dev-user-001', 'to': 'demo-shipper-001', 'text': 'Persembe gunu musaitim, size uyar mi?'},
        {'from': 'demo-shipper-001', 'to': 'dev-user-001', 'text': 'Persembe harika olur, saat 10:00\'da yukleme yapalim.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Tesekkurler, teklifinizi degerlendiriyorum.'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Rica ederim, baska sorunuz olursa yazabilirsiniz.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Bir sey sormak istiyorum, yukleme saatleri esnek mi?'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Evet, sabah 8\'den aksam 6\'ya kadar esnek calisabiliyorum.'},
        {'from': 'dev-user-001', 'to': 'demo-carrier-001', 'text': 'Cok iyi, yarin kesin donus yapacagim.'},
        {'from': 'demo-carrier-001', 'to': 'dev-user-001', 'text': 'Bekliyorum, iyi aksamlar.'},
        {'from': 'demo-shipper-001', 'to': 'dev-user-001', 'text': 'Persembe gunu adresi paylasabilir misiniz?'},
        {'from': 'dev-user-001', 'to': 'demo-shipper-001', 'text': 'Tabii, yuklemeden bir gun once adresi gonderecegim.'},
      ];
      for (var i = 0; i < sampleMessages.length; i++) {
        final m = sampleMessages[i];
        messages.add({
          'id': 'demo-msg-${i.toString().padLeft(3, '0')}',
          'sender_id': m['from'],
          'receiver_id': m['to'],
          'job_post_id': i < 8 ? 'demo-job-001' : null,
          'content': m['text'],
          'created_at': baseTime.subtract(Duration(hours: sampleMessages.length - i, minutes: (i * 7) % 60)).toIso8601String(),
          'is_read': i % 3 != 0,
        });
      }
      await _writeList(_keyMessages, messages);
    }
  }

  static Future<List<Map<String, dynamic>>> getJobs() async {
    await ensureDemoData();
    return _readList(_keyJobs);
  }

  static Future<Map<String, dynamic>?> getJob(String jobId) async {
    final jobs = await getJobs();
    try {
      return jobs.firstWhere((j) => j['id'] == jobId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> upsertJob(Map<String, dynamic> job) async {
    final jobs = await getJobs();
    final index = jobs.indexWhere((j) => j['id'] == job['id']);
    if (index >= 0) {
      jobs[index] = job;
    } else {
      jobs.add(job);
    }
    await _writeList(_keyJobs, jobs);
  }

  static Future<void> saveJobPrivateInfo(Map<String, dynamic> info) async {
    final items = await _readList(_keyJobPrivateInfo);
    final index = items.indexWhere(
      (i) => i['job_post_id'] == info['job_post_id'],
    );
    if (index >= 0) {
      items[index] = info;
    } else {
      items.add(info);
    }
    await _writeList(_keyJobPrivateInfo, items);
  }

  static Future<Map<String, dynamic>?> getJobPrivateInfo(String jobId) async {
    final items = await _readList(_keyJobPrivateInfo);
    try {
      return items.firstWhere((i) => i['job_post_id'] == jobId);
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getOffers() async {
    await ensureDemoData();
    return _readList(_keyOffers);
  }

  static Future<void> upsertOffer(Map<String, dynamic> offer) async {
    final offers = await getOffers();
    final index = offers.indexWhere((o) => o['id'] == offer['id']);
    if (index >= 0) {
      offers[index] = offer;
    } else {
      offers.add(offer);
    }
    await _writeList(_keyOffers, offers);
  }

  static Future<List<Map<String, dynamic>>> getReviews() async =>
      _readList(_keyReviews);

  static Future<void> addReview(Map<String, dynamic> review) async {
    final reviews = await getReviews();
    reviews.add(review);
    await _writeList(_keyReviews, reviews);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async =>
      _readList(_keyNotifications);

  static Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index >= 0) {
      notifications[index]['is_read'] = true;
      await _writeList(_keyNotifications, notifications);
    }
  }

  static Future<void> markAllNotificationsAsRead() async {
    final notifications = await getNotifications();
    for (final notification in notifications) {
      if (notification['user_id'] == devUserId) notification['is_read'] = true;
    }
    await _writeList(_keyNotifications, notifications);
  }

  static Future<void> addNotification(Map<String, dynamic> notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    await _writeList(_keyNotifications, notifications);
  }

  static Future<void> clear() async {
    final p = await _prefs;
    final keys = [
      _keyLoggedIn,
      _keyRole,
      _keyFullName,
      _keyPhone,
      _keyCity,
      _keyDistrict,
      _keyUserType,
      _keyVehicleType,
      _keyCapacity,
      _keyPlate,
      _keyServiceAreas,
      _keyJobTypePrefs,
      _keyProfileSetupComplete,
    ];
    for (final k in keys) {
      await p.remove(k);
    }
  }

  static Future<Map<String, dynamic>?> _getDemoProfile(String userId) async {
    final profiles = await _readList(_keyDemoProfiles);
    try {
      return profiles.firstWhere((profile) => profile['id'] == userId);
    } catch (_) {
      return null;
    }
  }

  static String _cargoLabel(String value) {
    const labels = {
      'ev_eşyasi': 'Ev eşyası',
      'parca_eşya': 'Parça eşya',
      'paletli_urun': 'Paletli ürün',
      'insaat_malzemesi': 'İnşaat malzemesi',
      'makine': 'Makine',
      'mobilya': 'Mobilya',
      'gida_disi': 'Gıda dışı ürün',
      'Diğer': 'Diğer yük',
    };
    return labels[value] ?? value;
  }

  static Future<List<Map<String, dynamic>>> _readList(String key) async {
    final raw = (await _prefs).getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await (await _prefs).setString(key, jsonEncode(value));
  }
}
